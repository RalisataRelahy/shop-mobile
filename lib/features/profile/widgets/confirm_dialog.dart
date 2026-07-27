import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_good/features/auth/providers/auth_provider.dart';

class DeleteAccountDialog extends ConsumerWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return AlertDialog(
      title: const Text("Supprimer mon compte ?"),
      content: const Text(
        "Cette action est définitive.\n"
        "Toutes vos données seront supprimées.",
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () {
            Navigator.pop(context);
          },
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: isLoading
              ? null
              : () async {
                  await ref.read(authControllerProvider.notifier).deleteMyAccount();
                  if (!context.mounted) return;
                  final newState = ref.read(authControllerProvider);
                  if (newState.hasError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Erreur: ${newState.error}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    // La redirection vers /login est gérée automatiquement par le GoRouter
                    // via l'écoute de authStateProvider quand l'utilisateur est déconnecté.
                    Navigator.pop(context);
                  }
                },
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text("Supprimer"),
        ),
      ],
    );
  }
}
