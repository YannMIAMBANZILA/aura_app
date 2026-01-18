import 'package:flutter/material.dart';
import 'package:aura_app/config/theme.dart';

void main() {
  runApp(const AuraApp());
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura App - Digital Bioluminescence',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const ThemeDemoPage(),
    );
  }
}

class ThemeDemoPage extends StatefulWidget {
  const ThemeDemoPage({super.key});

  @override
  State<ThemeDemoPage> createState() => _ThemeDemoPageState();
}

class _ThemeDemoPageState extends State<ThemeDemoPage> {
  bool _switchValue = false;
  bool _checkboxValue = false;

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Bioluminescence Theme'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titre avec Space Grotesk
            Text(
              'Thème Digital Bioluminescence',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Dark Mode complet avec Deep Space Blue, Electric Cyan et Mint Neon',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),

            // Section Typographie
            Text(
              'Typographie',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Space Grotesk pour les titres',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Inter pour le corps de texte',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // Section Boutons
            Text(
              'Boutons',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Bouton Primaire'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Bouton Outline'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {},
              child: const Text('Bouton Texte'),
            ),
            const SizedBox(height: 32),

            // Section Champ de texte
            Text(
              'Champs de texte',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Nom',
                hintText: 'Entrez votre nom',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'exemple@email.com',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 32),

            // Section Cards
            Text(
              'Cartes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Carte exemple',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cette carte utilise le thème Deep Space Blue avec des accents Electric Cyan.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Section Composants
            Text(
              'Composants',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Switch'),
                const Spacer(),
                Switch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                const Text('Checkbox'),
                const Spacer(),
                Checkbox(
                  value: _checkboxValue,
                  onChanged: (value) {
                    setState(() {
                      _checkboxValue = value ?? false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: const Text('Electric Cyan'),
                  backgroundColor: AppColors.electricCyan.withOpacity(0.2),
                ),
                Chip(
                  label: const Text('Mint Neon'),
                  backgroundColor: AppColors.mintNeon.withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Section Couleurs personnalisées
            Text(
              'Couleurs personnalisées',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildColorCard(
              context,
              'Succès',
              customColors.success,
              customColors.onSuccess,
            ),
            const SizedBox(height: 12),
            _buildColorCard(
              context,
              'Avertissement',
              customColors.warning,
              customColors.onWarning,
            ),
            const SizedBox(height: 12),
            _buildColorCard(
              context,
              'Information',
              customColors.info,
              customColors.onInfo,
            ),
            const SizedBox(height: 32),

            // Section Palette
            Text(
              'Palette de couleurs',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildColorSwatch('Deep Space Blue', AppColors.deepSpaceBlue),
            _buildColorSwatch('Electric Cyan', AppColors.electricCyan),
            _buildColorSwatch('Mint Neon', AppColors.mintNeon),
            _buildColorSwatch('Space Blue 800', AppColors.spaceBlue800),
            const SizedBox(height: 32),

            // Bottom spacing
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Thème Digital Bioluminescence actif !'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: const Icon(Icons.star),
      ),
    );
  }

  Widget _buildColorCard(
    BuildContext context,
    String label,
    Color color,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.spaceBlue600,
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: TextStyle(
                    color: AppColors.gray400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
