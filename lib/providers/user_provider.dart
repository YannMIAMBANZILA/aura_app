import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuraScoreNotifier extends StateNotifier<int> {
  // On initialise à 0 le temps de charger la mémoire
  AuraScoreNotifier() : super(0) {
    _loadScore();
  }

  static const _storageKey = 'aura_score';

  // 1. CHARGER : On lit le disque au démarrage
  Future<void> _loadScore() async {
    final prefs = await SharedPreferences.getInstance();
    // Si pas de score sauvegardé, on commence à 100 (Apprenti)
    state = prefs.getInt(_storageKey) ?? 100;
  }

  // 2. SAUVEGARDER : On écrit sur le disque à chaque changement
  Future<void> addPoints(int points) async {
    // Mise à jour visuelle immédiate (Optimistic UI)
    state = state + points; 
    
    // Sauvegarde "en dur"
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey, state);
  }
  
  // Utile pour remettre à zéro le score
  Future<void> reset() async {
    state = 100;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey, 100);
  }
}

final auraProvider = StateNotifierProvider<AuraScoreNotifier, int>((ref) {
  return AuraScoreNotifier();
});