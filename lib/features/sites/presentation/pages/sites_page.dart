import 'package:flutter/material.dart';
import '../../data/services/sites_database_service.dart';


class SitesPage extends StatefulWidget {
  const SitesPage({super.key});

  @override
  State<SitesPage> createState() => _SitesPageState();
}

class _SitesPageState extends State<SitesPage> {
  final SitesDatabaseService _databaseService = SitesDatabaseService();
  List<Site> _sites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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
        createdAt: DateTime.now(),
      ),
      Site(
        id: _databaseService.generateSiteId(),
        name: 'Lakawon',
        createdAt: DateTime.now(),
      ),
      Site(
        id: _databaseService.generateSiteId(),
        name: 'Daga',
        createdAt: DateTime.now(),
      ),
      Site(
        id: _databaseService.generateSiteId(),
        name: 'Cadiz Viejo',
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
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Site Name:'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter site name...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final siteName = controller.text.trim();
                if (siteName.isNotEmpty) {
                  final newSite = Site(
                    id: _databaseService.generateSiteId(),
                    name: siteName,
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
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
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
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Site'),
                onTap: () {
                  Navigator.of(context).pop();
                  _editSite(site);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Site'),
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
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _editSite(Site site) {
    final TextEditingController controller = TextEditingController(text: site.name);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Site Name:'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  final updatedSite = Site(
                    id: site.id,
                    name: newName,
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
                      content: Text('Site renamed to "$newName" successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
      backgroundColor: Colors.white,
      body: SafeArea(
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
                                // Site button
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      // Navigate to bird species page with selected site
                                      Navigator.of(context).pushNamed('/site-birds', arguments: site.name);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                                      child: Text(
                                        site.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF87CEEB),
                                        ),
                                        textAlign: TextAlign.center,
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
              GestureDetector(
                onTap: _showAddSiteDialog,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF87CEEB),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      color: Color(0xFF87CEEB),
                      size: 48,
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