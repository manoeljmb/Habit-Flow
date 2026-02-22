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

        final scale = 1 + (_controller.value * 0.08);
        final glow = 10 + (_controller.value * 25);

        return Transform.scale(
          scale: scale,
          child: Material(
            color: Colors.transparent,
            child: Container(
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
              child: InkWell(
                borderRadius: BorderRadius.circular(32),
                onTap: widget.onTap,
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