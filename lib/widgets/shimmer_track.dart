import 'package:flutter/material.dart';

/// A shimmer-effect track that sits behind the filled portion of a progress bar.
/// Drop-in replacement for a plain grey background Container.
class ShimmerTrack extends StatefulWidget {
  final double height;
  final BorderRadius borderRadius;

  const ShimmerTrack({
    super.key,
    this.height = 12,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<ShimmerTrack> createState() => _ShimmerTrackState();
}

class _ShimmerTrackState extends State<ShimmerTrack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark
        ? const Color(0xFF1C1C26)   // dark surface
        : const Color(0xFFD8D8D8);  // light grey
    final shimmerColor = isDark
        ? const Color(0xFF2E2E3E)   // slightly lighter for dark
        : const Color(0xFFEEEEEE);  // near-white for light

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 0.5, 0),
              end: Alignment(_animation.value + 0.5, 0),
              colors: [baseColor, shimmerColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
