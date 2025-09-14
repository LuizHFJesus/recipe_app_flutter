import 'package:app4_receitas/l10n/app_localizations.dart';
import 'package:app4_receitas/routes/app_router.dart';
import 'package:app4_receitas/utils/config/env.dart';
import 'package:app4_receitas/utils/local_controller.dart';
import 'package:app4_receitas/utils/theme/custom_theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'di/service_locator.dart';

Future<void> main() async {
  // Garante que o Flutter está inicializado
  WidgetsFlutterBinding.ensureInitialized();

  await Env.init();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  await injectDependencies();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // * Get.put
    // Usado para injetar dependências no GetX
    final theme = Get.put(CustomThemeController());

    final localeController = Get.put(LocalController());

    // * Obx
    // Usado para tornar um widget reativo
    return Obx(
      () => MaterialApp.router(
        title: 'Eu Amo Cozinhar',
        debugShowCheckedModeBanner: false,
        theme: theme.customTheme,
        darkTheme: theme.customThemeDark,
        themeMode: theme.isDark.value ? ThemeMode.dark : ThemeMode.light,
        routerConfig: AppRouter().router,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'),
          Locale('pt', 'BR'),
        ],
        locale: localeController.locale,
      ),
    );
  }
}
