import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// AuraProvider: Gestion des Aura Points (Local + Supabase)

class AuraScoreNotifier extends StateNotifier<int> {
  AuraScoreNotifier() : super(0) {
    _initScore();
  }

  static const _storageKey = 'aura_score';

  Future<void> _initScore() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await _loadFromSupabase(user.id);
    } else {
      await _loadFromLocal();
    }
  }

  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_storageKey) ?? 100;
  }

  Future<void> _loadFromSupabase(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('aura_points')
          .eq('id', userId)
          .single();
      state = data['aura_points'] as int;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_storageKey, state);
    } catch (e) {
      _loadFromLocal();
    }
  }

  Future<void> addPoints(int points) async {
    state = state + points;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey, state);

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        await Supabase.instance.client
            .from('profiles')
            .update({'aura_points': state})
            .eq('id', user.id);
      } catch (e) {
        print("Erreur de sauvegarde Cloud: $e");
      }
    }
  }

  Future<void> completeSession() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final profile = await Supabase.instance.client
        .from('profiles')
        .select('last_study_date, current_streak')
        .eq('id', user.id)
        .single();

    final lastDateStr = profile['last_study_date'] as String?;
    final lastDate = lastDateStr != null ? DateTime.parse(lastDateStr) : null;
    int streak = profile['current_streak'] as int? ?? 0;
    int multiplier = 1;

    // 1. Calcul de la régularité
    if (lastDate == null) {
      streak = 1;
    } else {
      final difference = DateTime(now.year, now.month, now.day)
          .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
          .inDays;

      if (difference == 1) {
        streak++; // Jour consécutif !
        multiplier = streak; // x4 si 4j, etc.
      } else if (difference > 1) {
        streak = 1; // On a raté un jour, on repart à 1
      } else {
        multiplier = 1; // Déjà révisé aujourd'hui : gain normal
      }
    }

    // 2. Application du gain unique de 50 pts
    int pointsToGain = 50 * multiplier;
    state = state + pointsToGain;

    // 3. Update BDD
    await Supabase.instance.client.from('profiles').update({
      'aura_points': state,
      'current_streak': streak,
      'last_study_date': now.toIso8601String(),
    }).eq('id', user.id);

    // 4. Update Local
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey, state);

    // 5. Vérification des Badges (placeholder)
    _checkAndAwardBadges(streak, user.id);
  }

  Future<void> _checkAndAwardBadges(int streak, String userId) async {
    // Logique pour les badges (à implémenter si besoin)
    print("Vérification des badges pour le streak: $streak");
  }

  Future<void> syncLocalToCloud() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final localScore = prefs.getInt(_storageKey) ?? 100;

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('aura_points')
          .eq('id', user.id)
          .single();

      final cloudScore = data['aura_points'] as int;

      if (localScore > cloudScore) {
        await Supabase.instance.client
            .from('profiles')
            .update({'aura_points': localScore})
            .eq('id', user.id);
        state = localScore;
      } else {
        state = cloudScore;
        await prefs.setInt(_storageKey, cloudScore);
      }
    } catch (e) {
      print("Erreur Sync: $e");
    }
  }
}

// Provider de score existant
final auraProvider = StateNotifierProvider<AuraScoreNotifier, int>((ref) {
  return AuraScoreNotifier();
});

// L'état de l'utilisateur (Identité)
class UserState {
  final User? user;

  UserState({this.user});

  // Fonction calculée pour le titre
  String getTitle(int points) {
    if (points < 1000) return 'Aura Éveil';
    if (points < 100000) return 'Aura Farmer';
    return 'Aura INFINIE';
  }
}

// La logique de l'utilisateur
class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState());

  // Appelé au démarrage de l'app ou après login
  Future<void> refreshUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      state = UserState(user: user);
    } else {
      state = UserState(user: null);
    }
  }

  // Appelé lors du logout pour tout nettoyer
  void clear() {
    state = UserState(user: null);
  }
}

// Le provider utilisateur global
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});