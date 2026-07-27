import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shop_good/app/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_good/shared/services/notification_services.dart';
import 'package:shop_good/utils/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shop_good/app/router/approute.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation de la localisation pour les dates
  await initializeDateFormatting('fr_FR');
  await PermissionService.requestInitialPermissions();
  // Pour masquer complètement la barre d'action rapide et la barre de statut
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );
  await Firebase.initializeApp();
  // Initialisation de Supabase
  await Supabase.initialize(
    url: 'https://odtzvmnqfwjxishkbnob.supabase.co',
    publishableKey: 'sb_publishable_rqf-EdjotQV6RkSR9VXnsQ_Xqva3t82',
  );
  await NotificationService().initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _hideSystemUI();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future.delayed(
        const Duration(milliseconds: 300),
        _hideSystemUI,
      );
    }
  }

  void _hideSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'Shop Good',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primaryGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          surface: AppColors.backgroundOffWhite,
        ),
        scaffoldBackgroundColor: AppColors.backgroundOffWhite,
        dividerColor: AppColors.lightGrey,
      ),
    );
  }
}