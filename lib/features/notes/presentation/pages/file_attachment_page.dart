import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../utils/avicast_header.dart';

class FileAttachmentPage extends StatefulWidget {
  const FileAttachmentPage({super.key});

  @override
  State<FileAttachmentPage> createState() => _FileAttachmentPageState();
}

class _FileAttachmentPageState extends State<FileAttachmentPage> {
  List<AttachedFile> attachedFiles = [];
  bool isLoading = false;

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
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: AvicastHeader(
                pageTitle: 'Attach Files',
                showPageTitle: true,
                onBackPressed: () => Navigator.of(context).pop(),
              ),
            ),
            
            // File Type Selection
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select File Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildFileTypeButton(
                        icon: Icons.picture_as_pdf,
                        label: 'PDF',
                        color: Colors.red,
                        onTap: () => _pickFiles(['pdf']),
                      ),
                      _buildFileTypeButton(
                        icon: Icons.image,
                        label: 'Images',
                        color: Colors.blue,
                        onTap: () => _pickFiles(['jpg', 'jpeg', 'png', 'gif']),
                      ),
                      _buildFileTypeButton(
                        icon: Icons.description,
                        label: 'Documents',
                        color: Colors.green,
                        onTap: () => _pickFiles(['doc', 'docx', 'txt', 'rtf']),
                      ),
                      _buildFileTypeButton(
                        icon: Icons.table_chart,
                        label: 'Spreadsheets',
                        color: Colors.orange,
                        onTap: () => _pickFiles(['xls', 'xlsx', 'csv']),
                      ),
                      _buildFileTypeButton(
                        icon: Icons.folder,
                        label: 'Any File',
                        color: Colors.purple,
                        onTap: () => _pickFiles([]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Attached Files List
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Attached Files (${attachedFiles.length})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const Spacer(),
                        if (attachedFiles.isNotEmpty)
                          TextButton.icon(
                            onPressed: _clearAllFiles,
                            icon: const Icon(Icons.clear_all, size: 18),
                            label: const Text('Clear All'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red[600],
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    if (attachedFiles.isEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.attach_file,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No files attached yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Select a file type above to get started',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: attachedFiles.length,
                          itemBuilder: (context, index) {
                            final file = attachedFiles[index];
                            return _buildFileCard(file, index);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Action Buttons
            if (attachedFiles.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveFiles,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Files'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF87CEEB),
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
        ),
      ),
    );
  }

  Widget _buildFileTypeButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard(AttachedFile file, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // File Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getFileTypeColor(file.extension).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileTypeIcon(file.extension),
              color: _getFileTypeColor(file.extension),
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${file.size} • ${file.extension.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Remove Button
          IconButton(
            onPressed: () => _removeFile(index),
            icon: Icon(
              Icons.remove_circle_outline,
              color: Colors.red[400],
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Color _getFileTypeColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.purple;
      case 'txt':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getFileTypeIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _pickFiles(List<String> allowedExtensions) async {
    try {
      setState(() {
        isLoading = true;
      });

      // For web, we'll use a simple file input
      // For mobile, this would use the device's file picker
      _showFilePickerDialog(allowedExtensions);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking files: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showFilePickerDialog(List<String> allowedExtensions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Files'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This feature allows you to pick files from your device storage.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            if (allowedExtensions.isNotEmpty)
              Text(
                'Allowed file types: ${allowedExtensions.join(', ').toUpperCase()}',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _simulateFilePick(allowedExtensions);
            },
            child: const Text('Pick Files'),
          ),
        ],
      ),
    );
  }

  void _simulateFilePick(List<String> allowedExtensions) {
    // Simulate picking files for demo purposes
    // In a real app, this would use the device's file picker
    final sampleFiles = [
      AttachedFile(
        name: 'sample_document.pdf',
        size: '2.5 MB',
        extension: 'pdf',
        bytes: Uint8List(0),
      ),
      AttachedFile(
        name: 'field_notes.docx',
        size: '1.8 MB',
        extension: 'docx',
        bytes: Uint8List(0),
      ),
      AttachedFile(
        name: 'site_photo.jpg',
        size: '3.2 MB',
        extension: 'jpg',
        bytes: Uint8List(0),
      ),
    ];

    // Filter by allowed extensions if specified
    final filteredFiles = allowedExtensions.isEmpty
        ? sampleFiles
        : sampleFiles.where((file) => 
            allowedExtensions.contains(file.extension.toLowerCase())).toList();

    setState(() {
      attachedFiles.addAll(filteredFiles);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${filteredFiles.length} sample files added for demonstration'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeFile(int index) {
    setState(() {
      attachedFiles.removeAt(index);
    });
  }

  void _clearAllFiles() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Files'),
        content: const Text('Are you sure you want to remove all attached files?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                attachedFiles.clear();
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      for (int i = 0; i < attachedFiles.length; i++) {
        final file = attachedFiles[i];
        final fileName = '${timestamp}_${i}_${file.name}';
        final filePath = '${directory.path}/$fileName';
        
        // Create a simple text file with file info for demo
        final fileObj = File(filePath);
        await fileObj.writeAsString(
          'File: ${file.name}\n'
          'Size: ${file.size}\n'
          'Type: ${file.extension}\n'
          'Saved: ${DateTime.now()}\n'
          'This is a demonstration file attachment.',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${attachedFiles.length} files saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class AttachedFile {
  final String name;
  final String size;
  final String extension;
  final Uint8List bytes;

  AttachedFile({
    required this.name,
    required this.size,
    required this.extension,
    required this.bytes,
  });
} 