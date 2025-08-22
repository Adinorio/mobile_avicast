import 'package:flutter/material.dart';

class ScrollableCounter extends StatefulWidget {
  final int initialValue;
  final Function(int) onValueChanged;
  final int minValue;
  final int maxValue;
  final int? value; // External value to sync with

  const ScrollableCounter({
    super.key,
    this.initialValue = 0,
    required this.onValueChanged,
    this.minValue = 0,
    this.maxValue = 999,
    this.value,
  });

  @override
  State<ScrollableCounter> createState() => _ScrollableCounterState();
}



class _ScrollableCounterState extends State<ScrollableCounter> {
  late FixedExtentScrollController _hundredsController;
  late FixedExtentScrollController _tensController;
  late FixedExtentScrollController _onesController;
  
  late int _hundreds;
  late int _tens;
  late int _ones;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(ScrollableCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && widget.value != oldWidget.value) {
      _updateFromExternalValue(widget.value!);
    }
  }

  void _initializeControllers() {
    final value = widget.initialValue.clamp(widget.minValue, widget.maxValue);
    _hundreds = value ~/ 100;
    _tens = (value % 100) ~/ 10;
    _ones = value % 10;
    
    _hundredsController = FixedExtentScrollController(initialItem: _hundreds);
    _tensController = FixedExtentScrollController(initialItem: _tens);
    _onesController = FixedExtentScrollController(initialItem: _ones);
  }

  @override
  void dispose() {
    _hundredsController.dispose();
    _tensController.dispose();
    _onesController.dispose();
    super.dispose();
  }

  void _updateValue() {
    final newValue = _hundreds * 100 + _tens * 10 + _ones;
    if (newValue >= widget.minValue && newValue <= widget.maxValue) {
      widget.onValueChanged(newValue);
    }
  }

  void _updateFromExternalValue(int value) {
    final clampedValue = value.clamp(widget.minValue, widget.maxValue);
    _hundreds = clampedValue ~/ 100;
    _tens = (clampedValue % 100) ~/ 10;
    _ones = clampedValue % 10;
    
    _hundredsController.jumpToItem(_hundreds);
    _tensController.jumpToItem(_tens);
    _onesController.jumpToItem(_ones);
    
    setState(() {});
  }

  void _onHundredsChanged(int value) {
    setState(() {
      _hundreds = value;
    });
    _updateValue();
  }

  void _onTensChanged(int value) {
    setState(() {
      _tens = value;
    });
    _updateValue();
  }

  void _onOnesChanged(int value) {
    setState(() {
      _ones = value;
    });
    _updateValue();
  }

  void setValue(int value) {
    final clampedValue = value.clamp(widget.minValue, widget.maxValue);
    _hundreds = clampedValue ~/ 100;
    _tens = (clampedValue % 100) ~/ 10;
    _ones = clampedValue % 10;
    
    _hundredsController.jumpToItem(_hundreds);
    _tensController.jumpToItem(_tens);
    _onesController.jumpToItem(_ones);
    
    setState(() {});
    _updateValue();
  }

  void reset() {
    setValue(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE3F2FD), // Light blue
            Color(0xFFF3E5F5), // Light purple
            Color(0xFFFFF9C4), // Light yellow
            Colors.white,
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00897B).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00897B).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Hundreds digit
          _buildDigitWheel(
            controller: _hundredsController,
            onChanged: _onHundredsChanged,
            label: 'Hundreds',
            color: Colors.red,
          ),
          
          // Separator
          Container(
            width: 3,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF00897B).withOpacity(0.3),
                  const Color(0xFF00897B),
                  const Color(0xFF00897B).withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00897B).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          
          // Tens digit
          _buildDigitWheel(
            controller: _tensController,
            onChanged: _onTensChanged,
            label: 'Tens',
            color: Colors.blue,
          ),
          
          // Separator
          Container(
            width: 3,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF00897B).withOpacity(0.3),
                  const Color(0xFF00897B),
                  const Color(0xFF00897B).withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00897B).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          
          // Ones digit
          _buildDigitWheel(
            controller: _onesController,
            onChanged: _onOnesChanged,
            label: 'Ones',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDigitWheel({
    required FixedExtentScrollController controller,
    required Function(int) onChanged,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C3E50),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        
        // Digit wheel
        Container(
          width: 60,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.9),
                color.withOpacity(0.1),
                Colors.white.withOpacity(0.9),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 6,
                offset: const Offset(-2, -2),
              ),
            ],
          ),
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 40,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                return Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                );
              },
              childCount: 10,
            ),
          ),
        ),
      ],
    );
  }
} 