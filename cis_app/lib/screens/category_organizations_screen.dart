import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../routes/app_routes.dart';

class CategoryOrganizationsScreen extends StatefulWidget {
  const CategoryOrganizationsScreen({super.key});

  @override
  State<CategoryOrganizationsScreen> createState() =>
      _CategoryOrganizationsScreenState();
}

class _CategoryOrganizationsScreenState
    extends State<CategoryOrganizationsScreen> {

  String selectedSector = "Government";

  bool _isLoading = true;

  String _categoryTitle = "Organizations";
  bool _hasLoadedServers = false;

  List<dynamic> _servers = [];

  List<dynamic> _filteredServers = [];

  final TextEditingController _searchController =
      TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    final categoryTitle = args is String ? args : "Organizations";

    if (!_hasLoadedServers || _categoryTitle != categoryTitle) {
      _hasLoadedServers = true;
      _categoryTitle = categoryTitle;
      _isLoading = true;
      _loadServers(_categoryTitle);
    }
  }

  Future<void> _loadServers(
    String categoryTitle,
  ) async {

    final data =
        await ApiService.getServersByCategory(
      categoryTitle,
    );

    if (!mounted) return;

    setState(() {
      _servers = data;

      _applyFilter();

      _isLoading = false;
    });
  }

  void _applyFilter() {

    final query = _searchController.text
        .trim()
        .toLowerCase();

    _filteredServers = _servers.where((server) {

      final sectorMatch =
          server["sector"] == selectedSector;

      final searchMatch =
          query.isEmpty ||

              (server["server_name"] ?? "")
                  .toString()
                  .toLowerCase()
                  .contains(query) ||

              (server["description"] ?? "")
                  .toString()
                  .toLowerCase()
                  .contains(query) ||

              (server["location"] ?? "")
                  .toString()
                  .toLowerCase()
                  .contains(query);

      return sectorMatch && searchMatch;

    }).toList();
  }

  void _searchLocalServers(String value) {

    setState(() {
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryTitle = _categoryTitle;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF7F8FA,
      ),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF004D48),

        foregroundColor: Colors.white,

        title: Text(categoryTitle),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // SEARCH BAR
            TextField(
              controller: _searchController,

              textInputAction:
                  TextInputAction.search,

              onChanged:
                  _searchLocalServers,

              decoration: InputDecoration(
                hintText:
                    "Search servers...",

                filled: true,
                fillColor: Colors.white,

                prefixIcon: const Icon(
                  Icons.search_rounded,
                ),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // TYPE TITLE
            const Text(
              "Select Organization Type",

              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            // FILTER BUTTONS
            Row(
              children: [

                Expanded(
                  child: _sectorButton(
                    title: "Government",

                    icon: Icons
                        .account_balance_rounded,

                    isSelected:
                        selectedSector ==
                            "Government",

                    onTap: () {

                      setState(() {

                        selectedSector =
                            "Government";

                        _applyFilter();
                      });
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _sectorButton(
                    title:
                        "Private Sector",

                    icon:
                        Icons.business_rounded,

                    isSelected:
                        selectedSector ==
                            "Private Sector",

                    onTap: () {

                      setState(() {

                        selectedSector =
                            "Private Sector";

                        _applyFilter();
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Text(
              selectedSector ==
                      "Government"
                  ? "Government Organizations"
                  : "Private Sector Organizations",

              style: const TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            // LOADING
            if (_isLoading)
              const Center(
                child:
                    CircularProgressIndicator(),
              )

            // EMPTY
            else if (_filteredServers.isEmpty)

              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),
                ),

                child: const Center(
                  child: Text(
                    "No servers available in this category.",
                  ),
                ),
              )

            // SERVER LIST
            else

              for (final server
                  in _filteredServers)

                _modernServerCard(
                  server: server,
                ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // SERVER CARD
  // ──────────────────────────────────────────────
  Widget _modernServerCard({
    required dynamic server,
  }) {

    final title =
        server["server_name"] ??
            "Unnamed Server";

    final description =
        server["description"] ?? "";

    final location =
        server["location"] ?? "";

    final category =
        server["category"] ?? "";

    final initial = title.toString().trim().isNotEmpty
        ? title.toString().trim().substring(0, 1).toUpperCase()
        : "?";

    return GestureDetector(

      onTap: () {

        Navigator.pushNamed(
          context,
          AppRoutes.serverDetails,
          arguments: server,
        );
      },

      child: Container(
        width: double.infinity,

        margin:
            const EdgeInsets.only(
          bottom: 18,
        ),

        padding:
            const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
            24,
          ),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withValues(
                alpha: 0.05,
              ),

              blurRadius: 10,

              offset: const Offset(
                0,
                4,
              ),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // TOP ROW
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // LOGO
                Container(
                  width: 58,
                  height: 58,

                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xFF7D1031),
                        Color(0xFFE44984),
                      ],
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),

                  child: Center(
                    child: Text(
                      initial,

                      style:
                          const TextStyle(
                        color:
                            Colors.white,

                        fontSize: 22,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // DETAILS
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Text(
                        title,

                        style:
                            const TextStyle(
                          fontSize: 22,

                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        description,

                        maxLines: 2,

                        overflow:
                            TextOverflow
                                .ellipsis,

                        style: TextStyle(
                          fontSize: 14,

                          color:
                              Colors.grey
                                  .shade700,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,

                        children: [

                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal:
                                  12,
                              vertical: 6,
                            ),

                            decoration:
                                BoxDecoration(
                              color: const Color(
                                0xFFF3F3F3,
                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),
                            ),

                            child: Text(
                              category,
                            ),
                          ),

                          Row(
                            mainAxisSize:
                                MainAxisSize
                                    .min,

                            children: [
                              const Icon(
                                Icons
                                    .location_on_outlined,

                                size: 18,

                                color:
                                    Colors
                                        .grey,
                              ),

                              const SizedBox(
                                width: 4,
                              ),

                              Text(
                                location,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Divider(
              color:
                  Colors.grey.shade300,
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                Text(
                  "Business Server",

                  style: TextStyle(
                    color:
                        Colors.grey
                            .shade700,
                  ),
                ),

                const Icon(
                  Icons
                      .arrow_forward_ios_rounded,

                  size: 18,

                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectorButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {

    return SizedBox(
      height: 56,

      child: ElevatedButton.icon(
        onPressed: onTap,

        icon: Icon(
          icon,

          color: isSelected
              ? Colors.white
              : const Color(
                  0xFF004D48,
                ),
        ),

        label: Text(
          title,

          style: TextStyle(
            fontWeight:
                FontWeight.bold,

            color: isSelected
                ? Colors.white
                : const Color(
                    0xFF004D48,
                  ),
          ),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected
                  ? const Color(
                      0xFF7D1031,
                    )
                  : Colors.white,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
        ),
      ),
    );
  }
}