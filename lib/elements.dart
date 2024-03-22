import 'package:flutter/material.dart';

class PressableButton extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onPressed;
  final Color color;
  final Color shadowColor;

  PressableButton({
    Key? key,
    required this.child,
    required this.padding,
    this.color = const Color(0xFFf0f0f0),
    this.shadowColor = const Color(0xFFd4d4d4),
    this.onPressed, // Optional parameter
  }) : super(key: key);

  @override
  _PressableButtonState createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton> {
  bool _isPressed = false;

  void _onPointerDown(PointerDownEvent event) {
    setState(() => _isPressed = true);
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() => _isPressed = false);
    if (widget.onPressed != null) {
      widget.onPressed!(); // Invoke the callback if it's not null
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.shadowColor,
                    offset: Offset(0, 5),
                    blurRadius: 0,
                  ),
                ],
        ),
        transform: _isPressed
            ? Matrix4.translationValues(0, 5, 0)
            : Matrix4.translationValues(0, 0, 0),
        child: widget.child,
      ),
    );
  }
}
