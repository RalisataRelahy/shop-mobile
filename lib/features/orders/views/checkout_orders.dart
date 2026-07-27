import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_good/app/theme/app_colors.dart';
import 'package:shop_good/features/auth/providers/auth_provider.dart';
import 'package:shop_good/features/cart/providers/cart_provider.dart';
import 'package:shop_good/features/orders/data/models/order_model.dart';
import 'package:shop_good/features/orders/providers/order_provider.dart';
import 'package:shop_good/shared/widgets/toast_notification.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

enum PickupTime {at1930, custom }

class CheckoutConfigScreen extends ConsumerStatefulWidget {
  const CheckoutConfigScreen({super.key});

  @override
  ConsumerState<CheckoutConfigScreen> createState() => _CheckoutConfigScreenState();
}

class _CheckoutConfigScreenState extends ConsumerState<CheckoutConfigScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  DeliveryMode? _mode;
  String? _paymentMethod;
  PickupTime? _pickupTime;
  TimeOfDay? _customTime;

  double? _lat;
  double? _lng;
  final bool _isGettingLocation = false;

  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    // Pré-remplissage des infos utilisateur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(userProfileProvider).value;
      if (profile != null) {
        _nameController.text = profile.pseudo;
        _phoneController.text = profile.phone;
      }
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Widget _staggered(int index, Widget child) {
    final start = (index * 0.12).clamp(0.0, 1.0);
    final end = (start + 0.5).clamp(0.0, 1.0);
    final curved = CurvedAnimation(
      parent: _entrance,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        return Opacity(
          opacity: curved.value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - curved.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  bool get _canSubmit {
    final baseOk = _nameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().length >= 8 &&
        _mode != null &&
        _paymentMethod != null;
    if (!baseOk) return false;
    if (_mode == DeliveryMode.pickup) return _pickupTime != null;
    if (_mode == DeliveryMode.delivery) {
      return _addressController.text.trim().isNotEmpty || (_lat != null && _lng != null);
    }
    return false;
  }


  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true || !_canSubmit) {
      HapticFeedback.mediumImpact();
      return;
    }

    final user = ref.read(currentUserProvider);
    final isGuest = ref.read(isGuestModeProvider);
    
    // Si pas de user et pas en mode invité (théoriquement impossible via le router mais sécu)
    if (user == null && !isGuest) {
      ToastNotification.showError(context, 'Veuillez vous connecter');
      return;
    }

    final cartItems = ref.read(cartProvider);
    final totalPrice = ref.read(cartTotalPriceProvider);

    String? timeStr;
    if (_mode == DeliveryMode.pickup) {
      timeStr = _pickupTime == PickupTime.at1930
          ? '19:30'
          : _customTime?.format(context) ?? '';
    }
    final currentMode = _mode;
    final currentPayment = _paymentMethod;

    if (currentMode == null || currentPayment == null) {
      ToastNotification.showError(context, 'Infos de livraison ou paiement manquantes');
      return;
    }
    final paymentMethod = currentPayment == "especes"
        ? "especes"
        : "mobile_money($currentPayment)";
    final order = OrderModel(
      id: const Uuid().v4(),
      clientId: user?.id,
      clientPhone: _phoneController.text.trim(),
      clientName: _nameController.text.trim(),
      statut: OrderStatus.nonConfirmer,
      deliveryMode: currentMode,
      deliveryAddress: currentMode == DeliveryMode.delivery ? _addressController.text.trim() : null,
      latitude: _lat,
      longitude: _lng,
      pickupTime: timeStr,
      paymentMethod: paymentMethod,
      totalPrice: totalPrice,
      note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      createdAt: DateTime.now(),
    );

    await ref.read(orderControllerProvider.notifier).placeOrder(
          order: order,
          items: cartItems,
        );

    final state = ref.read(orderControllerProvider);
    if (state.hasError) {
      if (mounted) {
        ToastNotification.showError(context, 'Erreur: ${state.error}');
      }
    } else {
      if (mounted) {
        ref.read(cartProvider.notifier).clearCart();
        ToastNotification.showSuccess(context, 'Commande passée avec succès !');
        context.go('/');
      }
    }
  }
  Map<String, String> mobileMethode = {
    "MVola": "MVola",
    "Orange Money": "OrangeMoney",
    "Airtel Money": "AirtelMoney",
  };

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundOffWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'CONFIGURER MA COMMANDE',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            double maxContentWidth = width < 600 ? width : 600;
            double horizontalPadding = width < 480 ? 16 : 24;

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _staggered(
                          0,
                          Text(
                            'Comment récupérer votre commande ?',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- Sélection du mode ---
                        _staggered(1, _ModeSelector(
                          selected: _mode,
                          onSelected: (m) => setState(() {
                            _mode = m;
                            _lat = null;
                            _lng = null;
                            if (m == DeliveryMode.pickup) {
                              _addressController.clear();
                            } else {
                              _pickupTime = null;
                              _customTime = null;
                            }
                          }),
                        )),
                        const SizedBox(height: 28),

                        // --- Coordonnées ---
                        _staggered(2, _SectionLabel(text: 'Vos coordonnées')),
                        const SizedBox(height: 12),
                        _staggered(
                          2,
                          _buildTextField(
                            controller: _nameController,
                            label: 'Pseudonyme pour la commande',
                            icon: Icons.person_outline,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _staggered(
                          2,
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Numéro de téléphone',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- Section conditionnelle ---
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          child: _mode == null
                              ? const SizedBox.shrink(key: ValueKey('empty'))
                              : _mode == DeliveryMode.pickup
                              ? _PickupTimeSection(
                            key: const ValueKey('pickup'),
                            selected: _pickupTime,
                            customTime: _customTime,
                            onSelected: (t) =>
                                setState(() => _pickupTime = t),
                            onPickCustomTime: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _customTime ??
                                    TimeOfDay.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  _customTime = picked;
                                  _pickupTime = PickupTime.custom;
                                });
                              }
                            },
                          )
                              : _DeliveryAddressSection(
                            key: const ValueKey('delivery'),
                            controller: _addressController,
                            isGettingLocation: _isGettingLocation,
                            lat: _lat,
                            lng: _lng,
                            onChanged: () => setState(() {
                              _lat = null;
                              _lng = null;
                            }),
                          ),
                        ),

                        const SizedBox(height: 24),
                        _staggered(2, _SectionLabel(text: 'Mode de paiement')),
                        const SizedBox(height: 12),
                        _staggered(
                          2,
                          _PaymentSelector(
                            selected: _paymentMethod,
                            onSelected: (p) => setState(() => _paymentMethod = p),
                            mobileMethode: mobileMethode,
                          ),
                        ),

                        const SizedBox(height: 24),
                        _staggered(2, _SectionLabel(text: 'Note ou instructions')),
                        const SizedBox(height: 12),
                        _staggered(
                          2,
                          _buildTextField(
                            controller: _noteController,
                            label: 'Ex: Code porte, instructions spéciales...',
                            icon: Icons.note_alt_outlined,
                            maxLines: 3,
                          ),
                        ),

                        const SizedBox(height: 40),
                        _staggered(3, _SubmitButton(
                          isLoading: orderState.isLoading,
                          enabled: _canSubmit && !orderState.isLoading,
                          onPressed: _submit,
                        )),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
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
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
        validator: (v) => (v == null || v.trim().isEmpty && maxLines == 1) ? 'Champ obligatoire' : null,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final DeliveryMode? selected;
  final ValueChanged<DeliveryMode> onSelected;

  const _ModeSelector({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeCard(
            icon: Icons.storefront_outlined,
            label: 'À récupérer',
            isSelected: selected == DeliveryMode.pickup,
            onTap: () => onSelected(DeliveryMode.pickup),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ModeCard(
            icon: Icons.delivery_dining_outlined,
            label: 'En livraison',
            isSelected: selected == DeliveryMode.delivery,
            onTap: () => onSelected(DeliveryMode.delivery),
          ),
        ),
      ],
    );
  }
}

class _PaymentSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;
  // Typage précis : les codes USSD (clés/valeurs) sont des String
  final Map<String, String> mobileMethode;

  const _PaymentSelector({
    required this.selected,
    required this.onSelected,
    required this.mobileMethode,
  });

  @override
  Widget build(BuildContext context) {
    // On convertit une fois pour toutes le Map en liste pour éviter les .elementAt() lents
    final methodsList = mobileMethode.entries.toList();

    return Column(
      mainAxisSize: MainAxisSize.min, // Optimise l'espace vertical
      children: [
        Row(
          children: [
            Expanded(
              child: _ModeCard(
                icon: Icons.payments_outlined,
                label: 'Espèces',
                isSelected: selected == 'especes',
                onTap: () => onSelected('especes'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModeCard(
                icon: Icons.phone_android_outlined,
                label: 'Mobile Money',
                // Reste sélectionné si la valeur courante fait partie des codes USSD
                isSelected: selected == 'mobile_money' || mobileMethode.containsValue(selected),
                onTap: () => onSelected('mobile_money'),
              ),
            ),
          ],
        ),
        // Affiche la liste si "Mobile Money" est cliqué OU si un opérateur est déjà choisi
        if (selected == 'mobile_money' || mobileMethode.containsValue(selected)) ...[
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true, // IMPORTANT: Empêche le crash dans une Column
            physics: const NeverScrollableScrollPhysics(), // Désactive le scroll imbriqué inutile
            itemCount: methodsList.length,
            itemBuilder: (context, index) {
              final entry = methodsList[index];
              final isCurrentOp = selected == entry.value;

              return Card(
                elevation: 0,
                color: isCurrentOp ? Theme.of(context).colorScheme.primaryContainer : null,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: isCurrentOp ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(
                    entry.key,
                    style: TextStyle(
                      fontWeight: isCurrentOp ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isCurrentOp
                      ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                      : const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => onSelected(entry.value), // Renvoie le code USSD exact (ex: #111*1*2*0345030370#)
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}


class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.lightGrey,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : AppColors.primaryGreen,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickupTimeSection extends StatelessWidget {
  final PickupTime? selected;
  final TimeOfDay? customTime;
  final ValueChanged<PickupTime> onSelected;
  final VoidCallback onPickCustomTime;

  const _PickupTimeSection({
    super.key,
    required this.selected,
    required this.customTime,
    required this.onSelected,
    required this.onPickCustomTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionLabel(text: 'Heure de retrait'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _ChoiceChipCustom(
              label: '19:30',
              selected: selected == PickupTime.at1930,
              onTap: () => onSelected(PickupTime.at1930),
            ),
            _ChoiceChipCustom(
              label: selected == PickupTime.custom && customTime != null
                  ? customTime!.format(context)
                  : 'Autre',
              selected: selected == PickupTime.custom,
              onTap: onPickCustomTime,
            ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceChipCustom extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChipCustom({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.primaryGreen : AppColors.lightGrey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.darkGrey,
          ),
        ),
      ),
    );
  }
}

class _DeliveryAddressSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isGettingLocation;
  final double? lat;
  final double? lng;
  final VoidCallback onChanged;

  const _DeliveryAddressSection({
    super.key,
    required this.controller,
    required this.isGettingLocation,
    required this.lat,
    required this.lng,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _SectionLabel(text: 'Adresse de livraison'),
          ],
        ),
        const SizedBox(height: 8),
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
          child: TextFormField(
            controller: controller,
            maxLines: 2,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              hintText: 'Votre adresse complète...',
              prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primaryGreen),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              suffixIcon: lat != null
                  ? const Icon(Icons.check_circle, color: AppColors.primaryGreen)
                  : null,
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Adresse requise' : null,
          ),
        ),
        if (lat != null && lng != null) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 180,
              child: GoogleMap(
                key: ValueKey('$lat-$lng'),
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat!, lng!),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('current_pos'),
                    position: LatLng(lat!, lng!),
                  ),
                },
                liteModeEnabled: true, // Optimisé pour l'affichage simple
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4),
            child: Text(
              'Coordonnées : ${lat!.toStringAsFixed(5)}, ${lng!.toStringAsFixed(5)}',
              style: const TextStyle(fontSize: 12, color: AppColors.mediumGrey, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: enabled ? 4 : 0,
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'VALIDER LA COMMANDE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
