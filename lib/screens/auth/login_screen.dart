import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sign_button/sign_button.dart';
import 'package:tracker/providers/auth_service_provider.dart';
import 'package:tracker/utils/app_logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Controller for the endless background animation
  late AnimationController _backgroundController;

  String _version = '1.0.0';

  @override
  void initState() {
    super.initState();
    _initVersion();
    // 1. Entrance Animations (One shot)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _entranceController.forward();

    // 2. Continuous Background Animation (Looping)
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // Slow, smooth rotation
    )..repeat(); // Continuously repeats from 0.0 to 1.0
  }

  Future<void> _initVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _loginWithGoogle(BuildContext context) async {
    try {
      await context.read<AuthServiceProvider>().signInWithGoogle();
    } catch (e) {
      AppLogger.log(e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _loginWithApple(BuildContext context) async {
    try {
      await context.read<AuthServiceProvider>().signInWithApple();
    } catch (e) {
      AppLogger.log(e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Calculate relative positions for the orbital animation
    // We use the same controller but different math functions to create independent movement patterns
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      body: Stack(
        children: [
          // 1. Static Base Background
          Container(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          ),

          // 2. Animated Flowing Mesh Gradient
          // We use varying alignment and scale to create a "liquid" feel
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              final t = _backgroundController.value;
              return Stack(
                children: [
                  // Orb 1: Primary Color - Large slow spiral
                  _AnimatedOrb(
                    color: colorScheme.primary,
                    alignment: Alignment(
                      math.cos(t * 2 * math.pi) * 0.7,
                      math.sin(t * 2 * math.pi) * 0.5,
                    ),
                    radius: 400,
                  ),

                  // Orb 2: Secondary Color - Moving crosswise
                  _AnimatedOrb(
                    color: colorScheme.secondary,
                    alignment: Alignment(
                      // Moves side to side in a sine wave, offset by PI
                      math.sin((t * 2 * math.pi) + math.pi),
                      // Moves up and down twice as fast
                      math.cos(t * 4 * math.pi) * 0.8,
                    ),
                    radius: 350,
                  ),

                  // Orb 3: Tertiary Color - Random-ish floating
                  _AnimatedOrb(
                    color: colorScheme.tertiary,
                    alignment: Alignment(
                      math.cos((t * 2 * math.pi) + math.pi / 2) * 0.9,
                      math.sin((t * 3 * math.pi)) * 0.6,
                    ),
                    radius: 300,
                  ),

                  // Orb 4: Subtle Highlight - Counter Rotation
                  _AnimatedOrb(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                    alignment: Alignment(
                      math.sin(-(t * 2 * math.pi)) * 0.4,
                      math.cos(-(t * 2 * math.pi)) * 0.4,
                    ),
                    radius: 200,
                  ),
                ],
              );
            },
          ),

          // 3. Blur Mesh Overlay (Blends the orbs into a gradient)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.transparent),
          ),

          // 4. Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Icon with Pulse (synced to background loop)
                            AnimatedBuilder(
                              animation: _backgroundController,
                              builder: (context, child) {
                                final pulse =
                                    (math.sin(
                                          _backgroundController.value *
                                              4 *
                                              math.pi,
                                        ) +
                                        1) /
                                    2; // 0 to 1 oscillating
                                return Transform.scale(
                                  scale: 1.0 + (pulse * 0.05),
                                  child: Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin:
                                            Alignment.topLeft +
                                            Alignment(pulse * 0.2, 0),
                                        end: Alignment.bottomRight,
                                        colors: [
                                          colorScheme.primary.withValues(
                                            alpha: 0.9,
                                          ),
                                          colorScheme.primary,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.primary.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 20 + (pulse * 10),
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/image/splash_transparent.png',
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 48),

                            // Glass Card
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color:
                                        (isDark ? Colors.black : Colors.white)
                                            .withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      width: 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Welcome Back',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface,
                                              letterSpacing: 0.5,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Sign in to continue your journey',
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: colorScheme.onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                      ),
                                      const SizedBox(height: 40),

                                      // Login Buttons
                                      _SocialLoginButton(
                                        text: 'Sign in with Google',
                                        buttonType: ButtonType.google,
                                        onPressed: () =>
                                            _loginWithGoogle(context),
                                      ),
                                      if (Platform.isIOS) ...[
                                        const SizedBox(height: 16),
                                        _SocialLoginButton(
                                          text: 'Sign in with Apple',
                                          buttonType: ButtonType.apple,
                                          onPressed: () =>
                                              _loginWithApple(context),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: SafeArea(
              top: false,
              child: Text(
                'Version $_version',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedOrb extends StatelessWidget {
  const _AnimatedOrb({
    required this.color,
    required this.alignment,
    required this.radius,
  });

  final Color color;
  final Alignment alignment;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.text,
    required this.buttonType,
    required this.onPressed,
  });
  final String text;
  final ButtonType buttonType;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54, // Slightly taller
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: UnconstrainedBox(
          constrainedAxis: Axis.vertical,
          child: SignInButton(
            buttonType: buttonType,
            btnText: text,
            buttonSize: ButtonSize.large,
            elevation: 0, // Flat elegant look
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18), // Softer corners
              side: BorderSide(
                color: Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
