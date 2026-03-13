import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ==========================================================
// 1. GESTION DU SCORE
// ==========================================================
class AuraScoreNotifier extends StateNotifier<int> {
  final Ref ref;
  AuraScoreNotifier(this.ref) : super(0) { _initScore(); }
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
  Future<Map<String, dynamic>> completeSession() async {
    final user = Supabase.instance.client.auth.currentUser;
    final prefs = await SharedPreferences.getInstance();
    
    int streak = prefs.getInt('current_streak') ?? 0;
    String? lastDateStr = prefs.getString('last_study_date');
    DateTime now = DateTime.now();
    
    bool isFirstSessionToday = true;

    if (lastDateStr != null) {
      final lastDate = DateTime.parse(lastDateStr).toLocal();
      if (lastDate.year == now.year && 
          lastDate.month == now.month && 
          lastDate.day == now.day) {
        isFirstSessionToday = false;
      }
    }

    int earnedPoints;
    String? badgeEarned;

    if (isFirstSessionToday) {
      // SCÉNARIO A : Nouvelle journée
      streak++;
      earnedPoints = 50 * streak;
      
      // On met à jour les préférences immédiatement
      await prefs.setInt('current_streak', streak);
      await prefs.setString('last_study_date', now.toIso8601String());
      
      // Vérification et déblocage des badges (Uniquement lors d'un nouveau jour de streak)
      badgeEarned = await _checkAndUnlockBadges(streak);
      
      // On force le rafraîchissement des badges
      ref.invalidate(badgesProvider);
    } else {
      // SCÉNARIO B : Déjà joué aujourd'hui
      earnedPoints = 50; 
      badgeEarned = null;
    }
    
    // Mise à jour état local (Points)
    state += earnedPoints;
    await prefs.setInt(_storageKey, state);

    // Sauvegarde Cloud (On écrase toujours avec la dernière date et le streak actuel)
    if (user != null) {
        try {
            await Supabase.instance.client.from('profiles').update({
                'aura_points': state,
                'current_streak': streak,
                'last_study_date': now.toIso8601String(),
            }).eq('id', user.id);
        } catch(e) { print("Erreur Cloud Update: $e"); }
    }

    return {
      'points': earnedPoints, 
      'streak': streak,
      'badge': badgeEarned,
    };
  }

  // 👇 RÉCOMPENSE L'EFFORT DE LECTURE (+25)
  Future<void> addPoints(int points) async {
    final user = Supabase.instance.client.auth.currentUser;
    final prefs = await SharedPreferences.getInstance();

    state += points;
    await prefs.setInt(_storageKey, state);

    if (user != null) {
      try {
        await Supabase.instance.client.from('profiles').update({
          'aura_points': state,
        }).eq('id', user.id);
      } catch (e) {
        print("Erreur addPoints Cloud: $e");
      }
    }
  }

  Future<String?> _checkAndUnlockBadges(int streak) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    String? lastBadge;

    // Tous les 7 jours -> Sceau Hebdo
    if (streak % 7 == 0) {
      await Supabase.instance.client.from('user_badges').insert({
        'user_id': user.id,
        'badge_id': 'streak_7',
      });
      lastBadge = "Sceau Hebdo";
    }

    // Tous les 30 jours -> Sceau Mensuel
    if (streak % 30 == 0) {
      await Supabase.instance.client.from('user_badges').insert({
        'user_id': user.id,
        'badge_id': 'streak_30',
      });
      lastBadge = "Sceau Mensuel";
    }

    // Tous les 90 jours -> Sceau Trimestriel
    if (streak % 90 == 0) {
      await Supabase.instance.client.from('user_badges').insert({
        'user_id': user.id,
        'badge_id': 'streak_90',
      });
      lastBadge = "Sceau Trimestriel";
    }

    // Tous les 365 jours -> Sceau Solaire
    if (streak % 365 == 0) {
      await Supabase.instance.client.from('user_badges').insert({
        'user_id': user.id,
        'badge_id': 'streak_365',
      });
      lastBadge = "Sceau Solaire";
    }

    return lastBadge;
  }
  
  Future<void> logout() async {
    // 1. Vider le state local (Riverpod)
    state = 0; 
    
    // 2. Vider le cache local
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('aura_score');
    await prefs.remove('current_streak');
    await prefs.remove('last_study_date');
    
    // 3. Déconnexion Supabase
    await Supabase.instance.client.auth.signOut();
  }
}

final auraProvider = StateNotifierProvider<AuraScoreNotifier, int>((ref) {
  return AuraScoreNotifier(ref);
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

// Provider pour récupérer les badges de l'utilisateur avec leur quantité
final badgesProvider = FutureProvider<Map<String, int>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return {};

  try {
    // On récupère TOUS les badges de l'utilisateur
    final data = await Supabase.instance.client
        .from('user_badges')
        .select('badge_id')
        .eq('user_id', user.id);
    
    final Map<String, int> badgeCounts = {};

    for (var item in (data as List)) {
      final id = item['badge_id'] as String;
      badgeCounts[id] = (badgeCounts[id] ?? 0) + 1;
    }

    return badgeCounts;
  } catch (e) {
    print("Erreur badges provider: $e");
    return {};
  }
  
});