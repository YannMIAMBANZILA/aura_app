import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ==========================================================
// 1. GESTION DU SCORE
// ==========================================================
class AuraScoreNotifier extends StateNotifier<int> {
  AuraScoreNotifier() : super(0) { _initScore(); }
  static const _storageKey = 'aura_score';

  Future<void> _initScore() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
         final data = await Supabase.instance.client
          .from('profiles')
          .select('aura_points')
          .eq('id', user.id)
          .single();
         state = data['aura_points'] as int;
      } catch (e) {
        _loadFromLocal();
      }
    } else {
      await _loadFromLocal();
    }
  }

  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_storageKey) ?? 0;
  }

  // 👇 LA MÉTHODE RESTAURÉE (Indispensable pour le Login)
  Future<void> syncLocalToCloud() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final localScore = prefs.getInt(_storageKey) ?? 0;

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('aura_points')
          .eq('id', user.id)
          .single();
      
      final cloudScore = data['aura_points'] as int;

      // On garde le meilleur des deux
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

  // La fonction pour la fin de session (Calcul Streak)
  Future<Map<String, int>> completeSession() async {
    final user = Supabase.instance.client.auth.currentUser;
    
    // Logique simplifiée de streak (tu pourras la complexifier avec la BDD plus tard)
    final prefs = await SharedPreferences.getInstance();
    int streak = (prefs.getInt('current_streak') ?? 0) + 1;
    await prefs.setInt('current_streak', streak);

    // Calcul du gain
    int earnedPoints = 50 * streak; 
    
    // Mise à jour état local
    state += earnedPoints;
    await prefs.setInt(_storageKey, state);

    // Sauvegarde Cloud
    if (user != null) {
        try {
            await Supabase.instance.client.from('profiles').update({
                'aura_points': state,
                'current_streak': streak,
                'last_study_date': DateTime.now().toIso8601String(),
            }).eq('id', user.id);
        } catch(e) { print(e); }
    }

    return {'points': earnedPoints, 'streak': streak};
  }
}

final auraProvider = StateNotifierProvider<AuraScoreNotifier, int>((ref) {
  return AuraScoreNotifier();
});

// ==========================================================
// 2. GESTION DE L'UTILISATEUR (Status & Titre)
// ==========================================================
class UserState {
  final User? user;
  UserState({this.user});

  String getTitle(int score) {
    if (score < 1000) return "Aura Éveil";
    if (score < 100000) return "Aura Farmer";
    return "Aura INFINIE";
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState());

  // Helper pour l'UI
  String getTitle(int score) => state.getTitle(score);

  Future<void> refreshUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      state = UserState(user: user);
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});