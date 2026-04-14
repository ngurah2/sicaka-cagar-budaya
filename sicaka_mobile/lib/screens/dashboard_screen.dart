import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'DASHBOARD ANALITIK',
          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A), letterSpacing: 1.5),
        ),
      ),
      body: FutureBuilder<List<EventModel>>(
        future: _apiService.fetchEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Belum ada data untuk dianalisis.'));

          List<EventModel> events = snapshot.data!;

          int totalKegiatan = events.length;
          int totalTerlaksana = events.where((e) => e.status == 'Terlaksana').length;
          int totalSegera = events.where((e) => e.status == 'Segera').length;

          Map<String, int> monthlyCount = {};
          for (var e in events) {
            List<String> parts = e.monthYear.split(' ');
            String monthName = parts.length >= 2 ? parts[parts.length - 2] : "Unknown"; 
            monthlyCount[monthName] = (monthlyCount[monthName] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ringkasan Cagar Budaya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(child: _buildSummaryCard('Total', totalKegiatan.toString(), const Color(0xFF1E3A8A))), // Biru Tua
                    const SizedBox(width: 12),
                    Expanded(child: _buildSummaryCard('Selesai', totalTerlaksana.toString(), Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSummaryCard('Segera', totalSegera.toString(), const Color(0xFFD4AF37))), // Emas
                  ],
                ),
                const SizedBox(height: 24),

                const Text('Persentase Pelaksanaan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)]),
                  height: 250,
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                color: Colors.green,
                                value: totalTerlaksana.toDouble(),
                                title: '${((totalTerlaksana / totalKegiatan) * 100).toStringAsFixed(1)}%',
                                radius: 50,
                                titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              PieChartSectionData(
                                color: const Color(0xFFD4AF37),
                                value: totalSegera.toDouble(),
                                title: '${((totalSegera / totalKegiatan) * 100).toStringAsFixed(1)}%',
                                radius: 50,
                                titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Indicator(color: Colors.green, text: 'Terlaksana'),
                          SizedBox(height: 8),
                          _Indicator(color: Color(0xFFD4AF37), text: 'Segera'),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text('Distribusi Kegiatan Bulanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.only(top: 32, right: 16, left: 8, bottom: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)]),
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (monthlyCount.values.isEmpty ? 5 : monthlyCount.values.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              if (value.toInt() >= 0 && value.toInt() < monthlyCount.keys.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(monthlyCount.keys.elementAt(value.toInt()).substring(0, 3), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 1)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(
                        monthlyCount.length,
                        (index) => BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: monthlyCount.values.elementAt(index).toDouble(),
                              color: const Color(0xFF1E3A8A), // Biru Tua
                              width: 22,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  const _Indicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}