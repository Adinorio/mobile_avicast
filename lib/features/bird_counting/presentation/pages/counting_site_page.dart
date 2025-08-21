import 'package:flutter/material.dart';
import '../../../../utils/avicast_header.dart';

class CountingSitePage extends StatelessWidget {
  const CountingSitePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the site name from navigation arguments
    final String siteName = ModalRoute.of(context)?.settings.arguments as String? ?? 'Selected Site';
    
    return Scaffold(
      body: CounterView(
        siteName: siteName,
        onBackToSites: () {
          Navigator.of(context).pop(); // Go back to sites page
        },
      ),
    );
  }
}

class SiteSelectionView extends StatefulWidget {
  const SiteSelectionView({super.key});

  @override
  State<SiteSelectionView> createState() => _SiteSelectionViewState();
}

class _SiteSelectionViewState extends State<SiteSelectionView> {
  String? _selectedSite;
  final List<String> _availableSites = [
    'Central Park Bird Sanctuary',
    'Riverside Wetlands',
    'Mountain Forest Reserve',
    'Coastal Bird Colony',
    'Urban Garden Habitat',
  ];

  void _selectSite(String site) {
    setState(() {
      _selectedSite = site;
    });
  }

  void _showAddSiteDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Site'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Site Name',
              border: OutlineInputBorder(),
              hintText: 'Enter site name...',
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                setState(() {
                  _availableSites.add(value);
                });
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final value = controller.text;
                if (value.isNotEmpty) {
                  setState(() {
                    _availableSites.add(value);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedSite != null) {
      return CounterView(
        siteName: _selectedSite!,
        onBackToSites: () {
          setState(() {
            _selectedSite = null;
          });
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with AVICAST branding
              AvicastHeader(
                pageTitle: 'Select Counting Site',
                showPageTitle: true,
              ),
              
              const SizedBox(height: 30),
              
              // Site list
              Expanded(
                child: ListView.builder(
                  itemCount: _availableSites.length,
                  itemBuilder: (context, index) {
                    final site = _availableSites[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF4CAF50),
                          child: Icon(
                            Icons.nature_people,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          site,
                          style: const TextStyle(
                            color: Color(0xFF2C3E50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Tap to start counting',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF2C3E50),
                          size: 16,
                        ),
                        onTap: () => _selectSite(site),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Add new site button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showAddSiteDialog,
                  icon: const Icon(Icons.add_location),
                  label: const Text('Add New Site'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CounterView extends StatefulWidget {
  final String siteName;
  final VoidCallback onBackToSites;

  const CounterView({
    super.key,
    required this.siteName,
    required this.onBackToSites,
  });

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  int _count = 0;
  String _counterName = "Unnamed Counter";

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

  void _showNameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Counter'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Counter Name',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: _counterName),
            onSubmitted: (value) {
              setState(() {
                _counterName = value.isNotEmpty ? value : "Unnamed Counter";
              });
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final controller = TextEditingController(text: _counterName);
                setState(() {
                  _counterName = controller.text.isNotEmpty ? controller.text : "Unnamed Counter";
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showSaveConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End and Save Count?'),
          content: Text('Do you want to save the count of $_count for ${widget.siteName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Save count to database with site information
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Saved count: $_count at ${widget.siteName}'),
                    backgroundColor: Colors.green[700],
                  ),
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
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
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBackToSites,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _counterName,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            Text(
              widget.siteName,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showNameDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Site info
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3C3C3C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: const Color(0xFF4CAF50),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.siteName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Large counter display
                  Text(
                    '$_count',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50), // Bright green color
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Divider line
                  Container(
                    width: 200,
                    height: 1,
                    color: Colors.grey[600],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Control buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Decrement button
                      GestureDetector(
                        onTap: _decrement,
                        onLongPress: _reset,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3C3C3C), // Lighter grey
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.remove,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 40),
                      
                      // Increment button
                      GestureDetector(
                        onTap: _increment,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3C3C3C), // Lighter grey
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Instructions
                  Text(
                    'Tap + to count, - to decrease\nLong press - to reset',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Additional actions
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showSaveConfirmation,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 