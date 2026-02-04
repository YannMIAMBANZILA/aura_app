import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/splash/screens/splash_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation des notifications
  await NotificationService().init();
  print("Notifications initialisées !");
  
  try {
    // 1. Charger les env vars
    await dotenv.load(fileName: ".env");

    // 2. Initialiser Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    print("Connecté à Supabase avec succès !");

  } catch (error) {
    print("Erreur d'initialisation : $error");
  }

  // 3. Lancer l'app avec Riverpod
  runApp(const ProviderScope(child: AuraApp()));
}


class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {

    final session = Supabase.instance.client.auth.currentSession;
    return MaterialApp(
      title: 'Aura',
      debugShowCheckedModeBanner: false,
      theme: AuraTheme.darkTheme,
      // Logique de redirection : gérée par le Splash Screen
      home: const SplashScreen(),
    );
  }
}