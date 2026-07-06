import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Chrome/Windows on same laptop: http://127.0.0.1:8000
  // Android emulator: --dart-define=API_BASE_URL=http://10.0.2.2:8000
  // Real phone: --dart-define=API_BASE_URL=http://YOUR_PC_IP:8000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );

  static const Duration _timeout = Duration(seconds: 12);

  static String? _token;
  static String? _activeRole;

  static String? get token => _token;
  static String? get activeRole => _activeRole;

  static String _roleTokenKey(String role) => '${role}_token';
  static String _roleEmailKey(String role) => '${role}_email';

  static String imageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    final value = path.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    if (value.startsWith('/')) return '$baseUrl$value';
    return value;
  }

  static Future<void> saveSession({
    required String token,
    required String role,
    String? email,
  }) async {
    final normalizedRole = role.trim();
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', token);
    await prefs.setString('role', normalizedRole);
    await prefs.setString(_roleTokenKey(normalizedRole), token);

    if (email != null && email.trim().isNotEmpty) {
      await prefs.setString(_roleEmailKey(normalizedRole), email.trim());
    }

    _token = token;
    _activeRole = normalizedRole;
  }

  static Future<Map<String, String>?> loadSession({String? role}) async {
    final prefs = await SharedPreferences.getInstance();

    if (role != null) {
      final normalizedRole = role.trim();
      final token = prefs.getString(_roleTokenKey(normalizedRole));
      final email = prefs.getString(_roleEmailKey(normalizedRole));

      if (token == null || token.isEmpty) return null;

      _token = token;
      _activeRole = normalizedRole;

      return {
        'token': token,
        'role': normalizedRole,
        if (email != null && email.isNotEmpty) 'email': email,
      };
    }

    final token = prefs.getString('token');
    final activeRole = prefs.getString('role');

    if (token == null || activeRole == null) return null;

    _token = token;
    _activeRole = activeRole;

    final email = prefs.getString(_roleEmailKey(activeRole));
    return {
      'token': token,
      'role': activeRole,
      if (email != null && email.isNotEmpty) 'email': email,
    };
  }



  static Future<bool> ensureSession({String? role}) async {
    final requiredRole = role?.trim();

    if (_token != null && _token!.isNotEmpty) {
      if (requiredRole == null || requiredRole.isEmpty || _activeRole == requiredRole) {
        return true;
      }
    }

    final session = await loadSession(role: requiredRole);
    if (session == null) return false;

    final sessionToken = session['token'];
    final sessionRole = session['role'];

    return sessionToken != null &&
        sessionToken.isNotEmpty &&
        (requiredRole == null || requiredRole.isEmpty || sessionRole == requiredRole);
  }

  static Future<bool> ensureOrganizationSession() {
    return ensureSession(role: 'organization');
  }

  static Future<bool> ensureClientSession() {
    return ensureSession(role: 'client');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove(_roleTokenKey('client'));
    await prefs.remove(_roleEmailKey('client'));
    await prefs.remove(_roleTokenKey('organization'));
    await prefs.remove(_roleEmailKey('organization'));
    _token = null;
    _activeRole = null;
  }

  static Future<void> clearToken() async => logout();

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Map<String, String> get _authHeaders => {
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Uri _uri(String path, [Map<String, String>? queryParameters]) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: queryParameters);
  }

  static Map<String, dynamic> _decodeMap(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'data': decoded};
  }

  static String _messageFrom(Map<String, dynamic> data, String fallback) {
    final detail = data['detail'];
    if (detail is String && detail.isNotEmpty) return detail;
    if (detail is List && detail.isNotEmpty) return detail.first.toString();
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
    return fallback;
  }

  static Map<String, dynamic> _networkError(Object error) {
    if (error is TimeoutException) {
      return {
        'success': false,
        'message': 'Server response timed out. Please check backend connection.',
      };
    }
    return {
      'success': false,
      'message': 'Cannot connect to backend server. Check API_BASE_URL and run the backend.',
    };
  }

  static Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body, {
    String failureMessage = 'Request failed',
  }) async {
    try {
      final response = await http
          .post(_uri(path), headers: _headers, body: jsonEncode(body))
          .timeout(_timeout);
      final data = _decodeMap(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, ...data};
      }
      if (response.statusCode == 401) {
        final message = _messageFrom(data, failureMessage);
        if (message.toLowerCase().contains('invalid token') ||
            message.toLowerCase().contains('not authenticated')) {
          await logout();
          return {
            'success': false,
            'message': 'Session expired. Please login as organization again.',
          };
        }
      }
      return {'success': false, 'message': _messageFrom(data, failureMessage)};
    } catch (error) {
      return _networkError(error);
    }
  }

  static Future<Map<String, dynamic>> _putJsonMap(
    String path,
    Map<String, dynamic> body, {
    String failureMessage = 'Update failed',
  }) async {
    try {
      final response = await http
          .put(_uri(path), headers: _headers, body: jsonEncode(body))
          .timeout(_timeout);
      final data = _decodeMap(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, ...data};
      }
      if (response.statusCode == 401) {
        final message = _messageFrom(data, failureMessage);
        if (message.toLowerCase().contains('invalid token') ||
            message.toLowerCase().contains('not authenticated')) {
          await logout();
          return {
            'success': false,
            'message': 'Session expired. Please login as organization again.',
          };
        }
      }
      return {'success': false, 'message': _messageFrom(data, failureMessage)};
    } catch (error) {
      return _networkError(error);
    }
  }

  static Future<bool> _putJson(String path, Map<String, dynamic> data) async {
    final response = await _putJsonMap(path, data);
    return response['success'] == true;
  }

  static Future<Map<String, dynamic>?> _getMap(String path, [Map<String, String>? query]) async {
    try {
      final response = await http.get(_uri(path, query), headers: _headers).timeout(_timeout);
      if (response.statusCode == 200 && response.body.trim() != 'null') {
        return _decodeMap(response.body);
      }
      if (response.statusCode == 401) {
        final data = _decodeMap(response.body);
        final message = _messageFrom(data, 'Unauthorized');
        if (message.toLowerCase().contains('invalid token') ||
            message.toLowerCase().contains('not authenticated')) {
          await logout();
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static Future<Map<String, dynamic>> clientLogin(String email, String password) async {
    final data = await _postJson(
      '/client/login',
      {'email': email, 'password': password},
      failureMessage: 'Login failed',
    );
    if (data['success'] == true && data['token'] != null) {
      await saveSession(token: data['token'], role: 'client', email: email);
    }
    return {'success': data['success'] == true, 'message': _messageFrom(data, 'Login successful')};
  }

  static Future<Map<String, dynamic>> clientSignup(
    String username,
    String email,
    String password,
  ) async {
    final data = await _postJson(
      '/client/signup',
      {'username': username, 'email': email, 'password': password},
      failureMessage: 'Signup failed',
    );
    if (data['success'] == true && data['token'] != null) {
      await saveSession(token: data['token'], role: 'client', email: email);
    }
    return {'success': data['success'] == true, 'message': _messageFrom(data, 'Client signup successful')};
  }

  static Future<Map<String, dynamic>> orgLogin(String email, String password) async {
    final data = await _postJson(
      '/organization/login',
      {'email': email, 'password': password},
      failureMessage: 'Login failed',
    );
    if (data['success'] == true && data['token'] != null) {
      await saveSession(token: data['token'], role: 'organization', email: email);
    }
    return {'success': data['success'] == true, 'message': _messageFrom(data, 'Organization login successful')};
  }

  static Future<Map<String, dynamic>> orgSignup(
    String organizationName,
    String email,
    String password, {
    String orgType = 'General',
    String registrationNumber = '',
    String phone = '',
    String address = '',
  }) async {
    final data = await _postJson(
      '/organization/signup',
      {
        'organization_name': organizationName,
        'org_type': orgType,
        'email': email,
        'password': password,
        'registration_number': registrationNumber,
        'phone': phone,
        'address': address,
      },
      failureMessage: 'Signup failed',
    );
    if (data['success'] == true && data['token'] != null) {
      await saveSession(token: data['token'], role: 'organization', email: email);
    }
    return {'success': data['success'] == true, 'message': _messageFrom(data, 'Organization signup successful')};
  }

  static Future<Map<String, dynamic>> clientGoogleLogin() => _googleLogin(role: 'client');
  static Future<Map<String, dynamic>> organizationGoogleLogin() => _googleLogin(role: 'organization');

  static Future<Map<String, dynamic>> _googleLogin({required String role}) async {
    if (kIsWeb && googleClientId.isEmpty) {
      return {
        'success': false,
        'message': 'Google Sign-In needs GOOGLE_CLIENT_ID for Chrome/Web testing.',
      };
    }

    try {
      final googleSignIn = GoogleSignIn(
        clientId: googleClientId.isEmpty ? null : googleClientId,
        scopes: const ['email', 'profile'],
      );
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Google verification cancelled.'};
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        return {'success': false, 'message': 'Google could not return a verification token.'};
      }

      final endpoint = role == 'organization' ? '/organization/google-login' : '/client/google-login';
      final data = await _postJson(
        endpoint,
        {'id_token': idToken},
        failureMessage: 'Google verification failed',
      );

      if (data['success'] == true && data['token'] != null) {
        await saveSession(token: data['token'], role: role, email: googleUser.email);
      }
      return {'success': data['success'] == true, 'message': _messageFrom(data, 'Google verification successful')};
    } catch (_) {
      return {
        'success': false,
        'message': 'Google verification failed. Please check Google Client ID setup.',
      };
    }
  }

  static Future<Map<String, dynamic>?> getClientProfile() => _getMap('/client/profile');
  static Future<Map<String, dynamic>?> getOrganizationProfile() => _getMap('/organization/profile');
  static Future<bool> updateClientProfile(Map<String, dynamic> data) => _putJson('/client/profile', data);
  static Future<bool> updateOrganizationProfile(Map<String, dynamic> data) => _putJson('/organization/profile', data);

  static Future<Map<String, dynamic>> uploadProfilePicture({
    required XFile file,
    required String role,
  }) async {
    try {
      final endpoint = role == 'organization'
          ? '/organization/profile/picture'
          : '/client/profile/picture';
      final request = http.MultipartRequest('POST', _uri(endpoint));
      request.headers.addAll(_authHeaders);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          await file.readAsBytes(),
          filename: file.name,
        ),
      );

      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      final data = _decodeMap(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, ...data};
      }
      return {'success': false, 'message': _messageFrom(data, 'Image upload failed')};
    } catch (error) {
      return _networkError(error);
    }
  }

  static Future<List<dynamic>> getNotifications(String receiverType, int receiverId) async {
    final data = await _getMap('/notifications/$receiverType/$receiverId');
    return data?['notifications'] ?? [];
  }

  static Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final response = await http
          .put(_uri('/notifications/read/${Uri.encodeComponent(notificationId)}'), headers: _headers)
          .timeout(_timeout);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  static Future<List<dynamic>> searchServers(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];
    final data = await _getMap('/server/search', {'query': trimmed});
    return data?['results'] ?? [];
  }

  static Future<List<dynamic>> getServersByCategory(String category) async {
    final encodedCategory = Uri.encodeComponent(category);
    final data = await _getMap('/server/category/$encodedCategory');
    return data?['servers'] ?? [];
  }

  static Future<List<dynamic>> getMyServers() async {
    final data = await _getMap('/server/my');
    return data?['servers'] ?? [];
  }

  static Future<Map<String, dynamic>?> getServer(String serverId) {
    return _getMap('/server/${Uri.encodeComponent(serverId)}');
  }

  static Future<Map<String, dynamic>> createServer({
    required String serverName,
    required String category,
    required String sector,
    required String description,
    required String location,
    required String contactNumber,
    required String email,
    required String website,
    String registrationNumber = '',
    String verificationEvidence = '',
  }) async {
    final hasSession = await ensureOrganizationSession();

    if (!hasSession) {
      return {
        'success': false,
        'message': 'Please login as an organization again.',
      };
    }

    final data = await _postJson(
      '/server/create',
      {
        'server_name': serverName,
        'category': category,
        'sector': sector,
        'description': description,
        'location': location,
        'contact_number': contactNumber,
        'email': email,
        'website': website,
        'registration_number': registrationNumber,
        'verification_evidence': verificationEvidence,
      },
      failureMessage: 'Server creation failed',
    );
    return {
      'success': data['success'] == true,
      'message': _messageFrom(data, 'Server created successfully'),
      if (data['server_id'] != null) 'server_id': data['server_id'],
    };
  }

  static Future<Map<String, dynamic>> updateServer({
    required String serverId,
    required String serverName,
    required String category,
    required String sector,
    required String description,
    required String location,
    required String contactNumber,
    required String email,
    required String website,
    String registrationNumber = '',
    String verificationEvidence = '',
  }) async {
    final hasSession = await ensureOrganizationSession();

    if (!hasSession) {
      return {
        'success': false,
        'message': 'Please login as an organization again.',
      };
    }

    final data = await _putJsonMap(
      '/server/${Uri.encodeComponent(serverId)}',
      {
        'server_name': serverName,
        'category': category,
        'sector': sector,
        'description': description,
        'location': location,
        'contact_number': contactNumber,
        'email': email,
        'website': website,
        'registration_number': registrationNumber,
        'verification_evidence': verificationEvidence,
      },
      failureMessage: 'Server update failed',
    );
    return {'success': data['success'] == true, 'message': _messageFrom(data, 'Server updated successfully')};
  }

  static Future<bool> deleteServer(String serverId) async {
    final hasSession = await ensureOrganizationSession();
    if (!hasSession) return false;

    try {
      final response = await http
          .delete(_uri('/server/${Uri.encodeComponent(serverId)}'), headers: _headers)
          .timeout(_timeout);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
