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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
            width: 2,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(1),
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
            width: 2,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(1),
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
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        
        // Digit wheel
        Container(
          width: 60,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
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