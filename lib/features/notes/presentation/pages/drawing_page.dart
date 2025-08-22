import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../utils/avicast_header.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  List<DrawingPoint?> drawingPoints = [];
  List<List<DrawingPoint?>> drawingHistory = [];
  List<List<DrawingPoint?>> redoHistory = [];
  Color selectedColor = Colors.black;
  Color canvasBackgroundColor = Colors.white;
  double strokeWidth = 3.0;
  String selectedTool = 'pen'; // 'pen', 'eraser', 'shape'
  String selectedShape = 'rectangle'; // 'rectangle', 'circle', 'line'
  Offset? shapeStartPoint;
  Offset? shapePreviewPoint; // For showing preview while dragging
  final GlobalKey canvasKey = GlobalKey();

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
                pageTitle: 'Drawing Sketch',
                showPageTitle: true,
                onBackPressed: () => Navigator.of(context).pop(),
              ),
            ),
            
            // Drawing Canvas
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: canvasBackgroundColor,
                    child: GestureDetector(
                      onPanStart: (details) {
                        _saveToHistory();
                        if (selectedTool == 'shape') {
                          shapeStartPoint = details.localPosition;
                        } else {
                          setState(() {
                            drawingPoints.add(
                              DrawingPoint(
                                details.localPosition,
                                _createPaint(),
                              ),
                            );
                          });
                        }
                      },
                      onPanUpdate: (details) {
                        if (selectedTool == 'shape') {
                          // For shapes, update the preview by redrawing
                          setState(() {
                            shapePreviewPoint = details.localPosition;
                          });
                        } else {
                          setState(() {
                            drawingPoints.add(
                              DrawingPoint(
                                details.localPosition,
                                _createPaint(),
                              ),
                            );
                          });
                        }
                      },
                      onPanEnd: (details) {
                        if (selectedTool == 'shape' && shapeStartPoint != null) {
                          _addShape(shapeStartPoint!, details.localPosition);
                          shapeStartPoint = null;
                          shapePreviewPoint = null; // Clear preview
                        } else {
                          setState(() {
                            drawingPoints.add(null);
                          });
                        }
                      },
                      child: CustomPaint(
                        key: canvasKey,
                        painter: DrawingPainter(
                          drawingPoints,
                          previewPoint: shapePreviewPoint,
                          previewShape: selectedTool == 'shape' ? selectedShape : null,
                          previewStartPoint: shapeStartPoint,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Drawing Controls - Compact Tool Panel
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tool Selection Row
                  Row(
                    children: [
                      // Pen Tool
                      Expanded(
                        child: _buildToolButton(
                          icon: Icons.edit,
                          label: 'Pen',
                          isSelected: selectedTool == 'pen',
                          onTap: () => _selectTool('pen'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Eraser Tool
                      Expanded(
                        child: _buildToolButton(
                          icon: Icons.auto_fix_high,
                          label: 'Eraser',
                          isSelected: selectedTool == 'eraser',
                          onTap: () => _selectTool('eraser'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Shape Tool
                      Expanded(
                        child: _buildToolButton(
                          icon: Icons.crop_square,
                          label: 'Shape',
                          isSelected: selectedTool == 'shape',
                          onTap: () => _selectTool('shape'),
                        ),
                      ),
                    ],
                  ),
                  
                  // Shape Selection (only show when shape tool is selected)
                  if (selectedTool == 'shape') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Select Shape Type',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildShapeButton('rectangle', Icons.crop_square),
                              _buildShapeButton('circle', Icons.circle_outlined),
                              _buildShapeButton('line', Icons.remove),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Pen Colors - Compact
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildColorButton(Colors.black, false),
                      _buildColorButton(Colors.red, false),
                      _buildColorButton(Colors.blue, false),
                      _buildColorButton(Colors.green, false),
                      _buildColorButton(Colors.orange, false),
                      _buildColorButton(Colors.purple, false),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Canvas Backgrounds - Compact
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildColorButton(Colors.white, true),
                      _buildColorButton(Colors.black, true),
                      _buildColorButton(Colors.grey[100]!, true),
                      _buildColorButton(Colors.yellow[50]!, true),
                      _buildColorButton(Colors.blue[50]!, true),
                      _buildColorButton(Colors.green[50]!, true),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Stroke Width & Actions Row
                  Row(
                    children: [
                      // Stroke Width
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            const Icon(Icons.line_weight, color: Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Slider(
                                value: strokeWidth,
                                min: 1.0,
                                max: 10.0,
                                divisions: 9,
                                onChanged: (value) {
                                  setState(() {
                                    strokeWidth = value;
                                  });
                                },
                              ),
                            ),
                            Text(
                              '${strokeWidth.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Undo/Redo
                      IconButton(
                        onPressed: drawingHistory.isEmpty ? null : _undo,
                        icon: const Icon(Icons.undo, size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue[50],
                          foregroundColor: Colors.blue[600],
                        ),
                      ),
                      IconButton(
                        onPressed: redoHistory.isEmpty ? null : _redo,
                        icon: const Icon(Icons.redo, size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue[50],
                          foregroundColor: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Action Buttons - Compact
                  Row(
                    children: [
                      // Clear Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _clearCanvas,
                          icon: const Icon(Icons.clear, size: 20),
                          label: const Text('Clear'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.red[300]!),
                            foregroundColor: Colors.red[600],
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Save Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveDrawing,
                          icon: const Icon(Icons.save, size: 20),
                          label: const Text('Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF87CEEB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
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
      ),
    );
  }

  Paint _createPaint() {
    if (selectedTool == 'eraser') {
      return Paint()
        ..color = canvasBackgroundColor
        ..isAntiAlias = true
        ..strokeWidth = strokeWidth * 2 // Eraser is wider
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.clear; // This makes it work as an eraser
    } else {
      return Paint()
        ..color = selectedColor
        ..isAntiAlias = true
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
    }
  }

  void _selectTool(String tool) {
    setState(() {
      selectedTool = tool;
    });
  }

  void _selectShape(String shape) {
    setState(() {
      selectedShape = shape;
    });
  }

  void _addShape(Offset start, Offset end) {
    final paint = Paint()
      ..color = selectedColor
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    setState(() {
      drawingPoints.add(
        DrawingPoint(start, paint, shapeType: selectedShape, endPoint: end),
      );
      drawingPoints.add(null); // End the shape
    });
  }

  void _saveToHistory() {
    drawingHistory.add(List.from(drawingPoints));
    redoHistory.clear(); // Clear redo history when new action is performed
    
    // Limit history size to prevent memory issues
    if (drawingHistory.length > 50) {
      drawingHistory.removeAt(0);
    }
  }

  void _undo() {
    if (drawingHistory.isNotEmpty) {
      redoHistory.add(List.from(drawingPoints));
      setState(() {
        drawingPoints = List.from(drawingHistory.removeLast());
      });
    }
  }

  void _redo() {
    if (redoHistory.isNotEmpty) {
      drawingHistory.add(List.from(drawingPoints));
      setState(() {
        drawingPoints = List.from(redoHistory.removeLast());
      });
    }
  }

  Widget _buildColorButton(Color color, bool isBackgroundColor) {
    final isSelected = isBackgroundColor 
        ? canvasBackgroundColor == color 
        : selectedColor == color;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isBackgroundColor) {
            canvasBackgroundColor = color;
          } else {
            selectedColor = color;
          }
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? Icon(
                isBackgroundColor ? Icons.format_paint : Icons.check,
                color: color == Colors.white || color == Colors.yellow[50] 
                    ? Colors.grey[700] 
                    : Colors.white,
                size: 20,
              )
            : null,
      ),
    );
  }

  Widget _buildOldColorButton(Color color) {
    final isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              )
            : null,
      ),
    );
  }

  Widget _buildShapeButton(String shape, IconData icon) {
    final isSelected = selectedShape == shape;
    return GestureDetector(
      onTap: () => _selectShape(shape),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? Colors.green[300]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.green[700] : Colors.grey[600],
          size: 18,
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue[300]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue[700] : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.blue[700] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearCanvas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Canvas'),
        content: const Text('Are you sure you want to clear the drawing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveToHistory();
              setState(() {
                drawingPoints.clear();
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDrawing() async {
    try {
      final RenderRepaintBoundary boundary = canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/sketch_$timestamp.png');
      await file.writeAsBytes(pngBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sketch saved successfully!\nPath: ${file.path}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving sketch: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class DrawingPoint {
  final Offset offset;
  final Paint paint;
  final String? shapeType;
  final Offset? endPoint;

  DrawingPoint(this.offset, this.paint, {this.shapeType, this.endPoint});
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> drawingPoints;
  final Offset? previewPoint;
  final String? previewShape;
  final Offset? previewStartPoint;

  DrawingPainter(
    this.drawingPoints, {
    this.previewPoint,
    this.previewShape,
    this.previewStartPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw all existing shapes and lines
    for (int i = 0; i < drawingPoints.length; i++) {
      final point = drawingPoints[i];
      if (point != null) {
        if (point.shapeType != null && point.endPoint != null) {
          // Draw shapes
          _drawShape(canvas, point);
        } else if (i < drawingPoints.length - 1 && drawingPoints[i + 1] != null) {
          // Draw lines (normal drawing) - only if next point exists and is not null
          final nextPoint = drawingPoints[i + 1]!;
          if (nextPoint.shapeType == null && nextPoint.endPoint == null) {
            canvas.drawLine(
              point.offset,
              nextPoint.offset,
              point.paint,
            );
          }
        }
      }
    }
    
    // Draw preview shape if available
    if (previewPoint != null && previewStartPoint != null && previewShape != null) {
      final previewPaint = Paint()
        ..color = Colors.blue.withOpacity(0.6)
        ..isAntiAlias = true
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      _drawPreviewShape(canvas, previewStartPoint!, previewPoint!, previewShape!, previewPaint);
    }
  }

  void _drawShape(Canvas canvas, DrawingPoint point) {
    if (point.shapeType == 'rectangle') {
      final rect = Rect.fromPoints(point.offset, point.endPoint!);
      canvas.drawRect(rect, point.paint);
    } else if (point.shapeType == 'circle') {
      final center = Offset(
        (point.offset.dx + point.endPoint!.dx) / 2,
        (point.offset.dy + point.endPoint!.dy) / 2,
      );
      final radius = (point.offset - point.endPoint!).distance / 2;
      canvas.drawCircle(center, radius, point.paint);
    } else if (point.shapeType == 'line') {
      canvas.drawLine(point.offset, point.endPoint!, point.paint);
    }
  }

  void _drawPreviewShape(Canvas canvas, Offset start, Offset end, String shapeType, Paint paint) {
    if (shapeType == 'rectangle') {
      final rect = Rect.fromPoints(start, end);
      canvas.drawRect(rect, paint);
    } else if (shapeType == 'circle') {
      final center = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2,
      );
      final radius = (start - end).distance / 2;
      canvas.drawCircle(center, radius, paint);
    } else if (shapeType == 'line') {
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 