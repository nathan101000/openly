import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late AnimationController _unlockController;
  late AnimationController _textController;
  late AnimationController _loadingController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scanAnimation;
  late Animation<double> _unlockScaleAnimation;
  late Animation<double> _unlockRotationAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _textOffsetAnimation;

  String animationPhase = 'start';

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scanController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _unlockController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Initialize animations
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );

    _unlockScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _unlockController, curve: Curves.easeOutBack),
    );

    _unlockRotationAnimation = Tween<double>(begin: -0.17, end: 0.0).animate(
      CurvedAnimation(parent: _unlockController, curve: Curves.easeOutBack),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _textOffsetAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Start animation sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Phase 1: Initial scale and opacity (200ms delay)
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => animationPhase = 'pulse');
    _mainController.forward();

    // Phase 2: Pulse animation (800ms delay)
    await Future.delayed(const Duration(milliseconds: 600));
    _pulseController.repeat(reverse: true);

    // Phase 3: Scan animation (1400ms delay)
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => animationPhase = 'scan');
    _pulseController.stop();
    _scanController.forward();

    // Phase 4: Unlock animation (2000ms delay)
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => animationPhase = 'unlock');
    _unlockController.forward();

    // Phase 5: Text fade-in (2600ms delay)
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => animationPhase = 'fadeInText');
    _textController.forward();
    _loadingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _scanController.dispose();
    _unlockController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A), // slate-900
              Color(0xFF1E293B), // slate-800
              Color(0xFF0F172A), // slate-900
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x800F172A), // slate-900/50
                    Color(0x331E3A8A), // blue-900/20
                    Color(0xFF0F172A), // slate-900
                  ],
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Fingerprint/Lock Icon Container
                  Container(
                    width: 128,
                    height: 128,
                    margin: const EdgeInsets.only(bottom: 64),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Fingerprint with animations
                        if (animationPhase != 'unlock')
                          AnimatedBuilder(
                            animation: _mainController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Opacity(
                                  opacity: _opacityAnimation.value,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Glowing effect
                                      AnimatedBuilder(
                                        animation: _pulseController,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: animationPhase == 'pulse'
                                                ? _pulseAnimation.value
                                                : 1.0,
                                            child: Container(
                                              width: 128,
                                              height: 128,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: RadialGradient(
                                                  colors: [
                                                    const Color(
                                                        0x4D22D3EE,), // cyan-400/30
                                                    Colors.transparent,
                                                  ],
                                                  stops: const [0.0, 0.7],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      // Fingerprint icon (using a custom fingerprint icon)
                                      ColorFiltered(
                                        colorFilter: ColorFilter.mode(
                                          animationPhase == 'pulse' ||
                                                  animationPhase == 'scan'
                                              ? const Color(0xFF22D3EE)
                                                  .withOpacity(0.9)
                                              : const Color(0xFF22D3EE),
                                          BlendMode.srcIn,
                                        ),
                                        child: const Icon(
                                          Icons.fingerprint,
                                          size: 80,
                                          color: Color(0xFF22D3EE),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                        // Scan Line
                        if (animationPhase == 'scan')
                          AnimatedBuilder(
                            animation: _scanController,
                            builder: (context, child) {
                              return Positioned(
                                top: 128 * _scanAnimation.value - 2,
                                left: 0,
                                right: 0,
                                child: Opacity(
                                  opacity:
                                      _getScanLineOpacity(_scanAnimation.value),
                                  child: Container(
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Color(0xFF22D3EE), // cyan-400
                                          Colors.transparent,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF22D3EE),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                        // Unlocked Padlock
                        if (animationPhase == 'unlock')
                          AnimatedBuilder(
                            animation: _unlockController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _unlockScaleAnimation.value,
                                child: Transform.rotate(
                                  angle: _unlockRotationAnimation.value,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Glowing effect for unlock icon
                                      Container(
                                        width: 128,
                                        height: 128,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              const Color(
                                                  0x3322D3EE,), // cyan-400/20
                                              Colors.transparent,
                                            ],
                                            stops: const [0.0, 0.7],
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.lock_open,
                                        size: 80,
                                        color: Color(0xFF22D3EE),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  // App Name and Tagline
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _textOffsetAnimation.value),
                        child: Opacity(
                          opacity: _textOpacityAnimation.value,
                          child: Column(
                            children: [
                              // App Name
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Color(0xFFA5F3FC), // cyan-200
                                    Colors.white,
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  'Openly',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Tagline
                              const Text(
                                'Seamless Access. Secured by You.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFCBD5E1), // slate-300
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Loading indicator
            if (animationPhase == 'fadeInText')
              Positioned(
                bottom: 64,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textOpacityAnimation.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return AnimatedBuilder(
                            animation: _loadingController,
                            builder: (context, child) {
                              final delayedValue =
                                  (_loadingController.value - (index * 0.2))
                                      .clamp(0.0, 1.0);
                              final scale = 1.0 +
                                  (0.2 *
                                      (0.5 - (delayedValue - 0.5).abs()) *
                                      2);

                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          const Color(0xFF22D3EE).withOpacity(
                                        0.5 + (0.5 * scale - 0.5) * 2,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _getScanLineOpacity(double progress) {
    if (progress <= 0.1) {
      return progress / 0.1; // Fade in
    } else if (progress >= 0.9) {
      return (1.0 - progress) / 0.1; // Fade out
    } else {
      return 1.0; // Full opacity
    }
  }
}
