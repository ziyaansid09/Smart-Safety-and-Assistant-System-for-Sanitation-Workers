import 'package:flutter/material.dart';

class BlinkingSOSIndicator extends StatefulWidget {
  final double size;
  const BlinkingSOSIndicator({super.key, this.size = 24});

  @override
  State<BlinkingSOSIndicator> createState() => _BlinkingSOSIndicatorState();
}

class _BlinkingSOSIndicatorState extends State<BlinkingSOSIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(_animation.value),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(_animation.value * 0.8),
                blurRadius: widget.size * 0.8,
                spreadRadius: widget.size * 0.2,
              ),
            ],
          ),
          child: Icon(
            Icons.warning_rounded,
            color: Colors.white,
            size: widget.size * 0.6,
          ),
        );
      },
    );
  }
}

class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;
  const PulsingDot({super.key, required this.color, this.size = 12});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(_anim.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_anim.value * 0.6),
                blurRadius: widget.size,
                spreadRadius: widget.size * 0.3,
              ),
            ],
          ),
        );
      },
    );
  }
}
