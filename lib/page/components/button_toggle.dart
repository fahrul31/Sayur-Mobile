import 'package:flutter/material.dart';

class ButtonToggle extends StatelessWidget {
  final bool isPemasukanSelected;
  final Function(bool) onToggleChanged;

  const ButtonToggle({
    super.key,
    required this.isPemasukanSelected,
    required this.onToggleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xffF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pengeluaran Button
          Expanded(
            child: GestureDetector(
              onTap: () => {onToggleChanged(false)},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isPemasukanSelected
                      ? Colors.yellow[200]
                      : Colors.green[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Pengeluaran',
                    style: TextStyle(
                      color: isPemasukanSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Pemasukan Button
          Expanded(
            child: GestureDetector(
              onTap: () => onToggleChanged(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isPemasukanSelected
                      ? Colors.green[700]
                      : Colors.yellow[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Pendapatan',
                    style: TextStyle(
                      color: isPemasukanSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
