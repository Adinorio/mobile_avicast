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
      'statusColor': Colors.red,
      'family': 'Scolopacidae',
      'scientificName': 'Calidris pygmaea',
      'image': 'assets/images/spoon_billed_sandpiper.jpg',
    },
    {
      'name': 'Chinese Egret',
      'status': 'EN',
      'statusText': 'Endangered',
      'statusColor': const Color(0xFFFF8C00), // Dark orange
      'family': 'Ardeidae',
      'scientificName': 'Egretta eulophotes',
      'image': 'assets/images/chinese_egret.jpg',
    },
    {
      'name': 'Black-faced Spoonbill',
      'status': 'VU',
      'statusText': 'Vulnerable',
      'statusColor': const Color(0xFFFFD700), // Gold/yellow
      'family': 'Threskiornithidae',
      'scientificName': 'Platalea minor',
      'image': 'assets/images/black_faced_spoonbill.jpg',
    },
    {
      'name': "Baer's Pochard",
      'status': 'CR',
      'statusText': 'Critically Endangered',
      'statusColor': Colors.red,
      'family': 'Anatidae',
      'scientificName': 'Aythya baeri',
      'image': 'assets/images/baers_pochard.jpg',
    },
    {
      'name': 'Far Eastern Curlew',
      'status': 'EN',
      'statusText': 'Endangered',
      'statusColor': const Color(0xFFFF8C00), // Dark orange
      'family': 'Scolopacidae',
      'scientificName': 'Numenius madagascariensis',
      'image': 'assets/images/far_eastern_curlew.jpg',
    },
    {
      'name': 'Whiskered Tern',
      'status': 'LC',
      'statusText': 'Least Concern',
      'statusColor': const Color(0xFF90EE90), // Light green
      'family': 'Laridae',
      'scientificName': 'Chlidonias hybrida',
      'image': 'assets/images/whiskered_tern.jpg',
    },
    {
      'name': 'Barn Swallow',
      'status': 'LC',
      'statusText': 'Least Concern',
      'statusColor': const Color(0xFF90EE90), // Light green
      'family': 'Hirundinidae',
      'scientificName': 'Hirundo rustica',
      'image': 'assets/images/barn_swallow.jpg',
    },
    {
      'name': 'Peregrine Falcon',
      'status': 'LC',
      'statusText': 'Least Concern',
      'statusColor': const Color(0xFF90EE90), // Light green
      'family': 'Falconidae',
      'scientificName': 'Falco peregrinus',
      'image': 'assets/images/peregrine_falcon.jpg',
    },
    {
      'name': 'Great Knot',
      'status': 'EN',
      'statusText': 'Endangered',
      'statusColor': const Color(0xFFFF8C00), // Dark orange
      'family': 'Scolopacidae',
      'scientificName': 'Calidris tenuirostris',
      'image': 'assets/images/great_knot.jpg',
    },
    {
      'name': 'Nordmann\'s Greenshank',
      'status': 'NT',
      'statusText': 'Near Threatened',
      'statusColor': const Color(0xFFFFA500), // Orange
      'family': 'Scolopacidae',
      'scientificName': 'Tringa guttifer',
      'image': 'assets/images/nordmanns_greenshank.jpg',
    },
    {
      'name': 'Common Redshank',
      'status': 'LC',
      'statusText': 'Least Concern',
      'statusColor': const Color(0xFF90EE90), // Light green
      'family': 'Scolopacidae',
      'scientificName': 'Tringa totanus',
      'image': 'assets/images/common_redshank.jpg',
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
        // Sort by IUCN status priority: CR > EN > VU > NT > LC
        final statusPriority = {'CR': 1, 'EN': 2, 'VU': 3, 'NT': 4, 'LC': 5};
        filtered.sort((a, b) {
          final aPriority = statusPriority[a['status']] ?? 6;
          final bPriority = statusPriority[b['status']] ?? 6;
          return aPriority.compareTo(bPriority);
        });
        break;
    }
    
    return filtered;
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
      backgroundColor: Colors.white,
      body: SafeArea(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  // Search bar
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 15),
                  
                  // Sort button
                  GestureDetector(
                    onTap: _showSortOptions,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34495E),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Sort by',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey[300],
                            size: 20,
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: _filteredBirds.length,
                itemBuilder: (context, index) {
                  final bird = _filteredBirds[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4FD),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.image,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                      title: Text(
                        bird['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            bird['family'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
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
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF2C3E50),
                        size: 16,
                      ),
                      onTap: () {
                        // Navigate to bird counter page
                        Navigator.of(context).pushNamed(
                          '/bird-counter',
                          arguments: {
                            'birdName': bird['name'],
                            'birdImage': bird['image'],
                            'birdStatus': bird['status'],
                            'birdFamily': bird['family'],
                            'birdScientificName': bird['scientificName'],
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
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
                // TODO: Implement camera functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Camera feature coming soon!'),
                    backgroundColor: Color(0xFF667eea),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 