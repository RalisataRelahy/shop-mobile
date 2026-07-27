import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_good/features/auth/providers/auth_provider.dart';
import '../../../app/theme/app_colors.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});
  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final pseudoController = TextEditingController();
  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    pseudoController.dispose();
    phoneController.dispose();
    super.dispose();
  }
  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    await ref.read(authControllerProvider.notifier)
        .updateProfile(
          pseudo: pseudoController.text.trim(),
          phone: phoneController.text.trim(),
        );
    final state = ref.read(authControllerProvider);
    if (!mounted) return;
    if (!state.hasError) {
      ref.invalidate(profileCompletedProvider);
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.error.toString(),
          ),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.person_add_alt_1,
                    size: 60,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Complétez votre profil",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Ces informations sont nécessaires "
                        "pour vos commandes et livraisons.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildField(
                    controller: pseudoController,
                    label: "Pseudo",
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: phoneController,
                    label: "Numéro de téléphone",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isLoading
                          ? null : saveProfile,
                      child: isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ) : const Text(
                        "Continuer",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:16,
                          fontWeight: FontWeight.bold,
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
    );
  }
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller:controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if(value == null ||
            value.trim().isEmpty) {
          return "$label obligatoire";
        }
        return null;
      },
      decoration:
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: AppColors.primaryGreen,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.primaryGreen,
            width: 2,
          ),
        ),
      ),
    );
  }
}