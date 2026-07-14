import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop_good/features/profile/views/profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Rappel de votre charte graphique
  static const Color greenApple = Color(0xFF4CD964);
  static const Color lightGrey = Color(0xFFE5E5EA);
  static const Color offWhite = Color(0xFFF9F9F6);
  static const Color darkText = Color(0xFF2C2C2E);

  // Fonctions natives gratuites pour interagir avec le smartphone
  Future<void> _openMap() async {
    // Coordonnées GPS validées précédemment à Ankadikely
    final Uri url = Uri.parse('https://google.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makeCall() async {
    final Uri url = Uri(scheme: 'tel', path: '+261387516864');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  /// Facteur d'échelle selon la largeur de l'écran.
  /// - < 360  : très petits téléphones
  /// - 360-600 : téléphones standards (référence)
  /// - 600-900 : phablettes / petites tablettes
  /// - > 900  : tablettes / desktop
  double _scaleFactor(double width) {
    if (width < 360) return 0.9;
    if (width < 600) return 1.0;
    if (width < 900) return 1.1;
    return 1.2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offWhite,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final bool isWideScreen = width > 900;
          final double horizontalPadding = width < 360 ? 12.0 : 20.0;
          final double scale = _scaleFactor(width);
          final double logoSize = (200 * scale).clamp(160.0, 260.0);
          final double contentMaxWidth = isWideScreen ? 700.0 : double.infinity;

          Widget pageContent = Column(
            children: [
              // --- SECTION 1 : LOGO & IDENTITÉ ---
              Center(
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/logo.svg',
                      width: logoSize,
                      height: logoSize,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildCardSection(
                  icon: Icons.person,
                  title: 'Info personnel',
                  child: ProfileWidget(),
                  scale: scale),
              const SizedBox(height: 30),
              // --- SECTION 2 : CONCEPT RESTAURANT / BAR ---
              _buildCardSection(
                icon: Icons.restaurant_menu,
                title: "Notre Concept",
                scale: scale,
                child: Text(
                  "Bienvenue dans notre espace hybride unique. Côté Cuisine, nous vous proposons des plats gourmands cuisinés avec des produits frais locaux. Côté Bar, profitez de notre ambiance lounge avec une sélection exclusive de cocktails, boissons fraîches et mocktails faits maison pour animer vos fins de journées.",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: (13.5 * scale).clamp(13.0, 16.0),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- SECTION 3 : INFOS PRATIQUES ---
              _buildCardSection(
                icon: Icons.info_outline,
                title: "Informations Pratiques",
                scale: scale,
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.access_time,
                      "Horaires d'ouverture",
                      "Mardi - Dimanche : 11h00 - 23h00\nLundi : Fermé",
                      scale,
                    ),
                    const Divider(color: lightGrey, height: 24),
                    _buildInfoRow(
                      Icons.payments_outlined,
                      "Modes de règlement acceptés",
                      "Espèces, Mobile Money (Mvola, Orange Money, Airtel Money)",
                      scale,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- SECTION 4 : LOCALISATION & CONTACT ---
              _buildCardSection(
                icon: Icons.call,
                title: "Nous Contacter & Nous Trouver",
                scale: scale,
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      "Adresse",
                      "Soanierana, Antananarivo, Madagascar, 101",
                      scale,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _openMap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: lightGrey,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: Icon(Icons.map, color: darkText, size: (18 * scale).clamp(16.0, 22.0)),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Y aller",
                                maxLines: 1,
                                style: TextStyle(
                                  color: darkText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: (13 * scale).clamp(12.0, 16.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _makeCall,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greenApple,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: Icon(Icons.phone, color: Colors.white, size: (18 * scale).clamp(16.0, 22.0)),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Appeler",
                                maxLines: 1,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: (13 * scale).clamp(12.0, 16.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- FOOTER VERSION ---
              Text(
                "Version 1.0.0",
                style: TextStyle(color: Colors.grey[400], fontSize: (11 * scale).clamp(10.0, 13.0)),
              ),
              Text(
                "© 2026 Tous droits réservés à l'entreprise",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: (11 * scale).clamp(10.0, 13.0)),
              ),
            ],
          );

          // Sur grand écran (tablette/desktop), on centre le contenu et on
          // limite sa largeur pour éviter des cartes qui s'étirent à
          // l'infini et deviennent difficiles à lire.
          if (isWideScreen) {
            pageContent = Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: pageContent,
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
            child: pageContent,
          );
        },
      ),
    );
  }

  // Composant d'organisation : Conteneur blanc propre pour chaque bloc
  Widget _buildCardSection({
    required IconData icon,
    required String title,
    required Widget child,
    required double scale,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lightGrey, width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: (18 * scale).clamp(16.0, 22.0)),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: (15 * scale).clamp(14.0, 19.0),
                    color: darkText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // Composant de ligne d'information iconographique
  Widget _buildInfoRow(IconData icon, String title, String subtitle, double scale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: greenApple, size: (22 * scale).clamp(20.0, 27.0)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: (13 * scale).clamp(12.0, 16.0),
                  color: darkText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: (12.5 * scale).clamp(12.0, 15.0),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}