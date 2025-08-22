import 'package:flutter/material.dart';
import '../../../../utils/avicast_header.dart';

class SiteBirdsPage extends StatefulWidget {
  final String siteName;
  
  const SiteBirdsPage({
    super.key,
    required this.siteName,
  });

  @override
  State<SiteBirdsPage> createState() => _SiteBirdsPageState();
}

class _SiteBirdsPageState extends State<SiteBirdsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSortOption = 'A - Z';
  
  // Sample bird data with conservation status and family
  final List<Map<String, dynamic>> _birds = [
    {
      'name': 'Spoon-billed Sandpiper',
      'status': 'CR',
      'statusText': 'Critically Endangered',
      'statusDescription': 'Facing extremely high risk of extinction in the wild',
      'statusColor': Colors.red,
      'family': 'Scolopacidae',
      'scientificName': 'Calidris pygmaea',
      'image': 'assets/images/spoon_billed_sandpiper.jpg',
    },
    {
      'name': 'Chinese Egret',
      'status': 'EN',
      'statusText': 'Endangered',
      'statusDescription': 'Facing very high risk of extinction in the wild',
      'statusColor': const Color(0xFFFF8C00), // Dark orange
      'family': 'Ardeidae',
      'scientificName': 'Egretta eulophotes',
      'image': 'assets/images/chinese_egret.jpg',
    },
    {
      'name': 'Black-faced Spoonbill',
      'status': 'VU',
      'statusText': 'Vulnerable',
      'statusDescription': 'Facing high risk of extinction in the wild',
      'statusColor': const Color(0xFFFFD700), // Gold/yellow
      'family': 'Threskiornithidae',
      'scientificName': 'Platalea minor',
      'image': 'assets/images/black_faced_spoonbill.jpg',
    },
    {
      'name': "Baer's Pochard",
      'status': 'CR',
      'statusText': 'Critically Endangered',
      'statusDescription': 'Facing extremely high risk of extinction in the wild',
      'statusColor': Colors.red,
      'family': 'Anatidae',
      'scientificName': 'Aythya baeri',
      'image': 'assets/images/baers_pochard.jpg',
    },
    {
      'name': 'Far Eastern Curlew',
      'status': 'EN',
      'statusText': 'Endangered',
      'statusDescription': 'Facing very high risk of extinction in the wild',
      'statusColor': const Color(0xFFFF8C00), // Dark orange
      'family': 'Scolopacidae',
      'scientificName': 'Numenius madagascariensis',
      'image': 'assets/images/far_eastern_curlew.jpg',
    },
    {
      'name': 'Whiskered Tern',
      'status': 'LC',
      'statusText': 'Least Concern',
      'statusDescription': 'Widespread and abundant, not at risk',
      'statusColor': const Color(0xFF90EE90), // Light green
      'family': 'Laridae',
      'scientificName': 'Chlidonias hybrida',
      'image': 'assets/images/whiskered_tern.jpg',
    },
    {
      'name': 'Barn Swallow',
      'status': 'LC',
      'statusText': 'Least Concern',
      'statusDescription': 'Widespread and abundant, not at risk',
      'statusColor': const Color(0xFF90EE90), // Light green
      'family': 'Hirundinidae',
      'scientificName': 'Hirundo rustica',
      'image': 'assets/images/barn_swallow.jpg',
    },
    {
      'name': 'Peregrine Falcon',
      'status': 'LC',
      'statusText': 'Least Concern',
      'statusDescription': 'Widespread and abundant, not at risk',
      'statusColor': const Color(0xFF90EE90), // Light green
      'family': 'Falconidae',
      'scientificName': 'Falco peregrinus',
      'image': 'assets/images/peregrine_falcon.jpg',
    },
    {
      'name': 'Great Knot',
      'status': 'EN',
      'statusText': 'Endangered',
      'statusDescription': 'Facing very high risk of extinction in the wild',
      'statusColor': const Color(0xFFFF8C00), // Dark orange
      'family': 'Scolopacidae',
      'scientificName': 'Calidris tenuirostris',
      'image': 'assets/images/great_knot.jpg',
    },
    {
      'name': 'Nordmann\'s Greenshank',
      'status': 'NT',
      'statusText': 'Near Threatened',
      'statusDescription': 'Close to qualifying for threatened status',
      'statusColor': const Color(0xFFFFA500), // Orange
      'family': 'Scolopacidae',
      'scientificName': 'Tringa guttifer',
      'image': 'assets/images/nordmanns_greenshank.jpg',
    },
    {
      'name': 'Common Redshank',
      'status': 'LC',
      'statusText': 'Least Concern',
      'statusDescription': 'Widespread and abundant, not at risk',
      'statusColor': const Color(0xFF90EE90), // Light green
      'family': 'Scolopacidae',
      'scientificName': 'Tringa totanus',
      'image': 'assets/images/common_redshank.jpg',
    },
    {
      'name': 'Saunders\'s Gull',
      'status': 'VU',
      'statusText': 'Vulnerable',
      'statusDescription': 'Facing high risk of extinction in the wild',
      'statusColor': const Color(0xFFFFD700), // Gold/yellow
      'family': 'Laridae',
      'scientificName': 'Saundersilarus saundersi',
      'image': 'assets/images/saunders_gull.jpg',
    },
    {
      'name': 'Oriental Stork',
      'status': 'EN',
      'statusText': 'Endangered',
      'statusDescription': 'Facing very high risk of extinction in the wild',
      'statusColor': const Color(0xFFFF8C00), // Dark orange
      'family': 'Ciconiidae',
      'scientificName': 'Ciconia boyciana',
      'image': 'assets/images/oriental_stork.jpg',
    },
    {
      'name': 'Red-crowned Crane',
      'status': 'VU',
      'statusText': 'Vulnerable',
      'statusDescription': 'Facing high risk of extinction in the wild',
      'statusColor': const Color(0xFFFFD700), // Gold/yellow
      'family': 'Gruidae',
      'scientificName': 'Grus japonensis',
      'image': 'assets/images/red_crowned_crane.jpg',
    },
    {
      'name': 'Chinese Crested Tern',
      'status': 'DD',
      'statusText': 'Data Deficient',
      'statusDescription': 'Insufficient data to assess conservation status',
      'statusColor': Colors.grey,
      'family': 'Laridae',
      'scientificName': 'Thalasseus bernsteini',
      'image': 'assets/images/chinese_crested_tern.jpg',
    },
  ];

  List<Map<String, dynamic>> get _filteredBirds {
    final searchQuery = _searchController.text.toLowerCase();
    var filtered = _birds.where((bird) => 
      bird['name'].toLowerCase().contains(searchQuery)
    ).toList();
    
    // Sort birds based on selected option
    switch (_selectedSortOption) {
      case 'A - Z':
        filtered.sort((a, b) => a['name'].compareTo(b['name']));
        break;
      case 'Family':
        filtered.sort((a, b) => a['family'].compareTo(b['family']));
        break;
      case 'IUCN Status':
        // Sort by IUCN status priority: CR > EN > VU > NT > LC > DD
        final statusPriority = {'CR': 1, 'EN': 2, 'VU': 3, 'NT': 4, 'LC': 5, 'DD': 6};
        filtered.sort((a, b) {
          final aPriority = statusPriority[a['status']] ?? 7;
          final bPriority = statusPriority[b['status']] ?? 7;
          return aPriority.compareTo(bPriority);
        });
        break;
    }
    
    return filtered;
  }

  void _showIUCNStatusInfo(Map<String, dynamic> bird) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bird['statusColor'],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  bird['status'],
                  style: TextStyle(
                    color: bird['status'] == 'VU' || bird['status'] == 'LC' 
                        ? Colors.black 
                        : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                bird['statusText'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bird['statusDescription'],
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'IUCN Red List Categories:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildIUCNCategoryInfo('CR', 'Critically Endangered', Colors.red, 'Facing extremely high risk of extinction'),
              _buildIUCNCategoryInfo('EN', 'Endangered', const Color(0xFFFF8C00), 'Facing very high risk of extinction'),
              _buildIUCNCategoryInfo('VU', 'Vulnerable', const Color(0xFFFFD700), 'Facing high risk of extinction'),
              _buildIUCNCategoryInfo('NT', 'Near Threatened', const Color(0xFFFFA500), 'Close to qualifying for threatened status'),
              _buildIUCNCategoryInfo('LC', 'Least Concern', const Color(0xFF90EE90), 'Widespread and abundant, not at risk'),
              _buildIUCNCategoryInfo('DD', 'Data Deficient', Colors.grey, 'Insufficient data to assess conservation status'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIUCNCategoryInfo(String code, String name, Color color, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
                              child: Text(
                  code,
                  style: TextStyle(
                    color: code == 'VU' || code == 'LC' || code == 'DD' ? Colors.black : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sort by'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('A - Z'),
                leading: Radio<String>(
                  value: 'A - Z',
                  groupValue: _selectedSortOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedSortOption = value!;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: const Text('Family'),
                leading: Radio<String>(
                  value: 'Family',
                  groupValue: _selectedSortOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedSortOption = value!;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: const Text('IUCN Status'),
                leading: Radio<String>(
                  value: 'IUCN Status',
                  groupValue: _selectedSortOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedSortOption = value!;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // Light blue
              Color(0xFFB0E0E6), // Powder blue
              Colors.white,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
        child: Column(
          children: [
            // AVICAST Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: AvicastHeader(
                pageTitle: widget.siteName.toUpperCase(),
                showPageTitle: true,
              ),
            ),
            
            // Search and sort section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Search bar
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: 'Search birds...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Sort button
                  GestureDetector(
                    onTap: _showSortOptions,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00897B),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00897B).withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sort,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Sort',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Birds list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _filteredBirds.length,
                itemBuilder: (context, index) {
                  final bird = _filteredBirds[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to bird counter page
                      Navigator.of(context).pushNamed(
                        '/bird-counter',
                        arguments: {
                          'birdName': bird['name'],
                          'birdData': bird,
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                          // Bird image placeholder
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!, width: 1),
                            ),
                            child: Icon(
                              Icons.photo_camera,
                              color: Colors.grey[500],
                              size: 28,
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Bird information
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Bird name
                                Text(
                                  bird['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                
                                const SizedBox(height: 4),
                                
                                // Scientific name
                                Text(
                                  bird['scientificName'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                
                                const SizedBox(height: 6),
                                
                                // Family
                                Text(
                                  'Family: ${bird['family']}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Status information
                                Row(
                                  children: [
                                    // Status badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: bird['statusColor'],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        bird['status'],
                                        style: TextStyle(
                                          color: bird['status'] == 'VU' || bird['status'] == 'LC' || bird['status'] == 'DD'
                                              ? Colors.black 
                                              : Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 8),
                                    
                                    // Status text with info icon
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _showIUCNStatusInfo(bird),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                bird['statusText'],
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.info_outline,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Arrow icon
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF2C3E50),
                            size: 16,
                          ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFF87CEEB), // Light blue navigation bar
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Document icon (left)
            IconButton(
              icon: const Icon(
                Icons.description,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/notes');
              },
            ),
            
            // Bird icon (center) - Floating action button style
            Container(
              width: 70,
              height: 70,
              margin: const EdgeInsets.only(bottom: 20), // Overlap the top edge
              decoration: BoxDecoration(
                color: const Color(0xFF87CEEB), // Light blue background
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.flutter_dash,
                color: Colors.white,
                size: 36,
              ),
            ),
            
            // Camera icon (right)
            IconButton(
              icon: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/camera');
              },
            ),
          ],
        ),
      ),
    );
  }
} 