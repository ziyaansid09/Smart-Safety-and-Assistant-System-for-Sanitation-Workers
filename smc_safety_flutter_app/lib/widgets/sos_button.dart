import 'package:flutter/material.dart';

class SOSButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isSending;
  final bool justSent;
  final String label;

  const SOSButton({
    super.key,
    required this.onPressed,
    this.isSending = false,
    this.justSent = false,
    this.label = 'PRESS FOR EMERGENCY',
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color btnColor = widget.justSent
        ? const Color(0xFF00E676)
        : const Color(0xFFFF1744);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            if (!widget.isSending) widget.onPressed();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (_, child) {
              return Transform.scale(
                scale: _pressed ? 0.92 : (widget.isSending ? 1.0 : _pulse.value),
                child: child,
              );
            },
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    btnColor,
                    btnColor.withOpacity(0.7),
                    btnColor.withOpacity(0.3),
                  ],
                  stops: const [0.4, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: btnColor.withOpacity(0.6),
                    blurRadius: 40,
                    spreadRadius: 15,
                  ),
                  BoxShadow(
                    color: btnColor.withOpacity(0.3),
                    blurRadius: 80,
                    spreadRadius: 30,
                  ),
                ],
                border: Border.all(
                  color: btnColor.withOpacity(0.8),
                  width: 3,
                ),
              ),
              child: widget.isSending
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 4,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.justSent
                              ? Icons.check_circle_rounded
                              : Icons.warning_rounded,
                          color: Colors.white,
                          size: 60,
                          shadows: const [
                            Shadow(color: Colors.white, blurRadius: 20),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.justSent ? 'SENT!' : 'SOS',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            shadows: [Shadow(color: Colors.white, blurRadius: 10)],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.label,
          style: TextStyle(
            color: btnColor.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
