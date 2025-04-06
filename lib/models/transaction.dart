import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  String category;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String? description;

  @HiveField(4)
  bool isIncome;

  @HiveField(5)
  bool isRecurring;

  @HiveField(6)
  String? recurrenceType;

  @HiveField(7)
  String? attachmentPath;

  Transaction({
    required this.category,
    required this.amount,
    required this.date,
    this.description,
    required this.isIncome,
    this.isRecurring = false,
    this.recurrenceType,
    this.attachmentPath,
  });

  static List<String> getIncomeCategories(String language) {
    if (language == 'English') {
      return [
        'Salary',
        'Gift',
        'Investments',
        'Side Job',
        'Debt Repayment',
        'Other',
      ];
    } else {
      return [
        'Зарплата',
        'Подарок',
        'Инвестиции',
        'Подработка',
        'Возврат долга',
        'Другое',
      ];
    }
  }

  static List<String> getExpenseCategories(String language) {
    if (language == 'English') {
      return [
        'Food',
        'Transport',
        'Housing',
        'Entertainment',
        'Health',
        'Clothing',
        'Education',
        'Travel',
        'Gifts',
        'Other',
      ];
    } else {
      return [
        'Еда',
        'Транспорт',
        'Жильё',
        'Развлечения',
        'Здоровье',
        'Одежда',
        'Образование',
        'Путешествия',
        'Подарки',
        'Другое',
      ];
    }
  }

  static List<String> getRecurrenceTypes(String language) {
    if (language == 'English') {
      return [
        'Monthly',
        'Weekly',
        'Yearly',
      ];
    } else {
      return [
        'Ежемесячно',
        'Еженедельно',
        'Ежегодно',
      ];
    }
  }
}
