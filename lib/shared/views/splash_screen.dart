import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// ---------------------------------------------------------------------------
/// SPLASH SCREEN ANIMÉ & RESPONSIVE — thème clair
/// ---------------------------------------------------------------------------
/// À placer dans lib/shared/views/splash_screen.dart
///
/// Ce widget ne navigue plus tout seul : c'est le routeur (GoRouter +
/// appInitProvider) qui décide quand quitter cet écran, une fois
/// l'initialisation terminée ET le délai minimum de 2s écoulé.
/// Le splash se contente donc de boucler ses animations indéfiniment.
///
/// Dépendances dans pubspec.yaml :
///   dependencies:
///     flutter_svg: ^2.0.10+1
///   flutter:
///     assets:
///       - assets/images/logo.svg
/// ---------------------------------------------------------------------------

// Si ces teintes existent déjà dans AppColors avec les mêmes valeurs,
// remplacez-les par AppColors.primaryGreen / AppColors.secondaryGreen /
// AppColors.offWhite pour garder une seule source de vérité.
const Color _kPrimaryGreen = Color(0xFF19A41C);
const Color _kSecondaryGreen = Color(0xFF229320);
const Color _kOffWhite = Color(0xFFFDFBF7);
const Color _kOffWhite1 = Color(0xFFF0FFF0);
const Color _kOffWhite2 = Color(0xFFDDFFDD);
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Logo : apparition une seule fois (scale + fade + rotation légère)
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoRotation;

  // Halo pulsant en arrière-plan, tourne en boucle tant que l'écran est affiché
  late final AnimationController _pulseController;

  // Indicateur de chargement, apparaît après le logo
  late final AnimationController _textController;
  late final Animation<double> _textFade;

  // Fond en dégradé animé, respiration continue
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _playIntro();
  }

  Future<void> _playIntro() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _textController.forward();

    // Pas de navigation ici : si le chargement n'est pas fini, on continue
    // simplement de tourner. C'est le router qui redirigera automatiquement
    // dès que l'app sera prête (voir appInitProvider / redirect de GoRouter).
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = math.min(size.width, size.height);
    final logoSize = (shortestSide * 0.6).clamp(120.0, 280.0);

    return Scaffold(
      backgroundColor: _kOffWhite,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _logoController,
          _pulseController,
          _textController,
          _bgController,
        ]),
        builder: (context, _) {
          // Le dégradé glisse doucement en diagonale grâce à _bgController,
          // pour donner une impression de respiration au fond clair.
          final shift = _bgController.value; // 0 -> 1 -> 0 (reverse: true)
          final begin = Alignment(-1.0 + shift * 0.4, -1.0 + shift * 0.2);
          final end = Alignment(1.0 - shift * 0.2, 1.0 - shift * 0.4);

          return Stack(
            fit: StackFit.expand,
            children: [
              // Fond en dégradé clair : blanc cassé -> vert, animé en douceur
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: begin,
                    end: end,
                    colors: const [
                      _kOffWhite,
                      _kOffWhite1,
                      _kOffWhite2,
                    ],
                    stops: const [0.0, 0.55, 1.15],
                  ),
                ),
              ),

              // Halos concentriques animés derrière le logo (boucle infinie)
              Center(
                child: SizedBox(
                  width: logoSize * 3,
                  height: logoSize * 3,
                  child: CustomPaint(
                    painter: _PulsePainter(
                      progress: _pulseController.value,
                      color: _kSecondaryGreen,
                    ),
                  ),
                ),
              ),

              // Contenu central : logo
              Center(
                child: Transform.rotate(
                  angle: _logoRotation.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoFade.value.clamp(0.0, 1.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _kPrimaryGreen
                                  .withOpacity(0.28 * _logoFade.value),
                              blurRadius: 60,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          'assets/images/logo.svg',
                          width: logoSize,
                          height: logoSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Indicateur de chargement : reste visible tant que l'écran l'est
              Positioned(
                bottom: shortestSide * 0.12,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _textFade,
                  child: Center(
                    child: SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: const AlwaysStoppedAnimation(_kPrimaryGreen),
                        backgroundColor: _kSecondaryGreen.withOpacity(0.15),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Peintre pour les halos concentriques pulsants derrière le logo.
class _PulsePainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;

  _PulsePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;

    for (int i = 0; i < 3; i++) {
      final t = ((progress + (i * 0.33)) % 1.0);
      final radius = maxRadius * (0.35 + t * 0.65);
      final opacity = (1.0 - t) * 0.22;

      final paint = Paint()
        ..color = color.withOpacity(opacity.clamp(0.0, 0.22))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) =>
      oldDelegate.progress != progress;
}