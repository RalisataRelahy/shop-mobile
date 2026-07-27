import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_good/app/theme/app_colors.dart';
import 'package:shop_good/features/orders/data/models/order_model.dart';
import 'package:shop_good/features/orders/providers/order_provider.dart';
import 'package:shop_good/utils/factorisingprice.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_provider.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  static const Color greenApple = Color(0xFF34A881);
  static const Color lightGrey = Color(0xFFE5E5EA);
  static const Color offWhite = Color(0xFFF9F9F6);
  static const Color darkText = Color(0xFF2C2C2E);

  /// Facteur d'échelle typographique selon la largeur de l'écran.
  /// - < 360  : très petits téléphones
  /// - 360-600 : téléphones standards (référence)
  /// - 600-900 : phablettes / petites tablettes
  /// - > 900  : tablettes / desktop
  double _fontScale(double width) {
    if (width < 360) return 0.9;
    if (width < 600) return 1.0;
    if (width < 900) return 1.08;
    return 1.15;
  }

  double _paddingWidth(double width) {
    if (width < 360) return 12.0;
    if (width < 600) return 16.0;
    return 20.0;
  }

  /// Identifiant court et sûr (évite un crash si l'id fait moins de 8
  /// caractères, ce que `substring(0, 8)` seul ne gère pas).
  static String shortId(String id) => id.length > 8 ? id.substring(0, 8) : id;

  /// Couleur associée au statut, dérivée du texte pour rester robuste même
  /// si de nouveaux statuts sont ajoutés côté back sans toucher cet écran.
  static Color statusColor(String statusValue) {
    final v = statusValue.toLowerCase();
    if (v.contains('annul')) return Colors.red;
    if (v.contains('livr') && !v.contains('livraison')) return greenApple;
    if (v.contains('prepar')) return Colors.orange;
    if (v.contains('route') || v.contains('livraison')) return Colors.blue;
    if (v.contains('confirm')) return AppColors.primaryGreen;
    return greenApple;
  }

  void showAdaptiveBottomSheet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600; // Point de rupture classique

    Widget notImplementedContent(VoidCallback onClose) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nous rappeler',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkText),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Cette fonctionnalité arrive bientôt.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    if (isTablet) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SizedBox(
            width: size.width * 0.4,
            child: notImplementedContent(() => Navigator.of(context).pop()),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: notImplementedContent(() => Navigator.of(context).pop()),
        ),
      );
    }
  }

  Widget _buildGuestOrdersView(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: offWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Mes Commandes',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 80, color: lightGrey),
              const SizedBox(height: 16),
              const Text(
                'Historique indisponible',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText),
              ),
              const SizedBox(height: 8),
              const Text(
                'En mode invité, vos commandes ne sont pas enregistrées dans un historique permanent. Connectez-vous pour suivre vos plats !',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => ref.read(isGuestModeProvider.notifier).state = false,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenApple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Se connecter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGuest = ref.watch(isGuestModeProvider);
    final ordersAsync = ref.watch(userOrdersProvider);

    if (isGuest) {
      return _buildGuestOrdersView(context, ref);
    }

    return Scaffold(
      backgroundColor: offWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Mes Commandes',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Text("Vous n'avez pas encore de commandes"),
            );
          }

          final activeOrders = orders
              .where((o) =>
          o.statut != OrderStatus.livree && o.statut != OrderStatus.annulee)
              .toList();
          final pastOrders = orders
              .where((o) =>
          o.statut == OrderStatus.livree || o.statut == OrderStatus.annulee)
              .toList();

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final bool isWideScreen = width > 900;
              final double paddingWidth = _paddingWidth(width);
              final double scale = _fontScale(width);
              final double contentMaxWidth = isWideScreen ? 800.0 : double.infinity;

              Widget listContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activeOrders.isNotEmpty) ...[
                    Row(
                      children: [
                        Text(
                          "Commande en cours",
                          style: TextStyle(
                            color: darkText,
                            fontWeight: FontWeight.bold,
                            fontSize: 18 * scale,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const _LivePulseDot(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...activeOrders.map(
                          (order) => _FadeSlideIn(
                        key: ValueKey('active-${order.id}'),
                        child: _ActiveOrderCard(
                          order: order,
                          padding: paddingWidth,
                          scale: scale,
                          onCallMe: () => showAdaptiveBottomSheet(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    "Historique des commandes",
                    style: TextStyle(
                      color: darkText,
                      fontWeight: FontWeight.bold,
                      fontSize: 18 * scale,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (pastOrders.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text("Aucun historique disponible"),
                      ),
                    )
                  else
                    ...pastOrders.map(
                          (order) => _buildPastOrderCard(
                        context,
                        ref,
                        order,
                        paddingWidth,
                        scale,
                      ),
                    ),
                ],
              );

              // Sur grand écran (tablette/desktop), on centre et limite la
              // largeur du contenu pour éviter des cartes qui s'étirent
              // indéfiniment et deviennent difficiles à lire.
              if (isWideScreen) {
                listContent = Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: listContent,
                  ),
                );
              }

              // Pull-to-refresh : filet de sécurité en plus du flux
              // temps réel, utile si la connexion a été coupée un moment.
              return RefreshIndicator(
                color: greenApple,
                onRefresh: () async {
                  ref.invalidate(userOrdersProvider);
                  await ref.read(userOrdersProvider.future);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(paddingWidth),
                  child: listContent,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 40, color: Colors.grey),
                const SizedBox(height: 12),
                Text("Impossible de charger vos commandes\n$err",
                    textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(userOrdersProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Réessayer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenApple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPastOrderCard(
      BuildContext context, WidgetRef ref, OrderModel order, double padding, double scale) {
    final dateStr =
    order.createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt!) : 'Date inconnue';
    final color = statusColor(order.statut.value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: padding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: lightGrey, width: 1),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: lightGrey, width: 1),
        ),
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: lightGrey.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            order.statut == OrderStatus.livree ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: order.statut == OrderStatus.livree ? Colors.grey[600] : Colors.red[300],
            size: 22 * scale,
          ),
        ),
        title: Text(
          "Commande #${shortId(order.id)}",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14 * scale,
            color: darkText,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          "$dateStr • ${factorisingPrice(order.totalPrice)} Ar",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12 * scale,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          order.statut.value.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 10 * scale,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _ItemsList(orderId: order.id, scale: scale),
          ),
        ],
      ),
    );
  }
}

/// Carte de commande active, extraite en widget avec état local pour gérer
/// proprement le chargement pendant l'annulation (évite les doubles-taps et
/// donne un retour visuel immédiat).
class _ActiveOrderCard extends ConsumerStatefulWidget {
  final OrderModel order;
  final double padding;
  final double scale;
  final VoidCallback onCallMe;

  const _ActiveOrderCard({
    required this.order,
    required this.padding,
    required this.scale,
    required this.onCallMe,
  });

  @override
  ConsumerState<_ActiveOrderCard> createState() => _ActiveOrderCardState();
}

class _ActiveOrderCardState extends ConsumerState<_ActiveOrderCard> {
  bool _isCancelling = false;

  Future<void> _confirmAndCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Annuler la commande ?'),
        content: const Text('Cette action est irréversible. Voulez-vous vraiment annuler cette commande ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Retour', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmer', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);
    try {
      await ref
          .read(orderControllerProvider.notifier)
          .canceledOrder(order: widget.order, status: OrderStatus.annulee);
      if (!mounted) return;
      final state = ref.read(orderControllerProvider);
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${state.error}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commande annulée')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final padding = widget.padding;
    final scale = widget.scale;
    final color = OrdersPage.statusColor(order.statut.value);

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Commande #${OrdersPage.shortId(order.id)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * scale,
                      color: OrdersPage.darkText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Le badge s'anime en douceur quand le statut change en
                // temps réel (couleur + texte), au lieu de sauter brutalement.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(scale: anim, child: child),
                  ),
                  child: Container(
                    key: ValueKey(order.statut.value),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.statut.value.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 10 * scale,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (order.createdAt != null) ...[
              const SizedBox(height: 4),
              _ElapsedTimeText(since: order.createdAt!, scale: scale),
            ],
            const Divider(color: OrdersPage.lightGrey, height: 20),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      order.isPickup ? Icons.storefront : Icons.delivery_dining,
                      color: Colors.grey,
                      size: 20 * scale,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.isPickup ? "À emporter" : "En livraison",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14 * scale,
                      ),
                    ),
                  ],
                ),
                if (order.pickupTime != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timelapse,
                        color: AppColors.darkGrey,
                        size: 14 * scale,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.pickupTime!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: OrdersPage.darkText,
                          fontSize: 14 * scale,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (order.deliveryAddress != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, color: AppColors.darkGrey, size: 14 * scale),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.deliveryAddress!,
                      style: TextStyle(fontSize: 13 * scale, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            _ItemsList(orderId: order.id, scale: scale),

            const Divider(color: OrdersPage.lightGrey, height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.paymentMethod == 'especes' ? "À régler sur place" : "Payé par Mobile Money",
                        style: TextStyle(
                          fontSize: 11 * scale,
                          color: order.paymentMethod == 'especes' ? Colors.red[400] : OrdersPage.greenApple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "${factorisingPrice(order.totalPrice)} Ar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18 * scale,
                          color: OrdersPage.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    SizedBox(
                      height: 34,
                      child: ElevatedButton.icon(
                        onPressed: _isCancelling ? null : _confirmAndCancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OrdersPage.lightGrey,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        icon: _isCancelling
                            ? SizedBox(
                          width: 14 * scale,
                          height: 14 * scale,
                          child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                        )
                            : Icon(Icons.cancel, size: 16 * scale, color: Colors.red),
                        label: Text(
                          _isCancelling ? "..." : "Annuler",
                          style: TextStyle(color: Colors.red, fontSize: 13 * scale, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 34,
                      child: ElevatedButton.icon(
                        onPressed: widget.onCallMe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OrdersPage.lightGrey,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        icon: Icon(Icons.phone, size: 16 * scale, color: OrdersPage.darkText),
                        label: Text(
                          "Appelez-moi",
                          style: TextStyle(
                            color: OrdersPage.darkText,
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Petit point vert pulsant, signal visuel discret indiquant que la liste
/// des commandes actives est suivie en temps réel.
class _LivePulseDot extends StatefulWidget {
  const _LivePulseDot();

  @override
  State<_LivePulseDot> createState() => _LivePulseDotState();
}

class _LivePulseDotState extends State<_LivePulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.35, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: OrdersPage.greenApple,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Texte "il y a X min" qui se met à jour tout seul, pour renforcer la
/// sensation de suivi en direct sans avoir à recharger l'écran.
class _ElapsedTimeText extends StatefulWidget {
  final DateTime since;
  final double scale;

  const _ElapsedTimeText({required this.since, required this.scale});

  @override
  State<_ElapsedTimeText> createState() => _ElapsedTimeTextState();
}

class _ElapsedTimeTextState extends State<_ElapsedTimeText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatElapsed() {
    final diff = DateTime.now().difference(widget.since);
    if (diff.inMinutes < 1) return "Commandée à l'instant";
    if (diff.inMinutes < 60) return "Commandée il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "Commandée il y a ${diff.inHours} h";
    return "Commandée le ${DateFormat('dd/MM à HH:mm').format(widget.since)}";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatElapsed(),
      style: TextStyle(fontSize: 11 * widget.scale, color: Colors.grey[500]),
    );
  }
}

/// Fait apparaître son enfant en fondu + léger glissement une seule fois,
/// à la création du widget. Grâce à la `key` stable passée par l'appelant
/// (basée sur `order.id`), Flutter réutilise l'élément entre deux
/// rafraîchissements du flux temps réel : les commandes déjà affichées ne
/// rejouent pas l'animation, seules les nouvelles commandes apparaissent
/// en douceur.
class _FadeSlideIn extends StatefulWidget {
  final Widget child;

  const _FadeSlideIn({super.key, required this.child});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _ItemsList extends ConsumerWidget {
  final String orderId;
  final double scale;

  const _ItemsList({required this.orderId, required this.scale});

  Widget _buildGuestOrdersView(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Mes Commandes',
          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.lightGrey),
              const SizedBox(height: 16),
              const Text(
                'Historique indisponible',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color:Colors.black54),
              ),
              const SizedBox(height: 8),
              const Text(
                'En mode invité, vos commandes ne sont pas enregistrées dans un historique permanent. Connectez-vous pour suivre vos plats !',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pushReplacementNamed('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Se connecter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(orderItemsProvider(orderId));

    return itemsAsync.when(
      data: (items) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${item.quantity}x ${item.displayName}",
                    style: TextStyle(fontSize: 13 * scale, color: Colors.grey[800]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  // BUG FIX : les montants passaient partout par
                  // factorisingPrice sauf ici (séparateurs de milliers
                  // manquants sur les prix d'articles).
                  "${factorisingPrice(item.totalPrice)} Ar",
                  style: TextStyle(fontSize: 13 * scale, color: Colors.grey[600]),
                ),
              ],
            ),
          ))
              .toList(),
        );
      },
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (e, stack) => Row(
        children: [
          Expanded(
            child: Text(
              "Erreur lors de la récupération des articles",
              style: TextStyle(fontSize: 12 * scale, color: Colors.red[400]),
            ),
          ),
          TextButton(
            onPressed: () => ref.invalidate(orderItemsProvider(orderId)),
            child: const Text("Réessayer", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}