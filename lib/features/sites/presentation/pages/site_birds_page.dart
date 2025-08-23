import 'package:flutter/material.dart';
import '../../../../utils/avicast_header.dart';
import '../../../../utils/theme.dart';
import '../../data/services/sites_database_service.dart';

class SiteBirdsPage extends StatefulWidget {
  final String siteName;
  
  const SiteBirdsPage({
    super.key,
    required this.siteName,
  });

  @override
  State<SiteBirdsPage> createState() => _SiteBirdsPageState();
}

class _SiteBirdsPageState extends State<SiteBirdsPage> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSortOption = 'A - Z';
  final SitesDatabaseService _databaseService = SitesDatabaseService();
  List<BirdCount> _savedCounts = [];
  
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
      'image': 'assets/images/birds/spoon_billed_sandpiper.jpg',
    },
    {
      'name': 'Chinese Egret',
      'status': 'EN',
      'statusText': 'Endangered',
      'statusDescription': 'Facing very high risk of extinction in the wild',
      'statusColor': const Color(0xFFFF8C00), // Dark orange
      'family': 'Ardeidae',
      'scientificName': 'Egretta eulophotes',
      'image': 'assets/images/birds/chinese_egret.jpg',
    },
    {
      'name': 'Black-faced Spoonbill',
      'status': 'VU',
      'statusText': 'Vulnerable',
      'statusDescription': 'Facing high risk of extinction in the wild',
      'statusColor': const Color(0xFFFFD700), // Gold/yellow
      'family': 'Threskiornithidae',
      'scientificName': 'Platalea minor',
      'image': 'assets/images/birds/black_faced_spoonbill.jpg',
    },
    {
      'name': "Baer's Pochard",
      'status': 'CR',
      'statusText': 'Critically Endangered',
      'statusDescription': 'Facing extremely high risk of extinction in the wild',
      'statusColor': Colors.red,
      'family': 'Anatidae',
      'scientificName': 'Aythya baeri',
      'image': 'assets/images/birds/baers_pochard.jpg',
    },
    {
      'name': 'Far Eastern Curlew',
      'status': 'EN',
      'statusText': 'Endangered',
      'statusDescription': 'Facing very high risk of extinction in the wild',
      'statusColor': const Color(0xFFFF8C00), // Dark orange
      'family': 'Scolopacidae',
      'scientificName': 'Numenius madagascariensis',
      'image': 'assets/images/birds/far_eastern_curlew.jpg',
    },
    {
      'name': 'Whiskered Tern',
      'status': 'LC',
      'statusText': 'Least Concern',
      'statusDescription': 'Species is not currently at risk of extinction',
      'statusColor': Colors.green,
      'family': 'Laridae',
      'scientificName': 'Chlidonias hybrida',
      'image': 'assets/images/birds/whiskered_tern.jpg',
    },
    {
      'name': 'Barn Swallow',
      'status': 'LC',
      'statusText': 'Least Concern',
      'statusDescription': 'Species is not currently at risk of extinction',
      'statusColor': Colors.green,
      'family': 'Hirundinidae',
      'scientificName': 'Hirundo rustica',
      'image': 'assets/images/birds/barn_swallow.jpg',
    },
    {
      'name': 'Peregrine Falcon',
      'status': 'LC',
      'statusText': 'Least Concern',
      'statusDescription': 'Species is not currently at risk of extinction',
      'statusColor': Colors.green,
      'family': 'Falconidae',
      'scientificName': 'Falco peregrinus',
      'image': 'assets/images/birds/peregrine_falcon.jpg',
    },
    {
      'name': 'Great Knot',
      'status': 'EN',
      'statusText': 'Endangered',
      'statusDescription': 'Facing very high risk of extinction in the wild',
      'statusColor': const Color(0xFFFF8C00), // Dark orange
      'family': 'Scolopacidae',
      'scientificName': 'Calidris tenuirostris',
      'image': 'assets/images/birds/great_knot.jpg',
    },
    {
      'name': "Nordmann's Greenshank",
      'status': 'EN',
      'statusText': 'Endangered',
      'statusDescription': 'Facing very high risk of extinction in the wild',
      'statusColor': const Color(0xFFFF8C00), // Dark orange
      'family': 'Scolopacidae',
      'scientificName': 'Tringa guttifer',
      'image': 'assets/images/birds/nordmanns_greenshank.jpg',
    },
    {
      'name': 'Common Redshank',
      'status': 'LC',
      'statusText': 'Least Concern',
      'statusDescription': 'Species is not currently at risk of extinction',
      'statusColor': Colors.green,
      'family': 'Scolopacidae',
      'scientificName': 'Tringa totanus',
      'image': 'assets/images/birds/common_redshank.jpg',
    },
    {
      'name': "Saunders's Gull",
      'status': 'VU',
      'statusText': 'Vulnerable',
      'statusDescription': 'Facing high risk of extinction in the wild',
      'statusColor': const Color(0xFFFFD700), // Gold/yellow
      'family': 'Laridae',
      'scientificName': 'Saundersilarus saundersi',
      'image': 'assets/images/birds/saunderss_gull.jpg',
    },
    {
      'name': 'Oriental Stork',
      'status': 'EN',
      'statusText': 'Endangered',
      'statusDescription': 'Facing very high risk of extinction in the wild',
      'statusColor': const Color(0xFFFF8C00), // Dark orange
      'family': 'Ciconiidae',
      'scientificName': 'Ciconia boyciana',
      'image': 'assets/images/birds/oriental_stork.jpg',
    },
    {
      'name': 'Red-crowned Crane',
      'status': 'VU',
      'statusText': 'Vulnerable',
      'statusDescription': 'Facing high risk of extinction in the wild',
      'statusColor': const Color(0xFFFFD700), // Gold/yellow
      'family': 'Gruidae',
      'scientificName': 'Grus japonensis',
      'image': 'assets/images/birds/red_crowned_crane.jpg',
    },
    {
      'name': 'Chinese Crested Tern',
      'status': 'CR',
      'statusText': 'Critically Endangered',
      'statusDescription': 'Facing extremely high risk of extinction in the wild',
      'statusColor': Colors.red,
      'family': 'Laridae',
      'scientificName': 'Thalasseus bernsteini',
      'image': 'assets/images/birds/chinese_crested_tern.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedCounts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh counts when app becomes active
      _loadSavedCounts();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh counts when dependencies change (e.g., when returning to this page)
    _loadSavedCounts();
  }

  Future<void> _loadSavedCounts() async {
    try {
      final sites = await _databaseService.getAllSites();
      final currentSite = sites.firstWhere((site) => site.name == widget.siteName);
      setState(() {
        _savedCounts = currentSite.birdCounts;
      });
    } catch (e) {
      setState(() {
        _savedCounts = [];
      });
    }
  }

  List<Map<String, dynamic>> get _filteredBirds {
    final searchTerm = _searchController.text.toLowerCase();
    List<Map<String, dynamic>> filtered = _birds.where((bird) {
      return bird['name'].toLowerCase().contains(searchTerm) ||
             bird['scientificName'].toLowerCase().contains(searchTerm) ||
             bird['family'].toLowerCase().contains(searchTerm);
    }).toList();

    // Apply sorting
    switch (_selectedSortOption) {
      case 'A - Z':
        filtered.sort((a, b) => a['name'].compareTo(b['name']));
        break;
      case 'Z - A':
        filtered.sort((a, b) => b['name'].compareTo(a['name']));
        break;
      case 'Status':
        filtered.sort((a, b) => _getStatusPriority(a['status']).compareTo(_getStatusPriority(b['status'])));
        break;
      case 'Family':
        filtered.sort((a, b) => a['family'].compareTo(b['family']));
        break;
    }

    return filtered;
  }

  int _getStatusPriority(String status) {
    switch (status) {
      case 'CR': return 1; // Critically Endangered
      case 'EN': return 2; // Endangered
      case 'VU': return 3; // Vulnerable
      case 'NT': return 4; // Near Threatened
      case 'LC': return 5; // Least Concern
      default: return 6;
    }
  }

  int _getBirdCount(String birdName) {
    return _savedCounts
        .where((count) => count.birdName == birdName)
        .fold(0, (sum, count) => sum + count.count);
  }

  String _getLastCountDate(String birdName) {
    final counts = _savedCounts.where((count) => count.birdName == birdName).toList();
    if (counts.isEmpty) return '';
    
    counts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final lastCount = counts.first.timestamp;
    
    final now = DateTime.now();
    final difference = now.difference(lastCount);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToBirdCounter(Map<String, dynamic> bird) {
    Navigator.of(context).pushNamed(
      '/bird-counter',
      arguments: {
        'birdName': bird['name'],
        'birdImage': bird['image'],
        'birdStatus': bird['status'],
        'birdFamily': bird['family'],
        'birdScientificName': bird['scientificName'],
        'siteName': widget.siteName,
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
              AppTheme.avicastBlue, // Light blue
              AppTheme.avicastLightBlue, // Powder blue
              Colors.white,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
        child: Column(
          children: [
            // AVICAST Header
            AvicastHeader(
              pageTitle: '📍 ${widget.siteName}',
              showPageTitle: true,
            ),
            
            
            
            // Search and filter section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search by name, scientific name, or family...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Sort options
                  Row(
                    children: [
                      const Text(
                        'Sort by: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              'A - Z',
                              'Z - A',
                              'Status',
                              'Family',
                            ].map((option) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(option),
                                selected: _selectedSortOption == option,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedSortOption = option;
                                    });
                                  }
                                },
                                                                  selectedColor: AppTheme.successColor,
                                labelStyle: TextStyle(
                                  color: _selectedSortOption == option ? Colors.white : Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Species list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _filteredBirds.length,
                itemBuilder: (context, index) {
                  final bird = _filteredBirds[index];
                  final birdCount = _getBirdCount(bird['name']);
                  final lastCountDate = _getLastCountDate(bird['name']);
                  
                  return GestureDetector(
                    onTap: () => _navigateToBirdCounter(bird),
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
                          // Bird image
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildBirdImage(bird['image']),
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                
                                const SizedBox(height: 4),
                                
                                // Scientific name in parentheses
                                Text(
                                  '(${bird['scientificName']})',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Family in highlighted box
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE3F2FD),
                                    borderRadius: BorderRadius.circular(8),
                                                                          border: Border.all(color: AppTheme.infoColor),
                                  ),
                                  child: Text(
                                    bird['family'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                                                              color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Conservation status
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: bird['statusColor'].withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: bird['statusColor']),
                                      ),
                                      child: Text(
                                        bird['status'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: bird['statusColor'],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        bird['statusText'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Count information
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (birdCount > 0) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                                                          color: AppTheme.successColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$birdCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lastCountDate,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '0',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'No counts',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ]),
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
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Refresh button (icon only)
          FloatingActionButton(
            onPressed: () => _loadSavedCounts(),
            backgroundColor: AppTheme.avicastBlue,
            foregroundColor: AppTheme.textPrimaryColor,
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 16),
          // View Summary button
          FloatingActionButton.extended(
            onPressed: _showCountsSummary,
            icon: const Icon(Icons.analytics),
            label: const Text('View Summary'),
            backgroundColor: AppTheme.successColor,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  void _showCountsSummary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCountsSummarySheet(),
    );
  }

  Widget _buildCountsSummarySheet() {
    final totalCounts = _savedCounts.length;
    final totalBirds = _savedCounts.fold<int>(0, (sum, count) => sum + count.count);
    final uniqueBirds = _savedCounts.map((count) => count.birdName).toSet().length;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header with progress indicator
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, color: AppTheme.successColor, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Review & Submit All Counts',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress steps
                Row(
                  children: [
                    Expanded(
                      child: _buildProgressStep('Site Info', 1, true),
                    ),
                    Expanded(
                      child: _buildProgressStep('Count Data', 2, true),
                    ),
                    Expanded(
                      child: _buildProgressStep('Confirm', 3, false),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Review Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Site Information Review
                  _buildReviewSection(
                    '📍 Site Information',
                    Icons.location_on,
                    AppTheme.infoColor,
                    [
                      _buildReviewItem('Site Name', widget.siteName, Icons.place),
                      _buildReviewItem('Total Counts', '$totalCounts', Icons.list_alt),
                      _buildReviewItem('Survey Date', _getCurrentDate(), Icons.calendar_today),
                      _buildReviewItem('Species Count', '$uniqueBirds', Icons.category),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Section 2: Count Data Review
                  _buildReviewSection(
                    '🦅 Count Data Summary',
                    Icons.analytics,
                    AppTheme.successColor,
                    [
                      _buildReviewItem('Total Counts', '$totalCounts', Icons.list_alt),
                      _buildReviewItem('Total Birds', '$totalBirds', Icons.flutter_dash),
                      _buildReviewItem('Average per Count', '${(totalBirds / totalCounts).toStringAsFixed(1)}', Icons.trending_up),
                      _buildReviewItem('Data Quality', 'High', Icons.verified),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Section 3: Recent Counts Preview
                  if (_savedCounts.isNotEmpty) ...[
                    _buildReviewSection(
                      '📊 Recent Counts',
                      Icons.history,
                      AppTheme.primaryColor,
                      [_buildRecentCountsPreview()],
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
          
          const Divider(height: 1),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Data'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppTheme.avicastBlue),
                      foregroundColor: AppTheme.avicastBlue,
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _confirmAndSubmitAll,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Submit All Counts'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String title, int step, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? AppTheme.successColor : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.circle,
            color: isCompleted ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isCompleted ? AppTheme.successColor : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(String title, IconData icon, Color color, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCountsPreview() {
    final recentCounts = _savedCounts.take(5).toList();
    
    return Column(
      children: recentCounts.map((count) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(
                count.birdName == 'General Count' ? Icons.nature_people : Icons.flutter_dash,
                color: AppTheme.successColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count.birdName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      'Count: ${count.count} • ${_formatTimestamp(count.timestamp)}',
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
      }).toList(),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  void _confirmAndSubmitAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: const Text(
          'Are you sure you want to submit all counts? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSubmissionSuccess();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showSubmissionSuccess() {
    Navigator.of(context).pop(); // Close review sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ All counts submitted successfully!'),
        backgroundColor: AppTheme.successColor,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildBirdImage(String imagePath) {
    if (imagePath.isNotEmpty) {
      return Image.asset(
        imagePath,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Icon(
        Icons.photo_camera,
        size: 24,
        color: Colors.grey[600],
      ),
    );
  }
} 