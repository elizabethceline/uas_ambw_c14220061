import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/mood.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseService = Provider.of<SupabaseService>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: user == null
          ? const Center(child: Text('User not found. Please log in again.'))
          : StreamBuilder<List<Mood>>(
              stream: supabaseService.getMoodHistory(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue.shade700,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('An error occurred: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Not enough data to show statistics.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final moods = snapshot.data!;
                final moodCounts = <String, int>{};
                for (var mood in moods) {
                  moodCounts[mood.mood] = (moodCounts[mood.mood] ?? 0) + 1;
                }

                String mostFrequentMood = 'N/A';
                if (moodCounts.isNotEmpty) {
                  mostFrequentMood = moodCounts.entries
                      .reduce((a, b) => a.value > b.value ? a : b)
                      .key;
                }

                final pieChartSections = moodCounts.entries.map((entry) {
                  final percentage = (entry.value / moods.length) * 100;
                  return PieChartSectionData(
                    color: _getColorForMood(entry.key),
                    value: entry.value.toDouble(),
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: 100,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                    ),
                    badgeWidget: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 24),
                    ),
                    badgePositionPercentageOffset: .98,
                  );
                }).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Your Mood Distribution',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        height: 250,
                        child: PieChart(
                          PieChartData(
                            sections: pieChartSections,
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildStatCard(
                        title: 'Total Entries',
                        value: moods.length.toString(),
                        icon: Icons.format_list_numbered,
                        iconColor: Colors.green.shade600,
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        title: 'Most Frequent Mood',
                        value: mostFrequentMood,
                        icon: Icons.star_border,
                        iconColor: Colors.purple.shade400,
                        isEmoji: true,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    bool isEmoji = false,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 30),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: isEmoji ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForMood(String mood) {
    switch (mood) {
      case '😊':
        return Colors.green.shade400;
      case '😭':
        return Colors.indigo.shade400;
      case '😐':
        return Colors.pink.shade300;
      case '😔':
        return Colors.blue.shade400;
      case '😡':
        return Colors.red.shade400;
      default:
        return Colors.grey;
    }
  }
}
