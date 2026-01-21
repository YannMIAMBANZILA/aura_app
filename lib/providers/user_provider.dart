import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuraScoreNotifier extends StateNotifier<int> {
  AuraScoreNotifier() : super(0) {
    _initScore();
  }

  static const _storageKey = 'aura_score';

  // 1. Initialisation Intelligente
  Future<void> _initScore() async {
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user != null) {
      // CAS A : Utilisateur Connecté -> On charge depuis Supabase
      await _loadFromSupabase(user.id);
    } else {
      // CAS B : Invité -> On charge depuis le téléphone
      await _loadFromLocal();
    }
  }

  // Charger Localement
  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_storageKey) ?? 100;
  }

  // Charger depuis le Cloud
  Future<void> _loadFromSupabase(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('aura_points')
          .eq('id', userId)
          .single();
      
      // On met à jour l'état avec le score du cloud
      state = data['aura_points'] as int;
      
      // On synchronise aussi le local pour le mode hors-ligne
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_storageKey, state);
      
    } catch (e) {
      // Si erreur (ex: pas d'internet), on repli sur le local
      _loadFromLocal();
    }
  }

  // 2. Ajouter des points (Fonction Hybride)
  Future<void> addPoints(int points) async {
    // Mise à jour visuelle immédiate (Optimistic UI)
    state = state + points;

    // Sauvegarde Locale (Toujours)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey, state);

    // Sauvegarde Cloud (Si connecté)
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        await Supabase.instance.client
            .from('profiles')
            .update({'aura_points': state})
            .eq('id', user.id);
      } catch (e) {
        print("Erreur de sauvegarde Cloud: $e");
        // Ce n'est pas grave, c'est sauvegardé en local.
        // On pourrait ajouter une file d'attente de sync ici plus tard.
      }
    }
  }

  // 3. LA FONCTION CLEF : Fusionner Invité -> Compte
  // À appeler juste après le login !
  Future<void> syncLocalToCloud() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final localScore = prefs.getInt(_storageKey) ?? 100;

    // On envoie le score local dans le cloud (écrasement ou addition ?)
    // Ici on choisit d'envoyer le MAX des deux pour ne rien perdre
    try {
      // D'abord on récupère le score cloud actuel
      final data = await Supabase.instance.client
          .from('profiles')
          .select('aura_points')
          .eq('id', user.id)
          .single();
      
      final cloudScore = data['aura_points'] as int;

      if (localScore > cloudScore) {
        // Le score local est meilleur (il vient de jouer), on update le cloud
        await Supabase.instance.client
            .from('profiles')
            .update({'aura_points': localScore})
            .eq('id', user.id);
        state = localScore;
      } else {
        // Le cloud est meilleur (il a joué sur un autre appareil), on update le local
        state = cloudScore;
        await prefs.setInt(_storageKey, cloudScore);
      }
    } catch (e) {
      print("Erreur Sync: $e");
    }
  }
}

final auraProvider = StateNotifierProvider<AuraScoreNotifier, int>((ref) {
  return AuraScoreNotifier();
});