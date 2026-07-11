import 'package:flutter/material.dart';

class Carrousel extends StatefulWidget {
  const Carrousel({super.key});

  @override
  State<Carrousel> createState() => _CarrouselState();
}

class _CarrouselState extends State<Carrousel> {
  final PageController _pageController = PageController(
    viewportFraction: 0.85,
  );

  int _currentPage = 0;

  final List<Color> _couleurs = [
    const Color(0xFF34A881),
    Colors.blue.shade400,
    Colors.orange.shade400,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _couleurs.length,
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index;
              });
            },
            pageSnapping: true,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _couleurs[index],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Promotions ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        // Indicateur de page (Dots)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _couleurs.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 24 : 8, // Plus large quand actif
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF34A881)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
