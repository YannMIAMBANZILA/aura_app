import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:aura_app/config/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Modèle pour les stats
// Provider pour l'onglet de temps (Jour, Semaine, Mois)
enum Timeframe { day, week, month }

final timeframeProvider = StateProvider<Timeframe>((ref) => Timeframe.week);

// Provider pour filtrer l'activité par index de barre sélectionnée
final selectedBarIndexProvider = StateProvider<int?>((ref) => null);

// Modèle pour les stats
class AuraStats {
  final List<BarChartGroupData> activityGroups;
  final Map<String, int> subjectDistribution;
  final double maxY;
  final List<String> xLabels;

  AuraStats({
    required this.activityGroups, 
    required this.subjectDistribution, 
    required this.maxY,
    required this.xLabels,
  });
}

// Provider pour récupérer les stats
final statsProvider = FutureProvider<AuraStats>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  final timeframe = ref.watch(timeframeProvider);
  
  if (user == null) {
    return AuraStats(
      activityGroups: [], 
      subjectDistribution: {}, 
      maxY: 5, 
      xLabels: [],
    );
  }

  try {
    final response = await Supabase.instance.client
        .from('study_sessions')
        .select()
        .eq('user_id', user.id); 

    final List<dynamic> data = response as List<dynamic>;
    Map<String, int> distribution = {};
    Map<String, int> activityMap = {};
    List<String> labels = [];

    final now = DateTime.now();

    if (timeframe == Timeframe.week) {
      // 7 derniers jours
      labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
      for (int i = 1; i <= 7; i++) activityMap[i.toString()] = 0;
      
      for (var session in data) {
        final date = DateTime.parse(session['created_at']).toLocal();
        // Filtrer par semaine actuelle (ou 7 derniers jours ?)
        // On va rester sur les jours de la semaine ISO pour l'instant
        activityMap[date.weekday.toString()] = (activityMap[date.weekday.toString()] ?? 0) + 1;
        
        String? subject = session['subject'] as String?;
        if (subject != null && subject != 'Général' && subject.isNotEmpty) {
          distribution[subject] = (distribution[subject] ?? 0) + 1;
        }
      }
    } else if (timeframe == Timeframe.day) {
      // Dernières 24h par tranches de 4h ? Ou les 7 derniers jours ?
      // L'utilisateur dit "trié par jour", on va montrer les 7 derniers jours avec la date
      for (int i = 6; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        final key = "${d.day}/${d.month}";
        labels.add(key);
        activityMap[key] = 0;
      }
      for (var session in data) {
        final date = DateTime.parse(session['created_at']).toLocal();
        final key = "${date.day}/${date.month}";
        if (activityMap.containsKey(key)) {
          activityMap[key] = (activityMap[key] ?? 0) + 1;
        }
        
        String? subject = session['subject'] as String?;
        if (subject != null && subject != 'Général' && subject.isNotEmpty) {
          distribution[subject] = (distribution[subject] ?? 0) + 1;
        }
      }
    } else {
      // Mois de l'année
      labels = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
      for (int i = 1; i <= 12; i++) activityMap[i.toString()] = 0;
      for (var session in data) {
        final date = DateTime.parse(session['created_at']).toLocal();
        if (date.year == now.year) {
          activityMap[date.month.toString()] = (activityMap[date.month.toString()] ?? 0) + 1;
        }
        String? subject = session['subject'] as String?;
        if (subject != null && subject != 'Général' && subject.isNotEmpty) {
          distribution[subject] = (distribution[subject] ?? 0) + 1;
        }
      }
    }

    double mY = 5.0;
    if (activityMap.isNotEmpty) {
      final maxValue = activityMap.values.fold(0, (prev, element) => element > prev ? element : prev);
      mY = (maxValue + 2).toDouble();
    }

    final List<BarChartGroupData> groups = [];
    for (int i = 0; i < labels.length; i++) {
      String key;
      if (timeframe == Timeframe.week) key = (i + 1).toString();
      else if (timeframe == Timeframe.day) key = labels[i];
      else key = (i + 1).toString();

      final count = activityMap[key] ?? 0;
      groups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            gradient: LinearGradient(
              colors: [AuraColors.electricCyan, AuraColors.electricCyan.withOpacity(0.1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            width: 14,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: mY,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ],
      ));
    }

    return AuraStats(
      activityGroups: groups,
      subjectDistribution: distribution.isEmpty ? {'Maths':0, 'Français':0, 'Physique':0} : distribution,
      maxY: mY,
      xLabels: labels,
    );
  } catch (e) {
    print("Erreur Stats: $e");
    return AuraStats(activityGroups: [], subjectDistribution: {}, maxY: 5, xLabels: []);
  }
});

class StatsSection extends ConsumerWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final timeframe = ref.watch(timeframeProvider);

    return statsAsync.when(
      data: (stats) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Text("ANALYSE DE L'AURA", style: AuraTextStyles.subtitle.copyWith(fontSize: 18, color: AuraColors.electricCyan))),
          const SizedBox(height: 24),

          // TOGGLE TIMEFRAME
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeframeButton(ref, "Jour", Timeframe.day, timeframe == Timeframe.day),
              const SizedBox(width: 8),
              _buildTimeframeButton(ref, "Semaine", Timeframe.week, timeframe == Timeframe.week),
              const SizedBox(width: 8),
              _buildTimeframeButton(ref, "Mois", Timeframe.month, timeframe == Timeframe.month),
            ],
          ),
          const SizedBox(height: 24),

          Center(child: Text("ACTIVITÉ ${timeframe.name.toUpperCase() == 'DAY' ? 'QUOTIDIENNE' : timeframe.name.toUpperCase() == 'WEEK' ? 'HEBDOMADAIRE' : 'MENSUELLE'}", style: AuraTextStyles.subtitle, textAlign: TextAlign.center)),
          const SizedBox(height: 16),
          _buildActivityChart(ref, stats),
          
          const SizedBox(height: 40),
          
          Center(child: Text("ÉQUILIBRE DES MATIÈRES", style: AuraTextStyles.subtitle, textAlign: TextAlign.center)),
          const SizedBox(height: 16),
          _buildRadarChart(stats.subjectDistribution),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator(color: AuraColors.electricCyan)),
      error: (err, stack) => Center(child: Text("Erreur de chargement des stats", style: TextStyle(color: AuraColors.softCoral))),
    );
  }

  Widget _buildTimeframeButton(WidgetRef ref, String label, Timeframe value, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ref.read(timeframeProvider.notifier).state = value;
        ref.read(selectedBarIndexProvider.notifier).state = null; // Reset filter
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AuraColors.electricCyan.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AuraColors.electricCyan : Colors.white10),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            color: isSelected ? AuraColors.electricCyan : Colors.white38,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityChart(WidgetRef ref, AuraStats stats) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AuraColors.abyssalGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: stats.maxY,
          barTouchData: BarTouchData(
            touchCallback: (FlTouchEvent event, barTouchResponse) {
              if (!event.isInterestedForInteractions ||
                  barTouchResponse == null ||
                  barTouchResponse.spot == null) {
                return;
              }
              final index = barTouchResponse.spot!.touchedBarGroupIndex;
              ref.read(selectedBarIndexProvider.notifier).state = index;
            },
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.black87,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                 return BarTooltipItem(
                    '${rod.toY.toInt()} sessions',
                    const TextStyle(color: AuraColors.electricCyan, fontWeight: FontWeight.bold),
                 );
              }
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < stats.xLabels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(stats.xLabels[index], style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true, 
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: stats.activityGroups,
        ),
      ),
    );
  }

  Widget _buildRadarChart(Map<String, int> subjectDistribution) {
    // Filtrer 'Général' est déjà fait dans le provider, mais on s'assure d'avoir au moins 3 points
    final entries = subjectDistribution.entries.toList();
    if (entries.length < 3) {
      // Padding pour le RadarChart qui a besoin de 3 points minimum
      while (entries.length < 3) {
        entries.add(const MapEntry('...', 0));
      }
    }
    
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AuraColors.abyssalGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          ticksTextStyle: const TextStyle(color: Colors.transparent),
          gridBorderData: const BorderSide(color: Colors.white12, width: 2),
          titlePositionPercentageOffset: 0.2,
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 12),
          getTitle: (index, angle) {
            if (index < entries.length) return RadarChartTitle(text: entries[index].key);
            return const RadarChartTitle(text: "");
          },
          tickCount: 3,
          dataSets: [
             RadarDataSet(
              fillColor: AuraColors.purple.withOpacity(0.2),
              borderColor: AuraColors.purple,
              entryRadius: 3,
              dataEntries: entries.map((e) => RadarEntry(value: e.value.toDouble())).toList(),
              borderWidth: 2,
            ),
          ],
        ),
        swapAnimationDuration: const Duration(milliseconds: 600),
      ),
    );
  }
}
