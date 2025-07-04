import 'package:flutter/material.dart';
import 'package:green_finance/models/item_model.dart';
import 'package:vibration/vibration.dart';

class ItemTile extends StatefulWidget {
  final ItemModel item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });
  @override
  State<ItemTile> createState() => _ItemTileState();
}

class _ItemTileState extends State<ItemTile>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _handleLongPress() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 70);
    }
    // Start shrink animation
    setState(() => _scale = 0.9);

    await Future.delayed(const Duration(milliseconds: 100));

    // Back to normal
    setState(() => _scale = 1.0);

    // Call external handler after animation
    await Future.delayed(const Duration(milliseconds: 100));
    widget.onLongPress();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: _handleLongPress,
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(widget.item.photo ?? ''),
            ),
            const Spacer(),
            Text(
              widget.item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
