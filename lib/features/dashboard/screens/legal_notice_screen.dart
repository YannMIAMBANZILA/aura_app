import 'package:flutter/material.dart';

class LegalNoticeScreen extends StatelessWidget {
  const LegalNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color mainBackground = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: const Text(
          'Mentions Légales',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              "1. Éditeur de l'application",
              "L'application Aura est éditée par [Ton Prénom Ton Nom / Nom de ta structure].\nEmail de contact : [Ton email de contact]",
            ),
            _buildSection(
              "2. Directeur de la publication",
              "Le directeur de la publication est Paul Ochon.",
            ),
            _buildSection(
              "3. Hébergement",
              "L'infrastructure backend et la base de données de l'application sont hébergées par Supabase, Inc.\nAdresse : 972 Mission St, San Francisco, CA 94103, États-Unis.",
            ),
            _buildSection(
              "4. Propriété intellectuelle",
              "L'ensemble des éléments constituant l'application Aura (textes, graphismes, logiciels, photographies, images, vidéos, sons, plans, noms, logos, marques, créations et œuvres protégeables diverses, bases de données, etc.) ainsi que l'application elle-même, relèvent des législations françaises et internationales sur le droit d'auteur et la propriété intellectuelle.\n\nToute reproduction, représentation, modification ou adaptation totale ou partielle de l'application ou de l'un de ses éléments, sans l'accord préalable et écrit de l'éditeur, est strictement interdite.",
            ),
            _buildSection(
              "5. Responsabilité",
              "Les contenus générés par l'Intelligence Artificielle (cours, quiz, corrections) sont fournis à titre d'aide pédagogique. Bien que nous nous efforcions d'assurer leur exactitude, l'éditeur ne saurait être tenu responsable en cas d'erreur ou d'omission. L'élève est invité à toujours vérifier ses connaissances avec ses supports de cours officiels.",
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    const Color accentColor = Color(0xFF00E5FF);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: accentColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
