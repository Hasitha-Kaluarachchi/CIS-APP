class Validators {
  // ──────────────────────────────────────────────
  // EMAIL VALIDATION
  // Checks whether user entered a proper email format.
  // Example valid email: user@gmail.com
  // ──────────────────────────────────────────────
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }

    final emailRegex = RegExp(
      r'^[\w\.-]+@[\w\.-]+\.\w{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return "Invalid email format. Please enter a valid email address.";
    }

    return null;
  }

  // ──────────────────────────────────────────────
  // PASSWORD VALIDATION
  // Password must have at least 6 characters.
  // ──────────────────────────────────────────────
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }

    if (value.length < 6) {
      return "Password must be at least 6 characters.";
    }

    return null;
  }

  // ──────────────────────────────────────────────
  // NAME VALIDATION
  // Prevents empty names and numbers-only names.
  // ──────────────────────────────────────────────
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required";
    }

    if (RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return "Name cannot contain only numbers.";
    }

    return null;
  }

  // ──────────────────────────────────────────────
  // PHONE VALIDATION
  // Allows Sri Lankan style numbers and general numbers.
  // Example: 0712345678
  // ──────────────────────────────────────────────
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // optional field
    }

    final phoneRegex = RegExp(r'^[0-9+]{9,15}$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return "Invalid phone number. Please enter a valid number.";
    }

    return null;
  }

  // ──────────────────────────────────────────────
  // REQUIRED FIELD VALIDATION
  // Use for address, service, website, etc.
  // ──────────────────────────────────────────────
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required";
    }

    return null;
  }

  // ──────────────────────────────────────────────
  // WEBSITE VALIDATION
  // Allows empty website, but validates if user enters one.
  // ──────────────────────────────────────────────
  static String? website(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // optional field
    }

    final websiteRegex = RegExp(
      r'^(https?:\/\/)?([\w\-]+\.)+[\w\-]{2,}(\/.*)?$',
    );

    if (!websiteRegex.hasMatch(value.trim())) {
      return "Invalid website format. Example: www.example.com";
    }

    return null;
  }
}