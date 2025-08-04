import "dart:io";
import "package:pdf/widgets.dart" as pw;
import "package:path_provider/path_provider.dart";
import "../models/models.dart";
import "../services/database_helper.dart";
import "package:intl/intl.dart";

Future<void> generateAndSavePdf(List<Map<String, dynamic>> sales) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Restaurant Invoice", style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Item', 'Qty', 'Price', 'Total'],
              data: sales.map((sale) {
                final total = sale['quantity'] * sale['price'];
                return [
                  sale['item'],
                  sale['quantity'].toString(),
                  sale['price'].toStringAsFixed(2),
                  total.toStringAsFixed(2),
                ];
              }).toList(),
            ),
          ],
        );
      },
    ),
  );

  // Save to local File

  final outputDir = await getApplicationDocumentsDirectory();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final file = File("${outputDir.path}/$timestamp-invoice.pdf");
  await file.writeAsBytes(await pdf.save());

  print("Invoice saved to: ${file.path}");
}

// Thermal Printer Bill Generator (80mm width)
Future<String> generateThermalBill(Sales sale) async {
  try {
    // Get restaurant info from database
    final dbHelper = DatabaseHelper();
    final restaurant = await dbHelper.getRestaurant();

    // Format date and time
    final dateFormat = DateFormat('dd/MM/yyyy hh:mm a');
    final currentDateTime = dateFormat.format(DateTime.now());

    // Calculate totals
    final subtotal = sale.subtotal;
    final discount = sale.discount;
    final taxAmount = sale.tax;
    final netTotal = sale.total;

    // Convert amount to words
    final amountInWords = convertNumberToWords(netTotal.toInt());

    // Build bill content for 80mm thermal printer (42 characters width)
    StringBuffer bill = StringBuffer();

    // Header - Restaurant Info (Centered)
    bill.writeln(''.padLeft(42, '='));
    if (restaurant != null) {
      bill.writeln(_centerText(restaurant.name, 42));
      bill.writeln(_centerText(restaurant.address, 42));
      bill.writeln(_centerText('PAN: ${restaurant.panNumber}', 42));
      bill.writeln(_centerText('Contact: ${restaurant.phone}', 42));
    } else {
      bill.writeln(_centerText('RESTAURANT NAME', 42));
      bill.writeln(_centerText('Restaurant Address', 42));
      bill.writeln(_centerText('PAN: 000000000', 42));
      bill.writeln(_centerText('Contact: +977-XXXXXXXXX', 42));
    }
    bill.writeln(''.padLeft(42, '='));
    bill.writeln();

    // Bill Details (Left aligned)
    bill.writeln('Bill No: ${sale.invoiceNo}');
    bill.writeln('Invoice Date: $currentDateTime');
    bill.writeln('Customer: Cash Customer');
    bill.writeln('Table: ${sale.table}');
    bill.writeln();

    // Items Header
    bill.writeln(''.padLeft(42, '-'));
    bill.writeln('# Items${' ' * 10}Qty  Rate  Amount');
    bill.writeln(''.padLeft(42, '-'));

    // Items List
    for (int i = 0; i < sale.items.length; i++) {
      final item = sale.items[i];
      final itemName = item.item['item_name'] as String;
      final qty = item.quantity;
      final rate = (item.item['rate'] as num).toDouble();
      final amount = item.totalPrice;

      // Format item line (keeping within 42 chars)
      final itemNo = '${i + 1}'.padRight(2);
      final truncatedName = itemName.length > 15
          ? '${itemName.substring(0, 12)}...'
          : itemName.padRight(15);
      final qtyStr = qty.toString().padLeft(3);
      final rateStr = rate.toStringAsFixed(0).padLeft(6);
      final amountStr = amount.toStringAsFixed(0).padLeft(8);

      bill.writeln('$itemNo $truncatedName $qtyStr $rateStr $amountStr');
    }

    bill.writeln(''.padLeft(42, '-'));

    // Totals (Right aligned)
    bill.writeln(
      '${'Sub Total:'.padLeft(30)} ${subtotal.toStringAsFixed(2).padLeft(10)}',
    );
    bill.writeln(
      '${'Discount:'.padLeft(30)} ${discount.toStringAsFixed(2).padLeft(10)}',
    );
    bill.writeln(
      '${'Tax Amt.:'.padLeft(30)} ${taxAmount.toStringAsFixed(2).padLeft(10)}',
    );
    bill.writeln(''.padLeft(42, '-'));
    bill.writeln(
      '${'Net Total:'.padLeft(30)} ${netTotal.toStringAsFixed(2).padLeft(10)}',
    );
    bill.writeln();

    // Amount in words
    bill.writeln('($amountInWords)');
    bill.writeln();

    // Footer
    bill.writeln(''.padLeft(42, '-'));
    bill.writeln(_centerText('Thank you for visiting us', 42));
    bill.writeln(_centerText('Please visit us again', 42));
    bill.writeln(_centerText('Good Bye', 42));
    bill.writeln(''.padLeft(42, '-'));

    // Save to local file
    final outputDir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File(
      "${outputDir.path}/bill_${sale.invoiceNo}_$timestamp.txt",
    );
    await file.writeAsString(bill.toString());

    print("Thermal bill saved to: ${file.path}");
    return file.path;
  } catch (e) {
    print("Error generating thermal bill: $e");
    rethrow;
  }
}

// Helper function to center text within given width
String _centerText(String text, int width) {
  if (text.length >= width) return text.substring(0, width);
  final padding = (width - text.length) ~/ 2;
  return '${' ' * padding}$text${' ' * (width - text.length - padding)}';
}

// Convert number to words (simple implementation for small amounts)
String convertNumberToWords(int number) {
  if (number == 0) return "Zero Rupees Only";

  final ones = [
    "",
    "One",
    "Two",
    "Three",
    "Four",
    "Five",
    "Six",
    "Seven",
    "Eight",
    "Nine",
    "Ten",
    "Eleven",
    "Twelve",
    "Thirteen",
    "Fourteen",
    "Fifteen",
    "Sixteen",
    "Seventeen",
    "Eighteen",
    "Nineteen",
  ];

  final tens = [
    "",
    "",
    "Twenty",
    "Thirty",
    "Forty",
    "Fifty",
    "Sixty",
    "Seventy",
    "Eighty",
    "Ninety",
  ];

  String result = "";

  if (number >= 1000) {
    final thousands = number ~/ 1000;
    result += "${ones[thousands]} Thousand ";
    number %= 1000;
  }

  if (number >= 100) {
    final hundreds = number ~/ 100;
    result += "${ones[hundreds]} Hundred ";
    number %= 100;
  }

  if (number >= 20) {
    final tensPart = number ~/ 10;
    final onesPart = number % 10;
    result += tens[tensPart];
    if (onesPart > 0) {
      result += " ${ones[onesPart]}";
    }
  } else if (number > 0) {
    result += ones[number];
  }

  return "${result.trim()} Rupees Only";
}

// Example usage function - call this after a sale is completed
Future<void> generateAndSaveThermalBill(Sales sale) async {
  try {
    final filePath = await generateThermalBill(sale);
    print("Thermal bill generated successfully at: $filePath");

    // You can also display a success message to the user
    // or open the file for preview if needed
  } catch (e) {
    print("Failed to generate thermal bill: $e");
    // Handle error appropriately in your app
  }
}
