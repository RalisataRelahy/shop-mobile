import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shop_good/app/theme/app_colors.dart';
import 'package:shop_good/features/auth/providers/auth_provider.dart';

// Changement du nom pour refléter que c'est un Widget interne
class ProfileWidget extends ConsumerWidget {
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final user = ref.watch(currentUserProvider);

    // On retourne directement la gestion d'état sans Scaffold ni AppBar
    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return const Center(child: Text('Profil non trouvé'));
        }

        // SingleChildScrollView est conservé pour éviter les bugs de débordement (Overflow)
        return SingleChildScrollView(
          padding: const EdgeInsets.only(top:20,bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                profile.pseudo,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                user?.email ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.mediumGrey,
                ),
              ),
              const SizedBox(height: 32),

              // Info Cards
              _buildInfoCard(
                icon: Icons.phone_outlined,
                title: 'Téléphone',
                value: profile.phone,
              ),
              const SizedBox(height: 6),
              _buildInfoCard(
                icon: Icons.calendar_today_outlined,
                title: 'Membre depuis',
                value: DateFormat('d MMMM yyyy', 'fr_FR').format(profile.createdAt),
              ),
              const SizedBox(height: 40),

              // Action Buttons
              _buildActionButton(
                icon: Icons.edit_outlined,
                label: 'Modifier le profil',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: Icons.logout_rounded,
                label: 'Se déconnecter',
                isDestructive: true,
                onTap: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Erreur: $err')),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(icon, color: AppColors.primaryGreen, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.mediumGrey,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : AppColors.primaryGreen;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
          ],
        ),
      ),
    );
  }
}
