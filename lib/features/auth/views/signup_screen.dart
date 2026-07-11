import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_good/app/theme/app_colors.dart';
import 'package:shop_good/features/auth/providers/auth_provider.dart';
import 'package:shop_good/shared/widgets/toast_notification.dart';

import '../../../shared/services/nominatim_service.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  bool _isPasswordObscured = true;

  // Indicatifs téléphoniques courants
  final List<Map<String, String>> _countryCodes = const [
    {'code': '+261', 'flag': '🇲🇬'}, // Madagascar
    {'code': '+33', 'flag': '🇫🇷'},
    {'code': '+1', 'flag': '🇺🇸'},
    {'code': '+44', 'flag': '🇬🇧'},
  ];
  String _selectedCode = '+261';

  @override
  void dispose() {
    _pseudoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('0')) {
      return phoneNumber.substring(1);
    }
    return phoneNumber;
  }

  Future<void> _signUp() async {
    final pseudo = _pseudoController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.isEmpty) {
      ToastNotification.showError(context, 'Veuillez remplir tous les champs');
      return;
    }
    final formattedPhone = _formatPhoneNumber(rawPhone);
    final phone = '$_selectedCode$formattedPhone';

    if (pseudo.isEmpty || email.isEmpty || password.isEmpty) {
      await ref.read(authControllerProvider.notifier).signUp(
            email: email,
            password: password,
            pseudo: pseudo,
            phone: phone,
          );
      final state = ref.read(authControllerProvider);
      if (state.hasError) {
        if (mounted) {
          ToastNotification.showError(context, 'Erreur: ${state.error}');
        }
      } else {
        if (mounted) {
          ToastNotification.showSuccess(context, 'Compte créé avec succès !');
          // Redirection gérée par le router
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 600;
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section image du haut (Responsive height)
            Stack(
              children: [
                Container(
                  height: size.height * (isSmallScreen ? 0.28 : 0.36),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/hamburger.jpg'),
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

                // Bouton retour
                Positioned(
                  top: 16,
                  left: 16,
                  child: SafeArea(
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(10),
                        elevation: 1,
                      ),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                // Titre et sous-titre
                Positioned(
                  bottom: 10,
                  left: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Créer un compte',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 24 : 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Rejoignez-nous en quelques secondes',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
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
                horizontal: isSmallScreen ? 20.0 : size.width * 0.10,
                vertical: 12,
              ),
              child: Column(
                children: [
                  // 1. Champ Pseudo
                  _buildTextField(
                    controller: _pseudoController,
                    hintText: 'Pseudo',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),

                  // 2. Champ Email
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),

                  // 3. Champ Mot de passe
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Mot de passe',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 6),

                  // Note discrète
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 14,
                        color: AppColors.mediumGrey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '8 caractères minimum, avec au moins un chiffre.',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: AppColors.mediumGrey,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 4. Champ Contact
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        const Icon(
                          Icons.phone_outlined,
                          color: AppColors.mediumGrey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        // Sélecteur d'indicatif
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCode,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.mediumGrey,
                              size: 18,
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            items: _countryCodes.map((c) {
                              return DropdownMenuItem<String>(
                                value: c['code'],
                                child: Text('${c['flag']}  ${c['code']}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedCode = value);
                              }
                            },
                          ),
                        ),
                        Container(
                          height: 24,
                          width: 1,
                          color: AppColors.lightGrey,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        // Numéro
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.poppins(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Numéro de contact',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.mediumGrey,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 5. Champ Adresse
                  TypeAheadField<Map<String, dynamic>>(
                    controller: _addressController,
                    suggestionsCallback: (search) async {
                      return await NominatimService().search(search);
                    },
                    builder: (context, controller, focusNode) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                          focusNode: focusNode,
                          keyboardType: TextInputType.streetAddress,
                          style: GoogleFonts.poppins(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Adresse où vous souhaitez livrer frequament",
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.mediumGrey,
                            ),
                            prefixIcon: const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.mediumGrey,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(18),
                          ),
                        ),
                      );
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primaryGreen,
                        ),
                        title: Text(
                          suggestion["display_name"] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                    onSelected: (suggestion) {
                      _addressController.text = suggestion["display_name"] ?? '';
                    },
                  ),
                  const SizedBox(height: 28),

                  // Bouton S'inscrire
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: authState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'S\'inscrire',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Déjà un compte
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Déjà un compte? ',
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Se connecter',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
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
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }
}
