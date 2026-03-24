import 'package:flutter/material.dart';
import '../../../models/agenda_models.dart';
import '../../../services/agenda_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TimetableSetupScreen extends StatefulWidget {
  const TimetableSetupScreen({Key? key}) : super(key: key);

  @override
  State<TimetableSetupScreen> createState() => _TimetableSetupScreenState();
}

class _TimetableSetupScreenState extends State<TimetableSetupScreen> {
  final AgendaService _agendaService = AgendaService();
  final TextEditingController _subjectController = TextEditingController();

  int _selectedDay = 1; // 1 = Lundi
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 0);

  final List<String> _days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'];

  // NOUVEAU : Pour stocker et afficher les cours
  List<TimetableEntry> _dayClasses = [];
  bool _isLoadingClasses = true;

  @override
  void initState() {
    super.initState();
    _loadClassesForSelectedDay();
  }

  // NOUVEAU : Fonction pour charger les cours du jour sélectionné
  Future<void> _loadClassesForSelectedDay() async {
    setState(() => _isLoadingClasses = true);
    try {
      final allClasses = await _agendaService.getMyTimetable();
      if (mounted) {
        setState(() {
          // On ne garde que les cours du jour cliqué
          _dayClasses = allClasses.where((c) => c.dayOfWeek == _selectedDay).toList();
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement cours : $e");
    } finally {
      if (mounted) setState(() => _isLoadingClasses = false);
    }
  }

  // NOUVEAU : Fonction pour supprimer un cours
  Future<void> _deleteEntry(String id) async {
    try {
      await Supabase.instance.client.from('user_timetable').delete().eq('id', id);
      _loadClassesForSelectedDay(); // On recharge la liste après suppression
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cours supprimé 🗑️')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _saveEntry() async {
    if (_subjectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('N\'oublie pas la matière ! 😅')),
      );
      return;
    }

    final entry = TimetableEntry(
      dayOfWeek: _selectedDay,
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      subject: _subjectController.text.trim().toUpperCase(),
    );

    try {
      await _agendaService.addTimetableEntry(entry);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✨ Cours ajouté !'), backgroundColor: Colors.green),
        );
      }
      _subjectController.clear();
      _loadClassesForSelectedDay(); // On met à jour la liste instantanément !
    } catch (e) {
      // On nettoie le message d'erreur pour qu'il soit joli
      String errorMessage = e.toString().replaceAll("Exception: ", "");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $errorMessage'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Mon Emploi du Temps'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // NOUVEAU : On rend l'écran scrollable pour éviter les problèmes avec le clavier
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8.0,
              children: List.generate(5, (index) {
                final dayNum = index + 1;
                return ChoiceChip(
                  label: Text(_days[index], style: const TextStyle(color: Colors.white)),
                  selected: _selectedDay == dayNum,
                  selectedColor: const Color(0xFF00E5FF),
                  backgroundColor: Colors.white.withOpacity(0.1),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedDay = dayNum);
                      _loadClassesForSelectedDay(); // On recharge si on change de jour
                    }
                  },
                );
              }),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text('Début: ${_startTime.format(context)}'),
                    onPressed: () async {
                      final time = await showTimePicker(context: context, initialTime: _startTime);
                      if (time != null) setState(() => _startTime = time);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.access_time_filled),
                    label: Text('Fin: ${_endTime.format(context)}'),
                    onPressed: () async {
                      final time = await showTimePicker(context: context, initialTime: _endTime);
                      if (time != null) setState(() => _endTime = time);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _subjectController,
              style: const TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Matière (ex: MATHS, HISTOIRE)',
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF00E5FF)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saveEntry,
              child: const Text('AJOUTER CE COURS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),

            const SizedBox(height: 32),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),

            // NOUVEAU : La section d'affichage des cours
            Text(
              'Mes cours du ${_days[_selectedDay - 1]}',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (_isLoadingClasses)
              const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
            else if (_dayClasses.isEmpty)
              const Center(
                child: Text(
                  'Aucun cours enregistré pour ce jour.',
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true, // Important pour qu'elle tienne dans la Column
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _dayClasses.length,
                itemBuilder: (context, index) {
                  final cours = _dayClasses[index];
                  return Card(
                    color: Colors.white.withOpacity(0.05),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.menu_book, color: Color(0xFF00E5FF)),
                      title: Text(cours.subject, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('${cours.startTime} - ${cours.endTime}', style: const TextStyle(color: Colors.grey)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _deleteEntry(cours.id!),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}