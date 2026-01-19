import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

void main() {
  runApp(const AuraApp());
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura',
      debugShowCheckedModeBanner: false, // Enlève le bandeau "Debug" moche
      theme: AuraTheme.darkTheme,        // On applique notre thème
      home: const DashboardScreen(),     // On lance l'écran d'accueil
    );
  }
}