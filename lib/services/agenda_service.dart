// services/agenda_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/agenda_models.dart';

class AgendaService {
  final _supabase = Supabase.instance.client;

  // --- EMPLOI DU TEMPS ---

  // Récupérer l'emploi du temps de l'élève connecté
  Future<List<TimetableEntry>> getMyTimetable() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('user_timetable')
        .select()
        .eq('user_id', userId)
        .order('day_of_week', ascending: true)
        .order('start_time', ascending: true);

    return response.map((map) => TimetableEntry.fromMap(map)).toList();
  }

  // Ajouter un cours à l'emploi du temps
  Future<void> addTimetableEntry(TimetableEntry entry) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("Utilisateur non connecté");

    // --- VÉRIFICATION DES CHEVAUCHEMENTS ---
    // On cherche s'il y a déjà un cours le même jour...
    // ...qui commence AVANT que le nouveau ne finisse (lt)
    // ...ET qui finit APRÈS que le nouveau ne commence (gt)
    final existingClasses = await _supabase
        .from('user_timetable')
        .select()
        .eq('user_id', userId)
        .eq('day_of_week', entry.dayOfWeek)
        .lt('start_time', '${entry.endTime}:00')
        .gt('end_time', '${entry.startTime}:00');

    if (existingClasses.isNotEmpty) {
      // S'il trouve quelque chose, on bloque tout et on lève une erreur claire !
      throw Exception("Tu as déjà un cours programmé sur ce créneau horaire ! ⏳");
    }
    // ---------------------------------------

    final data = entry.toMap();
    data['user_id'] = userId; // On force l'ID de l'utilisateur

    await _supabase.from('user_timetable').insert(data);
  }


  // --- DEVOIRS ET DS ---

  // Récupérer les devoirs/DS à venir
  Future<List<DeadlineTask>> getMyDeadlines() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('user_deadlines')
        .select()
        .eq('user_id', userId)
        .gte('due_date', DateTime.now().toIso8601String().split('T')[0]) // Uniquement le futur ou aujourd'hui
        .order('due_date', ascending: true);

    return response.map((map) => DeadlineTask.fromMap(map)).toList();
  }

  // Ajouter un devoir ou DS
  Future<void> addDeadline(DeadlineTask task) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("Utilisateur non connecté");

    final data = task.toMap();
    data['user_id'] = userId;

    await _supabase.from('user_deadlines').insert(data);
  }

  // Cocher/Décocher un devoir
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    await _supabase
        .from('user_deadlines')
        .update({'is_completed': isCompleted})
        .eq('id', taskId);
  }
}