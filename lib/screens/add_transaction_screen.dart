import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:task_1/models/transaction.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;
  final int? index;
  final String language;

  const AddTransactionScreen({
    super.key,
    this.transaction,
    this.index,
    this.language = 'English',
  });

  @override
  AddTransactionScreenState createState() => AddTransactionScreenState();
}

class AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _category;
  late double _amount;
  late String _description;
  late bool _isIncome;
  late DateTime _date;
  late bool _isRecurring;
  late String _recurrenceType;
  String? _attachmentPath;

  @override
  void initState() {
    super.initState();
    _category = widget.transaction?.category ?? '';
    _amount = widget.transaction?.amount ?? 0.0;
    _description = widget.transaction?.description ?? '';
    _isIncome = widget.transaction?.isIncome ?? true;
    _date = widget.transaction?.date ?? DateTime.now();
    _isRecurring = widget.transaction?.isRecurring ?? false;
    _recurrenceType = widget.transaction?.recurrenceType ??
        Transaction.getRecurrenceTypes(widget.language).first;
    _attachmentPath = widget.transaction?.attachmentPath;

    final incomeCategories = Transaction.getIncomeCategories(widget.language);
    final expenseCategories = Transaction.getExpenseCategories(widget.language);
    if (_category.isNotEmpty) {
      if (_isIncome && !incomeCategories.contains(_category)) {
        _category = incomeCategories.first;
      } else if (!_isIncome && !expenseCategories.contains(_category)) {
        _category = expenseCategories.first;
      }
    } else {
      _category = _isIncome ? incomeCategories.first : expenseCategories.first;
    }

    final recurrenceTypes = Transaction.getRecurrenceTypes(widget.language);
    if (!recurrenceTypes.contains(_recurrenceType)) {
      _recurrenceType = recurrenceTypes.first;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _attachmentPath = pickedFile.path;
      });
    }
  }

  void _removeAttachment() {
    setState(() {
      _attachmentPath = null;
    });
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final transaction = Transaction(
        category: _category,
        amount: _amount,
        date: _date,
        description: _description.isEmpty ? null : _description,
        isIncome: _isIncome,
        isRecurring: _isRecurring,
        recurrenceType: _isRecurring ? _recurrenceType : null,
        attachmentPath: _attachmentPath,
      );
      final box = Hive.box<Transaction>('transactions');
      widget.index != null
          ? box.putAt(widget.index!, transaction)
          : box.add(transaction);
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Colors.blueAccent.shade700),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _date) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final incomeCategories = Transaction.getIncomeCategories(widget.language);
    final expenseCategories = Transaction.getExpenseCategories(widget.language);
    final recurrenceTypes = Transaction.getRecurrenceTypes(widget.language);

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
          widget.index != null
              ? (widget.language == 'English'
                  ? 'Edit Transaction'
                  : 'Редактировать транзакцию')
              : (widget.language == 'English'
                  ? 'New Transaction'
                  : 'Новая транзакция'),
          style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent.shade700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: Text(
                        widget.language == 'English' ? 'Income' : 'Доход',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      selected: _isIncome,
                      onSelected: (selected) => setState(() {
                        _isIncome = true;
                        _category = incomeCategories.first;
                      }),
                      selectedColor: Colors.blueAccent.shade700,
                      backgroundColor: Colors.grey.shade200,
                      labelStyle: TextStyle(
                          color:
                              _isIncome ? Colors.white : Colors.grey.shade700),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: Text(
                        widget.language == 'English' ? 'Expense' : 'Расход',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      selected: !_isIncome,
                      onSelected: (selected) => setState(() {
                        _isIncome = false;
                        _category = expenseCategories.first;
                      }),
                      selectedColor: Colors.blueAccent.shade700,
                      backgroundColor: Colors.grey.shade200,
                      labelStyle: TextStyle(
                          color:
                              !_isIncome ? Colors.white : Colors.grey.shade700),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _category.isEmpty ? null : _category,
                  decoration: InputDecoration(
                    hintText:
                        widget.language == 'English' ? 'Category' : 'Категория',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 20),
                  ),
                  items: (_isIncome ? incomeCategories : expenseCategories)
                      .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category, style: GoogleFonts.poppins())))
                      .toList(),
                  onChanged: (value) => setState(() => _category = value ?? ''),
                  validator: (value) => value == null || value.isEmpty
                      ? (widget.language == 'English'
                          ? 'Select a category'
                          : 'Выберите категорию')
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _amount == 0.0 ? '' : _amount.toString(),
                  decoration: InputDecoration(
                    hintText: widget.language == 'English'
                        ? 'Amount (₽)'
                        : 'Сумма (₽)',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                    prefixIcon: Icon(Icons.currency_ruble_rounded,
                        color: Colors.blueAccent.shade700),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => value!.isEmpty ||
                          double.tryParse(value) == null ||
                          double.parse(value) <= 0
                      ? (widget.language == 'English'
                          ? 'Enter a valid amount'
                          : 'Введите корректную сумму')
                      : null,
                  onSaved: (value) => _amount = double.parse(value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _description,
                  decoration: InputDecoration(
                    hintText: widget.language == 'English'
                        ? 'Description (optional)'
                        : 'Описание (необязательно)',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 20),
                  ),
                  maxLines: 2,
                  onSaved: (value) => _description = value ?? '',
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.language == 'English' ? 'Date' : 'Дата'}: ${_date.toString().substring(0, 10)}',
                          style: GoogleFonts.poppins(
                              color: Colors.blueAccent.shade700),
                        ),
                        Icon(Icons.calendar_today_rounded,
                            color: Colors.blueAccent.shade700),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _isRecurring,
                            onChanged: (value) =>
                                setState(() => _isRecurring = value ?? false),
                            activeColor: Colors.blueAccent.shade700,
                          ),
                          Text(
                            widget.language == 'English'
                                ? 'Recurring Transaction'
                                : 'Повторяющаяся транзакция',
                            style: GoogleFonts.poppins(
                                color: Colors.blueAccent.shade700,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      if (_isRecurring)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: DropdownButtonFormField<String>(
                            value: _recurrenceType,
                            decoration: InputDecoration(
                              hintText: widget.language == 'English'
                                  ? 'Frequency'
                                  : 'Частота',
                              hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey.shade500),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 20),
                            ),
                            items: recurrenceTypes
                                .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type,
                                        style: GoogleFonts.poppins())))
                                .toList(),
                            onChanged: (value) => setState(() =>
                                _recurrenceType =
                                    value ?? recurrenceTypes.first),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.language == 'English'
                            ? 'Attach Photo (optional)'
                            : 'Прикрепить фото (необязательно)',
                        style: GoogleFonts.poppins(
                            color: Colors.blueAccent.shade700,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      if (_attachmentPath != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _attachmentPath!.split('/').last,
                                style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_rounded,
                                  color: Colors.redAccent),
                              onPressed: _removeAttachment,
                            ),
                          ],
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library_rounded),
                          label: Text(
                            widget.language == 'English'
                                ? 'Choose Photo'
                                : 'Выбрать фото',
                            style: GoogleFonts.poppins(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.language == 'English'
                        ? 'Save Transaction'
                        : 'Сохранить транзакцию',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
