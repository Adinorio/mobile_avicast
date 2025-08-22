import 'package:flutter/material.dart';
import '../../../../utils/avicast_header.dart';
import '../../../sites/data/services/sites_database_service.dart';
import '../widgets/scrollable_counter.dart';
import '../../data/services/offline_bird_api_service.dart';

class BirdCounterPage extends StatefulWidget {
  final String birdName;
  final String birdImage;
  final String birdStatus;
  final String birdFamily;
  final String birdScientificName;
  final String siteName;
  
  const BirdCounterPage({
    super.key,
    required this.birdName,
    required this.birdImage,
    required this.birdStatus,
    required this.birdFamily,
    required this.birdScientificName,
    required this.siteName,
  });

  @override
  State<BirdCounterPage> createState() => _BirdCounterPageState();
}

class _BirdCounterPageState extends State<BirdCounterPage> {
  int _count = 0;
  final TextEditingController _nameController = TextEditingController();
  String? _observerName;
  final SitesDatabaseService _databaseService = SitesDatabaseService();
  final OfflineBirdApiService _birdApiService = OfflineBirdApiService();
  Map<String, dynamic>? _birdInfo;
  
  // Count history for tracking all count changes
  final List<int> _countHistory = [];
  


  @override
  void initState() {
    super.initState();
    _loadBirdInfo();
  }

  void _loadBirdInfo() {
    _birdInfo = _birdApiService.getBirdInfo(widget.birdName);
  }

  void _addToHistory(int count) {
    _countHistory.add(count);
    
    // Keep only last 20 entries
    if (_countHistory.length > 20) {
      _countHistory.removeAt(0);
    }
  }



  void _exportCountData() {
    final data = {
      'bird_name': widget.birdName,
      'count': _count,
      'timestamp': DateTime.now().toIso8601String(),
      'observer_name': _observerName ?? 'Unknown',
      'site_name': widget.siteName,
    };
    
    // In a real app, you'd export this data
    // For now, we'll show it in a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Count Data Export'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bird: ${data['bird_name']}'),
            Text('Count: ${data['count']}'),
            Text('Time: ${data['timestamp']}'),
            Text('Observer: ${data['observer_name']}'),
            Text('Site: ${data['site_name']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Helper methods for IUCN status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'CR':
        return Colors.red;
      case 'EN':
        return const Color(0xFFFF8C00); // Dark orange
      case 'VU':
        return const Color(0xFFFFD700); // Gold/yellow
      case 'NT':
        return const Color(0xFFFFA500); // Orange
      case 'LC':
        return const Color(0xFF90EE90); // Light green
      case 'DD':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusTextColor(String status) {
    return status == 'VU' || status == 'LC' || status == 'DD' ? Colors.black : Colors.white;
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'CR':
        return 'Critically Endangered';
      case 'EN':
        return 'Endangered';
      case 'VU':
        return 'Vulnerable';
      case 'NT':
        return 'Near Threatened';
      case 'LC':
        return 'Least Concern';
      case 'DD':
        return 'Data Deficient';
      default:
        return 'Unknown';
    }
  }

  void _showIUCNStatusInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.birdStatus),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.birdStatus,
                  style: TextStyle(
                    color: _getStatusTextColor(widget.birdStatus),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _getStatusDescription(widget.birdStatus),
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
                _getStatusDescription(widget.birdStatus),
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



  void _showSaveConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End and Save Count?'),
          content: Text('Do you want to save the count of $_count ${widget.birdName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Observer name is now optional, use empty string if not provided
                final observerName = _observerName?.trim() ?? '';

                try {
                  // Get all sites to find the current site
                  final sites = await _databaseService.getAllSites();
                  final currentSite = sites.firstWhere((site) => site.name == widget.siteName);
                  
                  // Create bird count record
                  final birdCount = BirdCount(
                    birdName: widget.birdName,
                    birdFamily: widget.birdFamily,
                    birdScientificName: widget.birdScientificName,
                    birdStatus: widget.birdStatus,
                    count: _count,
                    timestamp: DateTime.now(),
                    observerName: observerName,
                  );
                  
                  // Save to database
                  await _databaseService.addBirdCount(currentSite.id, birdCount);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Count of $_count ${widget.birdName} saved successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  Navigator.of(context).pop(); // Close dialog
                  
                  // Log out and go to login page
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving count: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF87CEEB),
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AVICAST Header
                AvicastHeader(
                  pageTitle: 'Count ${widget.birdName}',
                  showPageTitle: true,
                ),
                
                const SizedBox(height: 30),
                
                // Bird information section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF87CEEB),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Bird Name label and value
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bird Name:',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.birdName,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Scientific name
                          Text(
                            '(${widget.birdScientificName})',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      
                      // Family and IUCN Status positioned on the right
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Family:',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.birdFamily,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            Text(
                              'IUCN Status:',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Status code badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(widget.birdStatus),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.birdStatus,
                                    style: TextStyle(
                                      color: _getStatusTextColor(widget.birdStatus),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Full status description with tooltip
                                GestureDetector(
                                  onTap: () => _showIUCNStatusInfo(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _getStatusDescription(widget.birdStatus),
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        textAlign: TextAlign.end,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.info_outline,
                                        size: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Counter section
                Column(
                  children: [
                    // COUNT label
                    const Text(
                      'COUNT',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // Scrollable Counter
                    ScrollableCounter(
                      initialValue: _count,
                      value: _count, // Pass current count to sync
                      onValueChanged: (value) {
                        setState(() {
                          _count = value;
                        });
                        _addToHistory(value);
                      },
                      minValue: 0,
                      maxValue: 999,
                    ),
                    
                    const SizedBox(height: 20),

                    
                    const SizedBox(height: 30),
                    
                                        // Action buttons row
                    Row(
                      children: [
                        // Export Count button (green)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _exportCountData,
                            icon: const Icon(
                              Icons.download,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Export',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 15),
                        
                        // Save Count button (white with black text)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showSaveConfirmation,
                            icon: const Icon(
                              Icons.save,
                              color: Colors.black87,
                            ),
                            label: const Text(
                              'Save Count',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Color(0xFF87CEEB),
                                  width: 2,
                                ),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                  ],
                                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Count History Display
                    if (_countHistory.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.history,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Count History (${_countHistory.length} entries)',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 40,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _countHistory.length,
                                itemBuilder: (context, index) {
                                  final isCurrent = _countHistory[index] == _count;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _count = _countHistory[index];
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isCurrent ? Colors.blue[600] : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isCurrent ? Colors.blue[800]! : Colors.grey[400]!,
                                          width: isCurrent ? 2 : 1,
                                        ),
                                      ),
                                      child: Text(
                                        '${_countHistory[index]}',
                                        style: TextStyle(
                                          color: isCurrent ? Colors.white : Colors.grey[700],
                                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
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
                      const SizedBox(height: 20),
                    ],
                    
                    const SizedBox(height: 30),
                    
                    // Bird Information from Offline API
                if (_birdInfo != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[600],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Bird Information',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Habitat
                        _buildInfoRow('Habitat', _birdInfo!['habitat']),
                        _buildInfoRow('Distribution', _birdInfo!['distribution']),
                        _buildInfoRow('Behavior', _birdInfo!['behavior']),
                        _buildInfoRow('Migration', _birdInfo!['migration']),
                        
                        const SizedBox(height: 12),
                        
                        // Threats
                        if (_birdInfo!['threats'] != null) ...[
                          Text(
                            'Threats:',
                            style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: (_birdInfo!['threats'] as List<dynamic>)
                                .map((threat) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red[100],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.red[300]!),
                                      ),
                                      child: Text(
                                        threat,
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                        
                        const SizedBox(height: 12),
                        
                        // Conservation Actions
                        if (_birdInfo!['conservation_actions'] != null) ...[
                          Text(
                            'Conservation Actions:',
                            style: TextStyle(
                              color: Colors.green[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: (_birdInfo!['conservation_actions'] as List<dynamic>)
                                .map((action) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.green[300]!),
                                      ),
                                      child: Text(
                                        action,
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
                
                // Observer name input
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Observer Name (Optional):',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                                                      TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                hintText: 'Enter your name (optional)...',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _observerName = value;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFF87CEEB),
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
            
            // Bird icon (center) - Clickable to show save confirmation
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _showSaveConfirmation,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 70,
                  height: 70,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF87CEEB),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
} 