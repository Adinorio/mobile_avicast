import 'package:flutter/material.dart';
import '../../../bird_counting/presentation/pages/counting_site_page.dart';
import '../../data/services/sites_database_service.dart';
import '../../../../core/database/models/site_model.dart';
import '../../../../utils/avicast_header.dart';
import '../../../../utils/theme.dart';


class SitesPage extends StatefulWidget {
  const SitesPage({super.key});

  @override
  State<SitesPage> createState() => _SitesPageState();
}

class _SitesPageState extends State<SitesPage> with WidgetsBindingObserver {
  final SitesDatabaseService _databaseService = SitesDatabaseService.instance;
  List<Site> _sites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSites();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh sites when app becomes active
      _loadSites();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh sites when dependencies change (e.g., when returning to this page)
    _loadSites();
  }

  Future<void> _loadSites() async {
    try {
      final sites = await _databaseService.getAllSites();
      setState(() {
        _sites = sites;
        _isLoading = false;
      });
    } catch (e) {
      // If no sites exist, create default ones
      if (_sites.isEmpty) {
        await _createDefaultSites();
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createDefaultSites() async {
    final defaultSites = [
      Site(
        id: _databaseService.generateSiteId(),
        name: 'Avila',
        description: 'Coastal wetland area',
        latitude: 10.1234,
        longitude: 122.5678,
        createdAt: DateTime.now(),
      ),
      Site(
        id: _databaseService.generateSiteId(),
        name: 'Lakawon',
        description: 'Island bird sanctuary',
        latitude: 10.2345,
        longitude: 122.6789,
        createdAt: DateTime.now(),
      ),
      Site(
        id: _databaseService.generateSiteId(),
        name: 'Daga',
        description: 'Mountain forest reserve',
        latitude: 10.3456,
        longitude: 122.7890,
        createdAt: DateTime.now(),
      ),
      Site(
        id: _databaseService.generateSiteId(),
        name: 'Cadiz Viejo',
        description: 'Urban park and gardens',
        latitude: 10.4567,
        longitude: 122.8901,
        createdAt: DateTime.now(),
      ),
    ];

    for (final site in defaultSites) {
      await _databaseService.addSite(site);
    }

    setState(() {
      _sites = defaultSites;
    });
  }

  void _showAddSiteDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController latitudeController = TextEditingController();
    final TextEditingController longitudeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Counting Site'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Site Name *',
                    border: OutlineInputBorder(),
                    hintText: 'Enter site name...',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    hintText: 'Enter site description...',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latitudeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 10.1234',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: longitudeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 122.5678',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final siteName = nameController.text.trim();
                if (siteName.isNotEmpty) {
                  try {
                    final newSite = Site(
                      id: _databaseService.generateSiteId(),
                      name: siteName,
                      description: descriptionController.text.trim().isNotEmpty 
                          ? descriptionController.text.trim() 
                          : null,
                      latitude: latitudeController.text.trim().isNotEmpty 
                          ? double.tryParse(latitudeController.text.trim()) 
                          : null,
                      longitude: longitudeController.text.trim().isNotEmpty 
                          ? double.tryParse(longitudeController.text.trim()) 
                          : null,
                      createdAt: DateTime.now(),
                    );
                    
                    await _databaseService.addSite(newSite);
                    setState(() {
                      _sites.add(newSite);
                    });
                    Navigator.of(context).pop();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Site "$siteName" added successfully!'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding site: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a site name'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Save Site'),
            ),
          ],
        );
      },
    );
  }

  void _showSiteOptions(Site site) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Site Options: ${site.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Site information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (site.description != null && site.description!.isNotEmpty) ...[
                      Text(
                        'Description:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        site.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (site.latitude != null && site.longitude != null) ...[
                      Text(
                        'Coordinates:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${site.latitude!.toStringAsFixed(4)}, ${site.longitude!.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      'Created: ${_formatDate(site.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    if (site.birdCounts.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Bird Counts: ${site.birdCounts.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Action buttons
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF4CAF50)),
                title: const Text('Edit Site'),
                subtitle: const Text('Modify site details'),
                onTap: () {
                  Navigator.of(context).pop();
                  _editSite(site);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Site'),
                subtitle: const Text('Remove this site permanently'),
                onTap: () {
                  Navigator.of(context).pop();
                  _deleteSite(site);
                },
              ),
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

  void _editSite(Site site) {
    final TextEditingController nameController = TextEditingController(text: site.name);
    final TextEditingController descriptionController = TextEditingController(text: site.description ?? '');
    final TextEditingController latitudeController = TextEditingController(text: site.latitude?.toString() ?? '');
    final TextEditingController longitudeController = TextEditingController(text: site.longitude?.toString() ?? '');
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Site: ${site.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Site Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    hintText: 'Enter site description...',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latitudeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 10.1234',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: longitudeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 122.5678',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    final updatedSite = Site(
                      id: site.id,
                      name: newName,
                      description: descriptionController.text.trim().isNotEmpty 
                          ? descriptionController.text.trim() 
                          : null,
                      latitude: latitudeController.text.trim().isNotEmpty 
                          ? double.tryParse(latitudeController.text.trim()) 
                          : null,
                      longitude: longitudeController.text.trim().isNotEmpty 
                          ? double.tryParse(longitudeController.text.trim()) 
                          : null,
                      createdAt: site.createdAt,
                      birdCounts: site.birdCounts,
                    );
                    
                    await _databaseService.updateSite(updatedSite);
                    setState(() {
                      final index = _sites.indexWhere((s) => s.id == site.id);
                      if (index != -1) {
                        _sites[index] = updatedSite;
                      }
                    });
                    Navigator.of(context).pop();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Site "${newName}" updated successfully!'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating site: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a site name'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Update Site'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _deleteSite(Site site) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Site'),
          content: Text('Are you sure you want to delete "${site.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _databaseService.deleteSite(site.id);
                setState(() {
                  _sites.removeWhere((s) => s.id == site.id);
                });
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Site "${site.name}" deleted successfully!'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
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
                      AppTheme.avicastBlue, // Light blue
        AppTheme.avicastLightBlue, // Powder blue
              Colors.white,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with AVICAST branding
              Row(
                children: [
                  // AVICAST Logo
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF87CEEB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flutter_dash,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 15),
                  // AVICAST Text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AVICAST',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                          fontFamily: 'serif',
                        ),
                      ),
                      const Text(
                        'FIELD TOOL',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7F8C8D),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Main title
              const Text(
                'Counting Sites',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Site statistics
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF87CEEB),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${_sites.length}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            'Total Sites',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${_sites.fold(0, (sum, site) => sum + site.birdCounts.length)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                          Text(
                            'Total Counts',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${_sites.where((site) => site.latitude != null && site.longitude != null).length}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                          Text(
                            'With GPS',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Sites list
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF87CEEB),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _sites.length,
                        itemBuilder: (context, index) {
                          final site = _sites[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            child: Row(
                              children: [
                                // Site button with details
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      // Navigate to bird species page with selected site
                                      Navigator.of(context).pushNamed('/site-birds', arguments: site.name);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: const Color(0xFF87CEEB),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Site name
                                          Text(
                                            site.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2C3E50),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          
                                          // Description
                                          if (site.description != null && site.description!.isNotEmpty)
                                            Text(
                                              site.description!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                                fontStyle: FontStyle.italic,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          
                                          const SizedBox(height: 8),
                                          
                                          // Coordinates and creation date
                                          Row(
                                            children: [
                                              if (site.latitude != null && site.longitude != null)
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.location_on,
                                                        size: 16,
                                                        color: Colors.grey[500],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          '${site.latitude!.toStringAsFixed(4)}, ${site.longitude!.toStringAsFixed(4)}',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey[500],
                                                            fontFamily: 'monospace',
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              const Spacer(),
                                              Text(
                                                'Created: ${_formatDate(site.createdAt)}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[400],
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          // Bird count indicator
                                          if (site.birdCounts.isNotEmpty)
                                            Container(
                                              margin: const EdgeInsets.only(top: 8),
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF4CAF50).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: const Color(0xFF4CAF50),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.eco,
                                                    size: 14,
                                                    color: const Color(0xFF4CAF50),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${site.birdCounts.length} count${site.birdCounts.length == 1 ? '' : 's'}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF4CAF50),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Options button
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(0xFF87CEEB),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.more_horiz,
                                      color: Color(0xFF87CEEB),
                                      size: 24,
                                    ),
                                    onPressed: () => _showSiteOptions(site),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              
              const SizedBox(height: 20),
              
              // Add counting site section
              const Text(
                'Add counting site',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF87CEEB),
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Add site button
              Tooltip(
                message: 'Click to add new counting site with full details',
                child: GestureDetector(
                  onTap: _showAddSiteDialog,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFE3F2FD),
                          Color(0xFF87CEEB),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFF87CEEB),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF87CEEB).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_location_alt,
                            color: Colors.white,
                            size: 48,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add New Site',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),

    );
  }
} 