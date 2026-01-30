import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:aura_app/config/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modèle pour les stats
class AuraStats {
  final Map<int, int> weeklyActivity;
  final Map<String, int> subjectDistribution;

  AuraStats({required this.weeklyActivity, required this.subjectDistribution});
}

// Provider pour récupérer les stats
final statsProvider = FutureProvider<AuraStats>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  
  // Default data structure
  Map<int, int> activity = {1:0, 2:0, 3:0, 4:0, 5:0, 6:0, 7:0};
  // Initialize with at least 3 subjects to satisfy RadarChart requirements
  Map<String, int> distribution = {
    'Maths': 0,
    'Français': 0,
    'Histoire': 0,
  };

  if (user == null) {
    return AuraStats(weeklyActivity: activity, subjectDistribution: distribution);
  }

  try {
    final response = await Supabase.instance.client
        .from('study_sessions')
        .select('created_at, subject')
        .eq('user_id', user.id); 

    final List<dynamic> data = response as List<dynamic>;

    for (var session in data) {
      final date = DateTime.parse(session['created_at']).toLocal();
      if (date.weekday >= 1 && date.weekday <= 7) {
         activity[date.weekday] = (activity[date.weekday] ?? 0) + 1;
      }

      String rawSubject = session['subject'] ?? 'Général';
      // Normalize subject name if you want (e.g. capitalized)
      String subject = rawSubject.isEmpty ? 'Général' : rawSubject;
      
      distribution[subject] = (distribution[subject] ?? 0) + 1;
    }

    return AuraStats(weeklyActivity: activity, subjectDistribution: distribution);
  } catch (e) {
    print("Erreur Stats: $e");
    // Return safe default on error
    return AuraStats(weeklyActivity: activity, subjectDistribution: distribution);
  }
});

class StatsSection extends ConsumerWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return statsAsync.when(
      data: (stats) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Text("ANALYSE DE L'AURA", style: AuraTextStyles.subtitle.copyWith(fontSize: 18, color: AuraColors.electricCyan))),
          const SizedBox(height: 24),

          Center(child: Text("ACTIVITÉ HEBDOMADAIRE", style: AuraTextStyles.subtitle, textAlign: TextAlign.center)),
          const SizedBox(height: 16),
          _buildActivityChart(stats.weeklyActivity),
          
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

  Widget _buildActivityChart(Map<int, int> weeklyActivity) {
    double maxY = 5.0; 
    if (weeklyActivity.isNotEmpty) {
      final maxValue = weeklyActivity.values.fold(0, (prev, element) => element > prev ? element : prev);
      maxY = (maxValue + 2).toDouble();
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AuraColors.abyssalGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
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
                  const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                  if (value.toInt() >= 0 && value.toInt() < 7) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(days[value.toInt()], style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
          barGroups: List.generate(7, (index) {
            final count = weeklyActivity[index + 1] ?? 0;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  gradient: LinearGradient(
                    colors: [AuraColors.electricCyan, AuraColors.electricCyan.withOpacity(0.0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  width: 12,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildRadarChart(Map<String, int> subjectDistribution) {
    final subjects = subjectDistribution.keys.toList();
    final counts = subjectDistribution.values.toList();
    
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
            if (index < subjects.length) return RadarChartTitle(text: subjects[index]);
            return const RadarChartTitle(text: "");
          },
          tickCount: 3,
          dataSets: [
             RadarDataSet(
              fillColor: AuraColors.purple.withOpacity(0.2), // Variation couleur
              borderColor: AuraColors.purple,
              entryRadius: 3,
              dataEntries: counts.map((c) => RadarEntry(value: c.toDouble())).toList(),
              borderWidth: 2,
            ),
          ],
        ),
        swapAnimationDuration: const Duration(milliseconds: 600),
      ),
    );
  }
}
