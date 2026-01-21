import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <--- Indispensable
import 'config/theme.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/screens/login_screen.dart';

Future<void> main() async {
  // On transforme le main en async pour charger les variables d'environnement
  await dotenv.load(fileName: ".env");
  // On englobe l'app avec ProviderScope pour activer Riverpod
  runApp(const ProviderScope(child: AuraApp()));

 // Initialisation de Supabase
 try {
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
 );
 // Vérification de la connexion
 print("✅ Connecté à Supabase avec succès !");
} catch (error) {
  print("⚠️ Erreur de connexion : $error");
  }
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
      // Logique de redirection :
      home: session != null ?  const DashboardScreen() : LoginScreen(),
    );
  }
}