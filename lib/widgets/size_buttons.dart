import 'package:flutter/material.dart';

class SizeButton extends StatelessWidget {
  final String size;
  final bool isSelected;
  final Function(String) onSelect;

  const SizeButton({
    super.key,
    required this.size,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(size),
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[200],
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
        child: Center(
          child: Text(
            size,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
