import 'package:flutter/material.dart';
import '../widgets/scrollable_counter.dart';
import '../../../../utils/avicast_header.dart';
import '../../../../utils/theme.dart';
import '../../../sites/data/services/sites_database_service.dart';


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
  final List<String> _availableSites = [];

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
                child: _availableSites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No Counting Sites Available',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'You haven\'t added any counting sites yet.\nTap the button below to add your first site.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton.icon(
                              onPressed: _showAddSiteDialog,
                              icon: const Icon(Icons.add_location),
                              label: const Text('Add First Site'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
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
              
              // Add new site button (only show when there are existing sites)
              if (_availableSites.isNotEmpty) ...[
                const SizedBox(height: 20),
                
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

class _CounterViewState extends State<CounterView> with WidgetsBindingObserver {
  int _count = 0;
  String _counterName = "Unnamed Counter";
  final SitesDatabaseService _databaseService = SitesDatabaseService();
  List<BirdCount> _savedCounts = [];
  bool _isLoading = true;

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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _savedCounts = [];
        _isLoading = false;
      });
    }
  }

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
    if (_count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a count greater than 0'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Count'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Do you want to save the count of $_count for ${widget.siteName}?'),
              const SizedBox(height: 16),
              const Text(
                'Note: This will save a general count for the site. For specific bird species, use the bird counter page.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Get all sites to find the current site
                  final sites = await _databaseService.getAllSites();
                  final currentSite = sites.firstWhere((site) => site.name == widget.siteName);
                  
                  // Create bird count record
                  final birdCount = BirdCount(
                    birdName: 'General Count',
                    birdFamily: 'Site Count',
                    birdScientificName: 'Site Count',
                    birdStatus: 'Unknown',
                    count: _count,
                    timestamp: DateTime.now(),
                    observerName: _counterName,
                  );
                  
                  // Save to database
                  await _databaseService.addBirdCount(currentSite.id, birdCount);
                  
                  // Reload saved counts
                  await _loadSavedCounts();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Saved count: $_count at ${widget.siteName}'),
                      backgroundColor: Colors.green[700],
                    ),
                  );
                  
                  Navigator.of(context).pop();
                  
                  // Reset count after saving
                  setState(() {
                    _count = 0;
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving count: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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

  void _showComprehensiveReview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildComprehensiveReviewSheet(),
    );
  }

  Widget _buildComprehensiveReviewSheet() {
    final totalCounts = _savedCounts.length;
    final totalBirds = _savedCounts.fold<int>(0, (sum, count) => sum + count.count);
    final uniqueObservers = _savedCounts.map((count) => count.observerName).toSet().length;
    
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
                    const Icon(Icons.verified, color: Color(0xFF4CAF50), size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Review & Submit All Counts',
                      style: TextStyle(
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
                    const Color(0xFF3498DB),
                    [
                      _buildReviewItem('Site Name', widget.siteName, Icons.place),
                      _buildReviewItem('Total Counts', '$totalCounts', Icons.list_alt),
                      _buildReviewItem('Survey Date', _getCurrentDate(), Icons.calendar_today),
                      _buildReviewItem('Observers', '$uniqueObservers', Icons.people),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Section 2: Count Data Review
                  _buildReviewSection(
                    '🦅 Count Data Summary',
                    Icons.analytics,
                    const Color(0xFF4CAF50),
                    [
                      _buildReviewItem('Total Counts', '$totalCounts', Icons.list_alt),
                      _buildReviewItem('Total Birds', '$totalBirds', Icons.flutter_dash),
                      _buildReviewItem('Average per Count', '${(totalBirds / totalCounts).toStringAsFixed(1)}', Icons.trending_up),
                      _buildReviewItem('Data Quality', 'High', Icons.verified),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Section 3: Observer Information
                  _buildReviewSection(
                    '👥 Observer Details',
                    Icons.person,
                    const Color(0xFF667eea),
                    _buildObserverItems(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Section 4: Recent Counts Preview
                  if (_savedCounts.isNotEmpty) ...[
                    _buildReviewSection(
                      '📊 Recent Counts',
                      Icons.history,
                      const Color(0xFF9B59B6),
                      [_buildRecentCountsPreview()],
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
          
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
                      side: const BorderSide(color: Color(0xFF667eea)),
                      foregroundColor: const Color(0xFF667eea),
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
                      backgroundColor: const Color(0xFF4CAF50),
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
            color: isCompleted ? const Color(0xFF4CAF50) : Colors.grey[300],
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
            color: isCompleted ? const Color(0xFF4CAF50) : Colors.grey[600],
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

  List<Widget> _buildObserverItems() {
    final observerCounts = <String, int>{};
    for (final count in _savedCounts) {
      final observerName = count.observerName ?? 'Unknown Observer';
      observerCounts[observerName] = (observerCounts[observerName] ?? 0) + 1;
    }
    
    return observerCounts.entries.map((entry) {
      return _buildReviewItem(
        entry.key,
        '${entry.value} counts',
        Icons.person_outline,
      );
    }).toList();
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
                color: const Color(0xFF4CAF50),
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
              backgroundColor: const Color(0xFF4CAF50),
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
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildCountsSummary() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_savedCounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF3C3C3C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 32),
            SizedBox(height: 8),
            Text(
              'No counts saved yet',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              'Start counting and save to see your data here',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3C3C3C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.history, color: Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                const Text(
                  'Saved Counts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_savedCounts.length} entries',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          ..._savedCounts.take(5).map((count) => _buildCountItem(count)),
          if (_savedCounts.length > 5)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '... and ${_savedCounts.length - 5} more',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCountItem(BirdCount count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${count.count}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.birdName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (count.observerName != null && count.observerName!.isNotEmpty)
                  Text(
                    'by ${count.observerName}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
              ],
            ),
          ),
          Text(
            _formatTimestamp(count.timestamp),
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _loadSavedCounts(),
            tooltip: 'Refresh Counts',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showNameDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
                child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Site info
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  
                  const SizedBox(height: 20),
                  
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
                  
                  const SizedBox(height: 30),
                  
                  // Saved counts summary
                  _buildCountsSummary(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Additional actions
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Review & Submit All Counts button
                if (_savedCounts.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton.icon(
                      onPressed: _showComprehensiveReview,
                      icon: const Icon(Icons.verified, size: 24),
                      label: const Text(
                        'Review & Submit All Counts',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                
                // Action buttons row
                Row(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
} 