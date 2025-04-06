import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:task_1/models/transaction.dart';

class StatisticsScreen extends StatelessWidget {
  final String language;

  const StatisticsScreen({super.key, this.language = 'English'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_rounded, color: Colors.blueAccent.shade700),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          language == 'English' ? 'Statistics' : 'Статистика',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent.shade700,
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Transaction>('transactions').listenable(),
        builder: (context, Box<Transaction> box, _) {
          final income = box.values
              .where((t) => t.isIncome)
              .fold<double>(0.0, (sum, t) => sum + t.amount);
          final expense = box.values
              .where((t) => !t.isIncome)
              .fold<double>(0.0, (sum, t) => sum + t.amount);
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: PieChart(
                    PieChartData(
                      sections: [
                        if (income > 0)
                          PieChartSectionData(
                            value: income,
                            color: Colors.blueAccent.shade700,
                            title:
                                '${language == 'English' ? 'Income' : 'Доходы'}\n${income.toStringAsFixed(2)} ₽',
                            radius: 100,
                            titleStyle: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (expense > 0)
                          PieChartSectionData(
                            value: expense,
                            color: Colors.redAccent,
                            title:
                                '${language == 'English' ? 'Expenses' : 'Расходы'}\n${expense.toStringAsFixed(2)} ₽',
                            radius: 100,
                            titleStyle: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                      sectionsSpace: 4,
                      centerSpaceRadius: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        language == 'English'
                            ? 'Total Balance:'
                            : 'Общий баланс:',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent.shade700,
                        ),
                      ),
                      Text(
                        '${(income - expense).toStringAsFixed(2)} ₽',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: income >= expense
                              ? Colors.blueAccent.shade700
                              : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
