import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_good/app/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_good/features/auth/providers/auth_provider.dart';
import 'package:shop_good/shared/widgets/toast_notification.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ToastNotification.showError(context, 'Veuillez remplir tous les champs');
      return;
    }

    await ref.read(authControllerProvider.notifier).login(email, password);

    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      if (mounted) {
        ToastNotification.showError(context, 'Identifiants incorrects');
      }
    } else {
      if (mounted) {
        ToastNotification.showSuccess(context, 'Connexion réussie !');
      }
    }
  }

  /// Facteur d'échelle typographique/espacements selon la largeur de l'écran.
  /// - < 360  : très petits téléphones
  /// - 360-600 : téléphones standards (référence)
  /// - 600-900 : phablettes / petites tablettes
  /// - > 900  : tablettes / desktop
  double _scaleFactor(double width) {
    if (width < 360) return 0.92;
    if (width < 600) return 1.0;
    if (width < 900) return 1.1;
    return 1.2;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = MediaQuery.of(context).size;
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            final bool isSmallScreen = width < 600;
            final bool isWideScreen = width > 900;
            final double scale = _scaleFactor(width);

            // Tailles adaptatives
            final double titleFontSize = (isSmallScreen ? 24 : 28) * scale.clamp(0.9, 1.15);
            final double subtitleFontSize = (14 * scale).clamp(13.0, 17.0);
            final double bodyFontSize = (14 * scale).clamp(13.0, 16.0);
            final double buttonFontSize = (16 * scale).clamp(15.0, 19.0);
            final double buttonHeight = (54 * scale).clamp(50.0, 66.0);
            final double fieldRadius = (16 * scale).clamp(14.0, 20.0);
            final double horizontalGutter = isWideScreen
                ? width * 0.20
                : (isSmallScreen ? 20.0 : width * 0.10);

            // Hauteur de la section image, plafonnée pour ne pas
            // envahir l'écran sur les formats très hauts/étroits.
            final double imageHeight = (height * (isSmallScreen ? 0.30 : 0.35))
                .clamp(180.0, 380.0);

            // Contenu centré avec largeur max sur grand écran (tablette/desktop)
            final double contentMaxWidth = isWideScreen ? 640.0 : double.infinity;

            Widget content = SingleChildScrollView(
              child: Column(
                children: [
                  // Section image du haut (Responsive height)
                  Stack(
                    children: [
                      Container(
                        height: imageHeight,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/hamburger.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                Colors.transparent,
                                AppColors.backgroundOffWhite.withValues(alpha: 0.7),
                                AppColors.backgroundOffWhite,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 24,
                        right: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bon retour parmis nous!',
                              style: GoogleFonts.poppins(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Connectez-vous pour continuer',
                              style: GoogleFonts.poppins(
                                fontSize: subtitleFontSize,
                                color: Colors.black54,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Formulaire
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalGutter,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        // Champ Email
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          icon: Icons.email_outlined,
                          fontSize: bodyFontSize,
                          radius: fieldRadius,
                        ),
                        SizedBox(height: 14 * scale),

                        // Champ Password
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'Mot de passe',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          fontSize: bodyFontSize,
                          radius: fieldRadius,
                        ),
                        const SizedBox(height: 6),

                        // Mot de passe oublié
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Mot de passe oublié?',
                              style: GoogleFonts.poppins(
                                fontSize: (13 * scale).clamp(12.0, 15.0),
                                color: AppColors.mediumGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16 * scale),

                        // Information réduction (discrète, neutre)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.local_offer_outlined,
                              size: (14 * scale).clamp(13.0, 18.0),
                              color: AppColors.mediumGrey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Bénéficiez de 5 % de réduction sur toutes vos commandes en vous connectant.',
                                style: GoogleFonts.poppins(
                                  fontSize: (11.5 * scale).clamp(11.0, 14.0),
                                  color: AppColors.mediumGrey,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 28 * scale),

                        // Bouton Connexion
                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: authState.isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(fieldRadius),
                              ),
                              elevation: 0,
                            ),
                            child: authState.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                              'Se connecter',
                              style: GoogleFonts.poppins(
                                fontSize: buttonFontSize,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20 * scale),

                        // Pas encore de compte
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Pas encore de compte? ',
                              style: GoogleFonts.poppins(
                                fontSize: (13.5 * scale).clamp(13.0, 16.0),
                                color: Colors.grey.shade600,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push('/signup'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'S\'inscrire',
                                style: GoogleFonts.poppins(
                                  fontSize: (13.5 * scale).clamp(13.0, 16.0),
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24 * scale),

                        // Séparateur
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: AppColors.lightGrey,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Ou continuer avec',
                                style: GoogleFonts.poppins(
                                  color: AppColors.mediumGrey,
                                  fontSize: (13 * scale).clamp(12.0, 15.0),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: AppColors.lightGrey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24 * scale),

                        // Boutons Sociaux
                        Row(
                          children: [
                            Expanded(
                              child: _buildSocialButtonWithImage(
                                label: 'Google',
                                onTap: () {},
                                fontSize: (13.5 * scale).clamp(13.0, 16.0),
                                radius: fieldRadius,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildSocialButton(
                                label: 'Facebook',
                                iconPath: Icons.facebook,
                                onTap: () {},
                                fontSize: (13.5 * scale).clamp(13.0, 16.0),
                                radius: fieldRadius,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32 * scale),

                        // Continuer en tant qu'invité
                        Center(
                          child: GestureDetector(
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continuer en tant qu\'invité',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.mediumGrey,
                                    fontSize: (13.5 * scale).clamp(13.0, 16.0),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_outlined,
                                  color: AppColors.mediumGrey,
                                  size: (16 * scale).clamp(15.0, 19.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24 * scale),
                      ],
                    ),
                  ),
                ],
              ),
            );

            // Sur grand écran, centre le contenu et limite sa largeur
            if (isWideScreen) {
              content = Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: content,
                ),
              );
            }

            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height),
              child: content,
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    double fontSize = 14,
    double radius = 16,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _isPasswordObscured : false,
        style: GoogleFonts.poppins(fontSize: fontSize),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: fontSize,
            color: AppColors.mediumGrey,
          ),
          prefixIcon: Icon(icon, color: AppColors.mediumGrey, size: 20),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _isPasswordObscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.mediumGrey,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isPasswordObscured = !_isPasswordObscured;
              });
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }

  Widget _buildSocialButtonWithImage({
    required String label,
    required VoidCallback onTap,
    double fontSize = 13.5,
    double radius = 16,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(radius),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/google.svg', // Le chemin exact défini dans le pubspec.yaml
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: fontSize,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData iconPath,
    required VoidCallback onTap,
    double fontSize = 13.5,
    double radius = 16,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(radius),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconPath,
              size: 24,
              color: label == 'Facebook' ? Colors.blue : Colors.red,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: fontSize,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}