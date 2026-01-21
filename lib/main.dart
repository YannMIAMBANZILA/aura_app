import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <--- Indispensable
import 'config/theme.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

void main() {
  // On englobe l'app avec ProviderScope pour activer Riverpod
  runApp(const ProviderScope(child: AuraApp()));
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura',
      debugShowCheckedModeBanner: false,
      theme: AuraTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}