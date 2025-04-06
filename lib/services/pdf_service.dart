import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class PdfService {
  Future<Uint8List> generatePdf(List<Map<String, dynamic>> transactions) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text("Финансовый отчет",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ["Дата", "Категория", "Сумма", "Повторяющийся"],
                data: transactions
                    .map((txn) => [
                          txn["date"] ?? "-",
                          txn["category"] ?? "-",
                          txn["amount"].toString(),
                          txn["isRecurring"] == true ? "Да" : "Нет"
                        ])
                    .toList(),
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.centerLeft,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> savePdfToFile(Uint8List pdfBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/transactions.pdf");
    await file.writeAsBytes(pdfBytes);
    print("PDF сохранен: ${file.path}");
  }

  Future<void> printPdf(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
}
