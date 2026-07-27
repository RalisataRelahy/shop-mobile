// features/onboarding/views/onboarding_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_good/app/theme/app_colors.dart';
import 'package:shop_good/features/onBoardinPage/views/providers/on_boarding_page_providers.dart';

import '../data/mockup/on_boarding_data.dart';
import '../data/models/onBoadingModel.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  final VoidCallback onFinished;

  const OnboardingPage({super.key, required this.onFinished});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  int _currentIndex = 0;

  static const _autoScrollDuration = Duration(seconds: 3);
  static const _transitionDuration = Duration(milliseconds: 450);

  bool get _isLastPage => _currentIndex == onboardingSlides.length - 1;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(_autoScrollDuration, (_) {
      if (!mounted) return;
      if (_isLastPage) {
        _autoScrollTimer?.cancel();
        return;
      }
      _pageController.nextPage(
        duration: _transitionDuration,
        curve: Curves.easeOutCubic,
      );
    });
  }

  /// Réinitialise le timer d'auto-scroll — appelé à chaque interaction
  /// manuelle pour éviter qu'un swipe soit immédiatement "cassé" par un
  /// changement automatique de page.
  void _resetAutoScroll() {
    if (_isLastPage) {
      _autoScrollTimer?.cancel();
      return;
    }
    _startAutoScroll();
  }

  Future<void> _finishOnboarding() async {
    _autoScrollTimer?.cancel();
    await ref.read(onboardingControllerProvider).completeOnboarding();
    widget.onFinished();
  }

  void _nextPage() {
    if (_isLastPage) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: _transitionDuration,
        curve: Curves.easeOutCubic,
      );
      _resetAutoScroll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompactHeight = size.height < 700; // petits téléphones
    final isWideScreen = size.width > 600; // tablette / desktop

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // --- Slides plein écran ---
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Toute interaction manuelle (drag utilisateur) relance le timer
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                _resetAutoScroll();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingSlides.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return _OnboardingSlide(
                  slide: onboardingSlides[index],
                  isCompactHeight: isCompactHeight,
                  isWideScreen: isWideScreen,
                );
              },
            ),
          ),

          // --- Bouton "Passer" ---
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: AnimatedOpacity(
                  opacity: _isLastPage ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: _isLastPage,
                    child: TextButton(
                      onPressed: _finishOnboarding,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.25),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Passer',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- Barres de progression façon "story" (au lieu de simples dots) ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
              child: Row(
                children: List.generate(onboardingSlides.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _StoryProgressBar(
                        isActive: index == _currentIndex,
                        isCompleted: index < _currentIndex,
                        // Ne s'anime que sur le segment courant, et seulement
                        // si l'auto-scroll est encore actif (pas sur la dernière slide).
                        animate: index == _currentIndex && !_isLastPage,
                        duration: _autoScrollDuration,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // --- Contenu texte + CTA, superposés en bas avec dégradé ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24, isCompactHeight ? 60 : 90, 24, 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0),
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
              child: SafeArea(
                top: false,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWideScreen ? 480 : double.infinity),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.15),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: Column(
                          key: ValueKey(_currentIndex),
                          children: [
                            Text(
                              onboardingSlides[_currentIndex].title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isCompactHeight ? 20 : 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              onboardingSlides[_currentIndex].subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isCompactHeight ? 13 : 14.5,
                                color: Colors.white.withOpacity(0.85),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isCompactHeight ? 20 : 28),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _isLastPage ? 'Commencer' : 'Suivant',
                              key: ValueKey(_isLastPage),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isCompactHeight ? 16 : 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barre de progression façon "story" Instagram/Snapchat : se remplit
/// progressivement pendant la durée de l'auto-scroll.
class _StoryProgressBar extends StatefulWidget {
  final bool isActive;
  final bool isCompleted;
  final bool animate;
  final Duration duration;

  const _StoryProgressBar({
    required this.isActive,
    required this.isCompleted,
    required this.animate,
    required this.duration,
  });

  @override
  State<_StoryProgressBar> createState() => _StoryProgressBarState();
}

class _StoryProgressBarState extends State<_StoryProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.animate) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _StoryProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller
        ..reset()
        ..forward();
    } else if (!widget.animate) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        height: 3,
        color: Colors.white.withOpacity(0.3),
        child: Align(
          alignment: Alignment.centerLeft,
          child: widget.isCompleted
              ? const _FullBar()
              : widget.isActive
              ? AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => FractionallySizedBox(
              widthFactor: _controller.value,
              child: const _FullBar(),
            ),
          )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _FullBar extends StatelessWidget {
  const _FullBar();

  @override
  Widget build(BuildContext context) {
    return Container(width: double.infinity, height: 3, color: Colors.white);
  }
}

class _OnboardingSlide extends StatelessWidget {
  final OnboardingSlideModel slide;
  final bool isCompactHeight;
  final bool isWideScreen;

  const _OnboardingSlide({
    required this.slide,
    required this.isCompactHeight,
    required this.isWideScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      slide.imageAsset,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.darkGrey,
        alignment: Alignment.center,
        child: Icon(Icons.fastfood, size: isWideScreen ? 90 : 60, color: Colors.white.withOpacity(0.4)),
      ),
    );
  }
}