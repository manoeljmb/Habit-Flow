import 'package:flutter/material.dart';

class PulsingFAB extends StatefulWidget {
  final VoidCallback onTap;

  const PulsingFAB({super.key, required this.onTap});

  @override
  State<PulsingFAB> createState() => _PulsingFABState();
}

class _PulsingFABState extends State<PulsingFAB>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _controller.repeat(reverse: true); // 🔥 PULSO
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF6FCF97);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {

        final scalePulse = 1 + (_controller.value * 0.08);
        final glow = 10 + (_controller.value * 25);

        final pressScale = isPressed ? 0.92 : 1.0;

        return Transform.scale(
          scale: scalePulse * pressScale,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(32),

              onTapDown: (_) => setState(() => isPressed = true),

              onTapUp: (_) {
                setState(() => isPressed = false);
                widget.onTap();
              },

              onTapCancel: () => setState(() => isPressed = false),

              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: green,
                  boxShadow: [
                    BoxShadow(
                      color: green.withOpacity(0.6),
                      blurRadius: glow,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}