import 'package:flutter/material.dart';
import '../../../../utils/avicast_header.dart';
import '../../../sites/data/services/sites_database_service.dart';

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
  bool _isLeftHanded = false;
  final SitesDatabaseService _databaseService = SitesDatabaseService();

  void _increment() {
    setState(() {
      _count++;
    });
  }

  void _decrement() {
    setState(() {
      if (_count > 0) {
        _count--;
      }
    });
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
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
                if (_observerName == null || _observerName!.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your name first'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.of(context).pop();
                  return;
                }

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
                    observerName: _observerName!,
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.birdStatus,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
                    
                    // Count display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
                      decoration: BoxDecoration(
                        color: const Color(0xFF87CEEB),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '$_count',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Control buttons - Layout changes based on handedness preference
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _isLeftHanded ? [
                        // Left-handed layout: Increment, Reset, Decrement
                        _buildIncrementButton(),
                        _buildResetButton(),
                        _buildDecrementButton(),
                      ] : [
                        // Right-handed layout: Decrement, Reset, Increment
                        _buildDecrementButton(),
                        _buildResetButton(),
                        _buildIncrementButton(),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Action buttons row
                    Row(
                      children: [
                        // Left/Right-Handed toggle button (blue)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isLeftHanded = !_isLeftHanded;
                              });
                            },
                            icon: const Icon(
                              Icons.swap_horiz,
                              color: Colors.white,
                            ),
                            label: Text(
                              _isLeftHanded ? 'Left-Handed' : 'Right-Handed',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
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
                    
                    const SizedBox(height: 30),
                    
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
                            'Observer Name:',
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
                              hintText: 'Enter your name...',
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

  Widget _buildIncrementButton() {
    return GestureDetector(
      onTap: _increment,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildDecrementButton() {
    return GestureDetector(
      onTap: _decrement,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF44336),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF44336).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.remove,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return GestureDetector(
      onTap: _reset,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF757575),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
} 