import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/agenda_models.dart';
import '../../../services/agenda_service.dart';

class DeadlinesScreen extends StatefulWidget {
  const DeadlinesScreen({Key? key}) : super(key: key);

  @override
  State<DeadlinesScreen> createState() => _DeadlinesScreenState();
}

class _DeadlinesScreenState extends State<DeadlinesScreen> {
  final AgendaService _agendaService = AgendaService();
  bool _isLoading = true;
  List<DeadlineTask> _deadlines = [];

  // Constantes de style
  final Color _bgColor = const Color(0xFF0F172A);
  final Color _cyanAccent = const Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();
    _loadDeadlines();
  }

  Future<void> _loadDeadlines() async {
    setState(() => _isLoading = true);
    try {
      final deadlines = await _agendaService.getMyDeadlines();
      setState(() {
        _deadlines = deadlines;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _toggleCompletion(int index, bool? value) async {
    if (value == null) return;
    
    final task = _deadlines[index];
    final originalState = task.isCompleted;

    // Mise à jour locale (optimiste)
    setState(() {
      _deadlines[index] = DeadlineTask(
        id: task.id,
        userId: task.userId,
        dueDate: task.dueDate,
        subject: task.subject,
        taskType: task.taskType,
        description: task.description,
        isCompleted: value,
      );
    });

    try {
      if (task.id != null) {
        await _agendaService.toggleTaskCompletion(task.id!, value);
      }
    } catch (e) {
      // En cas d'erreur, on annule le changement local
      if (mounted) {
        setState(() {
          _deadlines[index] = DeadlineTask(
            id: task.id,
            userId: task.userId,
            dueDate: task.dueDate,
            subject: task.subject,
            taskType: task.taskType,
            description: task.description,
            isCompleted: originalState,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddDeadlineSheet(
        agendaService: _agendaService,
        onAdded: _loadDeadlines,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text(
          'Mes Devoirs & DS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _cyanAccent))
          : _deadlines.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun devoir ou DS à venir ! 🎉',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _deadlines.length,
                  itemBuilder: (context, index) {
                    final task = _deadlines[index];
                    final isDS = task.taskType == 'DS';
                    final color = isDS ? Colors.redAccent : _cyanAccent;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: task.isCompleted
                              ? Colors.transparent
                              : color.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (val) => _toggleCompletion(index, val),
                          activeColor: _cyanAccent,
                          checkColor: _bgColor,
                          side: BorderSide(
                            color: task.isCompleted ? Colors.grey : color,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        title: Text(
                          task.subject,
                          style: TextStyle(
                            color: task.isCompleted
                                ? Colors.grey
                                : Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  isDS
                                      ? Icons.warning_amber_rounded
                                      : Icons.assignment_outlined,
                                  color: task.isCompleted ? Colors.grey : color,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  task.taskType,
                                  style: TextStyle(
                                    color: task.isCompleted
                                        ? Colors.grey
                                        : color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey[400],
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(task.dueDate),
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                              ],
                            ),
                            if (task.description != null &&
                                task.description!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                task.description!,
                                style: TextStyle(
                                  color: task.isCompleted
                                      ? Colors.grey
                                      : Colors.grey[300],
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: _cyanAccent,
        foregroundColor: _bgColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddDeadlineSheet extends StatefulWidget {
  final AgendaService agendaService;
  final VoidCallback onAdded;

  const _AddDeadlineSheet({
    Key? key,
    required this.agendaService,
    required this.onAdded,
  }) : super(key: key);

  @override
  State<_AddDeadlineSheet> createState() => _AddDeadlineSheetState();
}

class _AddDeadlineSheetState extends State<_AddDeadlineSheet> {
  final _formKey = GlobalKey<FormState>();
  String _taskType = 'DEVOIR';
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSaving = false;

  final Color _sheetBgColor = const Color(0xFF1E293B);
  final Color _cyanAccent = const Color(0xFF00E5FF);

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: _cyanAccent,
              onPrimary: const Color(0xFF0F172A),
              surface: _sheetBgColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez choisir une date'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final task = DeadlineTask(
        dueDate: _selectedDate!,
        subject: _subjectController.text.trim(),
        taskType: _taskType,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      await widget.agendaService.addDeadline(task);

      if (mounted) {
        Navigator.pop(context); // Fermer le bottom sheet
        widget.onAdded(); // Rafraîchir la liste
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ajouté avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding pour soulever le formulaire avec le clavier virtuel
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _sheetBgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.white10),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nouveau $_taskType',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'DEVOIR', label: Text('Devoir')),
                  ButtonSegment(value: 'DS', label: Text('DS')),
                ],
                selected: {_taskType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _taskType = newSelection.first);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return _taskType == 'DS'
                            ? Colors.redAccent.withOpacity(0.2)
                            : _cyanAccent.withOpacity(0.2);
                      }
                      return Colors.transparent;
                    },
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return _taskType == 'DS'
                            ? Colors.redAccent
                            : _cyanAccent;
                      }
                      return Colors.grey;
                    },
                  ),
                  side: WidgetStateProperty.all(
                    const BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _subjectController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Matière',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _cyanAccent),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Veuillez entrer une matière'
                    : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Choisir une date'
                            : 'Pour le : ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                        style: TextStyle(
                          color: _selectedDate == null
                              ? Colors.grey
                              : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Icon(Icons.calendar_today, color: _cyanAccent),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Description (Optionnel) ex: Ex 4 page 12',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _cyanAccent),
                  ),
                ),
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cyanAccent,
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Color(0xFF0F172A),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Sauvegarder',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
