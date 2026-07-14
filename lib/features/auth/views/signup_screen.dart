import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _SignupScreenState extends ConsumerState<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final FocusNode _pseudoFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();

  bool _isPasswordObscured = true;
  bool _isSubmitting = false;

  // Indicatifs téléphoniques courants
  final List<Map<String, String>> _countryCodes = const [
    {'code': '+261', 'flag': '🇲🇬'}, // Madagascar
    {'code': '+33', 'flag': '🇫🇷'},
    {'code': '+1', 'flag': '🇺🇸'},
    {'code': '+44', 'flag': '🇬🇧'},
  ];
  String _selectedCode = '+261';

  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _digitRegex = RegExp(r'\d');

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));

    // Rafraîchit le bouton "S'inscrire" en direct pendant la saisie,
    // sans re-valider tout le formulaire à chaque frappe.
    for (final c in [
      _pseudoController,
      _emailController,
      _passwordController,
      _phoneController,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _entrance.dispose();
    _pseudoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _pseudoFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('0')) {
      return phoneNumber.substring(1);
    }
    return phoneNumber;
  }

  bool get _isPasswordStrongEnough {
    final p = _passwordController.text;
    return p.length >= 8 && _digitRegex.hasMatch(p);
  }

  // Contrôle léger et immédiat pour activer/désactiver le bouton,
  // en plus de la validation complète faite par le Form à la soumission.
  bool get _canSubmit {
    return _pseudoController.text.trim().isNotEmpty &&
        _emailRegex.hasMatch(_emailController.text.trim()) &&
        _isPasswordStrongEnough &&
        _phoneController.text.trim().length >= 7;
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid || !_canSubmit) {
      HapticFeedback.mediumImpact();
      return;
    }

    setState(() => _isSubmitting = true);

    final pseudo = _pseudoController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final rawPhone = _phoneController.text.trim();
    final formattedPhone = _formatPhoneNumber(rawPhone);
    final phone = '$_selectedCode$formattedPhone';

    await ref.read(authControllerProvider.notifier).signUp(
      email: email,
      password: password,
      pseudo: pseudo,
      phone: phone,
    );

    if (!mounted) return;

    final state = ref.read(authControllerProvider);
    setState(() => _isSubmitting = false);

    if (state.hasError) {
      ToastNotification.showError(context, 'Erreur: ${state.error}');
    } else {
      ToastNotification.showSuccess(context, 'Compte créé avec succès !');
      // Redirection gérée par le router
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
    final isLoading = authState.isLoading || _isSubmitting;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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

              // Hauteur de la section image, plafonnée
              final double imageHeight = (height * (isSmallScreen ? 0.28 : 0.32))
                  .clamp(160.0, 340.0);

              final double contentMaxWidth = isWideScreen ? 640.0 : double.infinity;

              Widget content = SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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

                              // Bouton retour
                              Positioned(
                                top: 16,
                                left: 16,
                                child: IconButton(
                                  onPressed: isLoading ? null : () => Navigator.of(context).maybePop(),
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

                              // Titre et sous-titre
                              Positioned(
                                bottom: 10,
                                left: 24,
                                right: 24,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Créer un compte',
                                      style: GoogleFonts.poppins(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Rejoignez-nous en quelques secondes',
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
                                // 1. Champ Pseudo
                                _buildTextField(
                                  controller: _pseudoController,
                                  focusNode: _pseudoFocus,
                                  nextFocusNode: _emailFocus,
                                  hintText: 'Pseudo',
                                  icon: Icons.person_outline,
                                  fontSize: bodyFontSize,
                                  radius: fieldRadius,
                                  enabled: !isLoading,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Pseudo requis';
                                    if (v.trim().length < 2) return 'Pseudo trop court';
                                    return null;
                                  },
                                ),
                                SizedBox(height: 14 * scale),

                                // 2. Champ Email
                                _buildTextField(
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  nextFocusNode: _passwordFocus,
                                  hintText: 'Email',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  fontSize: bodyFontSize,
                                  radius: fieldRadius,
                                  enabled: !isLoading,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) {
                                    final value = v?.trim() ?? '';
                                    if (value.isEmpty) return 'Email requis';
                                    if (!_emailRegex.hasMatch(value)) return 'Email invalide';
                                    return null;
                                  },
                                ),
                                SizedBox(height: 14 * scale),

                                // 3. Champ Mot de passe
                                _buildTextField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  nextFocusNode: _phoneFocus,
                                  hintText: 'Mot de passe',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  fontSize: bodyFontSize,
                                  radius: fieldRadius,
                                  enabled: !isLoading,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) {
                                    final value = v ?? '';
                                    if (value.isEmpty) return 'Mot de passe requis';
                                    if (value.length < 8) return '8 caractères minimum';
                                    if (!_digitRegex.hasMatch(value)) return 'Au moins un chiffre';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 6),

                                // Note discrète, devient verte quand le critère est rempli
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      child: Icon(
                                        _isPasswordStrongEnough
                                            ? Icons.check_circle_outline
                                            : Icons.info_outline,
                                        key: ValueKey(_isPasswordStrongEnough),
                                        size: (14 * scale).clamp(13.0, 18.0),
                                        color: _isPasswordStrongEnough
                                            ? AppColors.primaryGreen
                                            : AppColors.mediumGrey,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 200),
                                        style: GoogleFonts.poppins(
                                          fontSize: (11.5 * scale).clamp(11.0, 14.0),
                                          color: _isPasswordStrongEnough
                                              ? AppColors.primaryGreen
                                              : AppColors.mediumGrey,
                                          height: 1.3,
                                        ),
                                        child: const Text(
                                          '8 caractères minimum, avec au moins un chiffre.',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 14 * scale),

                                // 4. Champ Contact
                                _PhoneField(
                                  controller: _phoneController,
                                  focusNode: _phoneFocus,
                                  nextFocusNode: _addressFocus,
                                  fieldRadius: fieldRadius,
                                  bodyFontSize: bodyFontSize,
                                  scale: scale,
                                  enabled: !isLoading,
                                  selectedCode: _selectedCode,
                                  countryCodes: _countryCodes,
                                  onCodeChanged: (value) {
                                    setState(() => _selectedCode = value);
                                  },
                                  validator: (v) {
                                    final value = v?.trim() ?? '';
                                    if (value.isEmpty) return 'Numéro requis';
                                    if (value.length < 7) return 'Numéro trop court';
                                    return null;
                                  },
                                ),
                                SizedBox(height: 14 * scale),

                                // 5. Champ Adresse
                                TypeAheadField<Map<String, dynamic>>(
                                  controller: _addressController,
                                  focusNode: _addressFocus,
                                  suggestionsCallback: (search) async {
                                    if (search.trim().length < 3) return const [];
                                    return await NominatimService().search(search);
                                  },
                                  builder: (context, controller, focusNode) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(fieldRadius),
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
                                        enabled: !isLoading,
                                        keyboardType: TextInputType.streetAddress,
                                        textInputAction: TextInputAction.done,
                                        onSubmitted: (_) => _signUp(),
                                        style: GoogleFonts.poppins(fontSize: bodyFontSize),
                                        decoration: InputDecoration(
                                          hintText:
                                          "Adresse où vous souhaitez livrer fréquemment",
                                          hintStyle: GoogleFonts.poppins(
                                            fontSize: bodyFontSize,
                                            color: AppColors.mediumGrey,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.location_on_outlined,
                                            color: AppColors.mediumGrey,
                                            size: (20 * scale).clamp(18.0, 24.0),
                                          ),
                                          suffixIcon: controller.text.isNotEmpty
                                              ? IconButton(
                                            icon: const Icon(Icons.close, size: 18),
                                            color: AppColors.mediumGrey,
                                            onPressed: () {
                                              controller.clear();
                                              setState(() {});
                                            },
                                          )
                                              : null,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(fieldRadius),
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
                                          fontSize: bodyFontSize,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  },
                                  onSelected: (suggestion) {
                                    _addressController.text =
                                        suggestion["display_name"] ?? '';
                                    setState(() {});
                                  },
                                ),
                                SizedBox(height: 28 * scale),

                                // Bouton S'inscrire
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: (_canSubmit && !isLoading) ? 1.0 : 0.55,
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: buttonHeight,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : _signUp,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryGreen,
                                        disabledBackgroundColor: AppColors.primaryGreen,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(fieldRadius),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: isLoading
                                          ? SizedBox(
                                        width: buttonFontSize,
                                        height: buttonFontSize,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.4,
                                        ),
                                      )
                                          : Text(
                                        'S\'inscrire',
                                        style: GoogleFonts.poppins(
                                          fontSize: buttonFontSize,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20 * scale),

                                // Déjà un compte
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'Déjà un compte? ',
                                      style: GoogleFonts.poppins(
                                        fontSize: (13.5 * scale).clamp(13.0, 16.0),
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: isLoading
                                          ? null
                                          : () => Navigator.of(context).maybePop(),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Se connecter',
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    bool isPassword = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    double fontSize = 14,
    double radius = 16,
    FormFieldValidator<String>? validator,
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
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        obscureText: isPassword ? _isPasswordObscured : false,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onFieldSubmitted: (_) {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          } else {
            _signUp();
          }
        },
        style: GoogleFonts.poppins(fontSize: fontSize),
        validator: validator,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
          ),
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }
}

/// Champ téléphone (indicatif + numéro) avec validation intégrée.
/// Extrait en widget séparé pour bénéficier de FormField et afficher
/// un message d'erreur cohérent avec les autres champs.
class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final double fieldRadius;
  final double bodyFontSize;
  final double scale;
  final bool enabled;
  final String selectedCode;
  final List<Map<String, String>> countryCodes;
  final ValueChanged<String> onCodeChanged;
  final FormFieldValidator<String>? validator;

  const _PhoneField({
    required this.controller,
    required this.focusNode,
    required this.nextFocusNode,
    required this.fieldRadius,
    required this.bodyFontSize,
    required this.scale,
    required this.enabled,
    required this.selectedCode,
    required this.countryCodes,
    required this.onCodeChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (_) => validator?.call(controller.text),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(fieldRadius),
                border: state.hasError
                    ? Border.all(color: Colors.redAccent, width: 1)
                    : null,
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
                  Icon(
                    Icons.phone_outlined,
                    color: AppColors.mediumGrey,
                    size: (20 * scale).clamp(18.0, 24.0),
                  ),
                  const SizedBox(width: 8),
                  // Sélecteur d'indicatif
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCode,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.mediumGrey,
                        size: 18,
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: bodyFontSize,
                        color: Colors.black87,
                      ),
                      items: countryCodes.map((c) {
                        return DropdownMenuItem<String>(
                          value: c['code'],
                          child: Text('${c['flag']}  ${c['code']}'),
                        );
                      }).toList(),
                      onChanged: enabled
                          ? (value) {
                        if (value != null) onCodeChanged(value);
                      }
                          : null,
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
                      controller: controller,
                      focusNode: focusNode,
                      enabled: enabled,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => state.didChange(controller.text),
                      onSubmitted: (_) {
                        if (nextFocusNode != null) {
                          FocusScope.of(context).requestFocus(nextFocusNode);
                        }
                      },
                      style: GoogleFonts.poppins(fontSize: bodyFontSize),
                      decoration: InputDecoration(
                        hintText: 'Numéro de contact',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: bodyFontSize,
                          color: AppColors.mediumGrey,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              child: state.hasError
                  ? Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  state.errorText ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.redAccent,
                  ),
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}