import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shop_good/app/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shop_good/app/router/approute.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation de la localisation pour les dates
  await initializeDateFormatting('fr_FR');
  
  // Initialisation de Supabase
  await Supabase.initialize(
    url: 'https://odtzvmnqfwjxishkbnob.supabase.co',
    publishableKey: 'sb_publishable_rqf-EdjotQV6RkSR9VXnsQ_Xqva3t82',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
