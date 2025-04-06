import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_1/blocs/auth_bloc.dart';
import 'package:task_1/models/transaction.dart';
import 'package:task_1/screens/add_transaction_screen.dart';
import 'package:task_1/screens/statistics_screen.dart';
import 'package:task_1/screens/settings_screen.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:task_1/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_1/services/pdf_service.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String language;

  const HomeScreen(
      {super.key, required this.userName, this.language = 'English'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String filter = 'all';
  final _searchController = TextEditingController();
  final PdfService _pdfService = PdfService();
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _language = widget.language;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateLanguage(String language) {
    setState(() {
      _language = language;
    });
  }

  Future<void> _exportToCsv(Box<Transaction> box) async {
    List<List<dynamic>> rows = [
      ['Category', 'Amount', 'Date', 'Description', 'Type'],
      ...box.values.map((t) => [
            t.category,
            t.amount,
            t.date.toIso8601String(),
            t.description ?? '',
            t.isIncome ? 'Income' : 'Expense',
          ]),
    ];
    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getExternalStorageDirectory();
    final file = File('${directory!.path}/transactions.csv');
    await file.writeAsString(csv);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _language == 'English'
                ? 'Exported to ${file.path}'
                : 'Экспортировано в ${file.path}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.blueAccent.shade700,
        ),
      );
    }
  }

  Future<void> _exportToPdf(Box<Transaction> box) async {
    final transactions = box.values
        .map((t) => {
              'date': t.date.toString().substring(0, 10),
              'category': t.category,
              'amount': t.amount,
              'isRecurring': t.isRecurring,
            })
        .toList();
    final pdfBytes = await _pdfService.generatePdf(transactions);
    await _pdfService.savePdfToFile(pdfBytes);
    if (mounted) {
      final directory = await getApplicationDocumentsDirectory();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _language == 'English'
                ? 'PDF exported to ${directory.path}/transactions.pdf'
                : 'PDF экспортирован в ${directory.path}/transactions.pdf',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.blueAccent.shade700,
        ),
      );
    }
  }

  Future<void> _showExportDialog() async {
    final box = Hive.box<Transaction>('transactions');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _language == 'English' ? 'Export Format' : 'Формат экспорта',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.blueAccent.shade700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _exportToCsv(box);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
                elevation: 0,
              ),
              child: Text(
                'CSV',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _exportToPdf(box);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
                elevation: 0,
              ),
              child: Text(
                'PDF',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _language == 'English' ? 'Cancel' : 'Отмена',
              style: GoogleFonts.poppins(color: Colors.blueAccent.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, Transaction transaction,
      int index, Box<Transaction> box) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.isIncome
              ? Colors.blueAccent.shade700
              : Colors.redAccent,
          child: Icon(
            transaction.isIncome
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            color: Colors.white,
          ),
        ),
        title: Text(
          transaction.category,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: Colors.blueAccent.shade700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${transaction.amount.toStringAsFixed(2)} ₽ • ${transaction.date.toString().substring(0, 10)}',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.grey.shade600),
            ),
            if (transaction.description != null)
              Text(
                transaction.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey.shade500),
              ),
            if (transaction.isRecurring)
              Text(
                transaction.recurrenceType ??
                    (_language == 'English' ? 'Recurring' : 'Повторяющаяся'),
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.blueAccent.shade400,
                    fontStyle: FontStyle.italic),
              ),
            if (transaction.attachmentPath != null)
              Text(
                _language == 'English'
                    ? 'Attached photo'
                    : 'Прикрепленное фото',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.blueAccent.shade400),
              ),
          ],
        ),
        trailing: transaction.isRecurring
            ? Icon(Icons.repeat_rounded,
                color: Colors.blueAccent.shade700, size: 20)
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(
                transaction: transaction,
                index: index,
                language: _language,
              ),
            ),
          );
        },
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                _language == 'English'
                    ? 'Delete Transaction?'
                    : 'Удалить транзакцию?',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent.shade700),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    _language == 'English' ? 'Cancel' : 'Отмена',
                    style:
                        GoogleFonts.poppins(color: Colors.blueAccent.shade700),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    box.deleteAt(index);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _language == 'English' ? 'Deleted' : 'Удалено',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: Colors.blueAccent.shade700,
                      ),
                    );
                  },
                  child: Text(
                    _language == 'English' ? 'Yes' : 'Да',
                    style: GoogleFonts.poppins(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _language == 'English' ? 'My Finances' : 'Мои финансы',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent.shade700,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list_rounded,
                color: Colors.blueAccent.shade700),
            onSelected: (value) => setState(() => filter = value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Text(
                  _language == 'English' ? 'All' : 'Все',
                  style: GoogleFonts.poppins(),
                ),
              ),
              PopupMenuItem(
                value: 'income',
                child: Text(
                  _language == 'English' ? 'Income' : 'Доходы',
                  style: GoogleFonts.poppins(),
                ),
              ),
              PopupMenuItem(
                value: 'expense',
                child: Text(
                  _language == 'English' ? 'Expenses' : 'Расходы',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
          IconButton(
            icon:
                Icon(Icons.download_rounded, color: Colors.blueAccent.shade700),
            tooltip: _language == 'English' ? 'Export Data' : 'Экспорт данных',
            onPressed: _showExportDialog,
          ),
          IconButton(
            icon: Icon(Icons.pie_chart_rounded,
                color: Colors.blueAccent.shade700),
            tooltip: _language == 'English' ? 'Statistics' : 'Статистика',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StatisticsScreen(language: _language),
              ),
            ),
          ),
          IconButton(
            icon:
                Icon(Icons.settings_rounded, color: Colors.blueAccent.shade700),
            tooltip: _language == 'English' ? 'Settings' : 'Настройки',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  onLanguageChanged: _updateLanguage,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: Colors.blueAccent.shade700),
            tooltip: _language == 'English' ? 'Logout' : 'Выйти',
            onPressed: () async {
              try {
                final authService = AuthService(Supabase.instance);
                await authService.clearSession();
                context.read<AuthBloc>().add(const LogoutEvent());
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (route) => false);
              } catch (e) {
                print('Error during logout: $e');
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _language == 'English'
                    ? 'Search transactions...'
                    : 'Поиск транзакций...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search_rounded,
                    color: Colors.blueAccent.shade700),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable:
                  Hive.box<Transaction>('transactions').listenable(),
              builder: (context, Box<Transaction> box, _) {
                final balance = box.values.fold<double>(0.0,
                    (sum, t) => t.isIncome ? sum + t.amount : sum - t.amount);
                var transactions = box.values.toList()
                  ..sort((a, b) => b.date.compareTo(a.date));
                if (filter != 'all') {
                  transactions = transactions
                      .where(
                          (t) => filter == 'income' ? t.isIncome : !t.isIncome)
                      .toList();
                }
                if (_searchController.text.isNotEmpty) {
                  final query = _searchController.text.toLowerCase();
                  transactions = transactions
                      .where((t) =>
                          t.category.toLowerCase().contains(query) ||
                          (t.description?.toLowerCase().contains(query) ??
                              false))
                      .toList();
                }
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.shade700,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _language == 'English' ? 'Balance' : 'Баланс',
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            Text(
                              '${balance.toStringAsFixed(2)} ₽',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: balance >= 0
                                    ? Colors.white
                                    : Colors.redAccent.shade100,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: transactions.isEmpty
                          ? Center(
                              child: Text(
                                _language == 'English'
                                    ? 'No Transactions'
                                    : 'Нет транзакций',
                                style: GoogleFonts.poppins(
                                    fontSize: 18, color: Colors.grey.shade500),
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = transactions[index];
                                return _buildTransactionTile(
                                    context,
                                    transaction,
                                    box.values.toList().indexOf(transaction),
                                    box);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddTransactionScreen(language: _language),
          ),
        ),
        backgroundColor: Colors.blueAccent.shade700,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
