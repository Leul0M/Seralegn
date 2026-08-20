import 'package:flutter/material.dart';

class SwipeActionButton extends StatefulWidget {
  final String label;
  final Color activeColor;
  final Color backgroundColor;
  final VoidCallback onSwiped;

  const SwipeActionButton({
    super.key,
    required this.label,
    required this.activeColor,
    required this.backgroundColor,
    required this.onSwiped,
  });

  @override
  State<SwipeActionButton> createState() => _SwipeActionButtonState();
}

class _SwipeActionButtonState extends State<SwipeActionButton> {
  double _dragPosition = 0.0;
  bool _isFinished = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = constraints.maxWidth - 56.0;

        return Container(
          height: 56,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: widget.activeColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              // Background label
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: widget.activeColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: widget.activeColor,
                    ),
                  ],
                ),
              ),

              // Draggable Handle
              Positioned(
                left: _dragPosition,
                top: 3,
                bottom: 3,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isFinished) return;
                    setState(() {
                      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isFinished) return;
                    if (_dragPosition >= maxDrag * 0.75) {
                      setState(() {
                        _dragPosition = maxDrag;
                        _isFinished = true;
                      });
                      widget.onSwiped();
                    } else {
                      setState(() {
                        _dragPosition = 0.0;
                      });
                    }
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: widget.activeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.activeColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
