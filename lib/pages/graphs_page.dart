import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:health/health.dart';

class GraphsPage extends StatelessWidget {
  
  final Map<String, List<HealthDataPoint>> health;

  const GraphsPage({super.key, required this.health});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Graphs")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildGraphSection(context, "Steps", health["steps"] ?? [], Colors.blue),
            const SizedBox(height: 32),
            _buildGraphSection(context, "Calories", health["calories"] ?? [], Colors.red),
            const SizedBox(height: 32),
            _buildGraphSection(context, "Distance", health["distance"] ?? [], Colors.green),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }


  Widget _buildGraphSection(BuildContext context, String title,
      List<HealthDataPoint> data, Color color) {
    final Map<DateTime, double> dailyTotals = {};

    for (var point in data) {
      final date = DateTime(
          point.dateFrom.year, point.dateFrom.month, point.dateFrom.day);
      final value = (point.value as NumericHealthValue?)?.numericValue ?? 0.0;
      dailyTotals[date] = (dailyTotals[date] ?? 0) + value;
    }

    final sortedDates = dailyTotals.keys.toList()..sort();
    final values = sortedDates.map((d) => dailyTotals[d]!).toList();

    final maxY =
        values.isEmpty ? 100.0 : values.reduce((a, b) => a > b ? a : b);

    double getSmartInterval(double max) {
      // if (max <= 10) return 2;
      // if (max <= 50) return 10;
      // if (max <= 100) return 20;
      // if (max <= 300) return 50;
      // if (max <= 600) return 100;
      // return 200;

      if (max == 0) return 1;
      return (max / 10).ceilToDouble();
    }

    final yInterval = getSmartInterval(maxY);

    final barGroups = List.generate(sortedDates.length, (i) {
      final date = sortedDates[i];
      final value = dailyTotals[date]!;
      return BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: value, color: color, width: 20),
      ]);
    });

    final dateLabels = sortedDates.map((d) => "${d.day}/${d.month}").toList();

    if (barGroups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("No data available"),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: barGroups.length * 60,
            height: 250,
            child: BarChart(
              BarChartData(
                maxY: maxY + yInterval,
                barGroups: barGroups,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: yInterval,
                      reservedSize: 40, // Increase width reserved for Y-axis
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                              fontSize: 12), // Reduce font size if needed
                          textAlign: TextAlign.left,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 || index >= dateLabels.length)
                          return const SizedBox();
                        return Text(dateLabels[index],
                            style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
