import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget child;
  const SplashScreen({super.key, required this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoOpacity;
  late Animation<double> _splashOpacity;
  bool _showApp = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // Logo fades IN during first 0.3s, stays visible, then fades OUT
    _logoOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 6),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 74),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    // Splash background fades out at very end
    _splashOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 84),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 16),
    ]).animate(_controller);

    _controller.forward().then((_) {
      if (mounted) {
        setState(() => _showApp = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showApp) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: [
            widget.child,
            Opacity(
              opacity: _splashOpacity.value,
              child: Container(
                color: const Color(0xFF0A0A0F),
                child: Center(
                  child: Opacity(
                    opacity: _logoOpacity.value,
                    child: Image.asset(
                      'assets/images/app_logo.jpg',
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
