import 'package:flutter/material.dart';
import 'legal_notice_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color mainBackground = Color(0xFF0F172A);
    const Color accentColor = Color(0xFF00E5FF);
    
    return Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: const Text(
          'Paramètres',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          _buildSectionTitle('MON COMPTE'),
          _buildListTile(
            context: context,
            title: 'Modifier mon profil',
            icon: Icons.person,
            iconColor: accentColor,
            onTap: () {
              _showNavigationMessage(context, 'Naviguer vers Modifier mon profil');
            },
          ),
          _buildListTile(
            context: context,
            title: 'Changer de classe',
            icon: Icons.school,
            iconColor: accentColor,
            onTap: () {
              _showNavigationMessage(context, 'Naviguer vers Changer de classe');
            },
          ),
          _buildListTile(
            context: context,
            title: 'Déconnexion',
            icon: Icons.logout,
            iconColor: accentColor,
            onTap: () {
              _showNavigationMessage(context, 'Action : Déconnexion');
            },
          ),
          
          const SizedBox(height: 16),
          const Divider(color: Colors.white10, thickness: 1, height: 1),
          const SizedBox(height: 8),

          _buildSectionTitle('EXPÉRIENCE AURA'),
          _buildListTile(
            context: context,
            title: 'Préférences de Coaching',
            icon: Icons.tune,
            iconColor: accentColor,
            onTap: () {
              _showNavigationMessage(context, 'Naviguer vers Préférences de Coaching');
            },
          ),
          _buildListTile(
            context: context,
            title: 'Aura Shop (Personnalisation)',
            icon: Icons.storefront,
            iconColor: accentColor,
            trailingWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: accentColor.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star, color: accentColor, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Nouveau',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            onTap: () {
              _showNavigationMessage(context, 'Naviguer vers Aura Shop');
            },
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white10, thickness: 1, height: 1),
          const SizedBox(height: 8),

          _buildSectionTitle('SUPPORT & LÉGAL'),
          _buildListTile(
            context: context,
            title: 'Nous Contacter / Signaler un bug',
            icon: Icons.chat_bubble_outline,
            iconColor: accentColor,
            onTap: () {
              _showNavigationMessage(context, 'Naviguer vers Support');
            },
          ),
          _buildListTile(
            context: context,
            title: 'Mentions Légales',
            icon: Icons.gavel,
            iconColor: accentColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LegalNoticeScreen()),
              );
            },
          ),
          _buildListTile(
            context: context,
            title: 'Politique de Confidentialité',
            icon: Icons.shield_outlined,
            iconColor: accentColor,
            onTap: () {
              _showNavigationMessage(context, 'Naviguer vers Politique de Confidentialité');
            },
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.redAccent, thickness: 0.2, height: 1),
          const SizedBox(height: 8),

          _buildSectionTitle('ZONE DE DANGER', color: Colors.redAccent),
          _buildListTile(
            context: context,
            title: 'Supprimer mon compte',
            titleColor: Colors.redAccent,
            icon: Icons.delete_forever,
            iconColor: Colors.redAccent,
            onTap: () {
              _showNavigationMessage(context, 'Action : Supprimer le compte');
            },
          ),

          const SizedBox(height: 48),
          
          const Center(
            child: Text(
              'Aura App v1.0.0',
              style: TextStyle(
                color: Colors.white30,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Color color = Colors.grey}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: color.withOpacity(0.7),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required String title,
    Color titleColor = Colors.white,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    Widget? trailingWidget,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor, 
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailingWidget ?? const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  void _showNavigationMessage(BuildContext context, String message) {
    print('Naviguer vers: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF00E5FF), width: 1),
        ),
      ),
    );
  }
}
