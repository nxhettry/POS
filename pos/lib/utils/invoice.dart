import "dart:io";
import "package:pdf/widgets.dart" as pw;
import "package:pdf/pdf.dart";
import "package:path_provider/path_provider.dart";
import "../models/models.dart";
import "../services/database_helper.dart";
import "package:intl/intl.dart";
import 'package:windows_printer/windows_printer.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import './invoice_formatter.dart';

Future<pw.Document> generateInvoicePdf(Sales sale) async {
  final pdf = pw.Document();
  final dbHelper = DatabaseHelper();
  final restaurant = await dbHelper.getRestaurant();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: pw.Column(
                children: [
                  pw.Text(
                    restaurant?.name ?? "RESTAURANT NAME",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(restaurant?.address ?? "Restaurant Address"),
                  pw.Text("PAN: ${restaurant?.panNumber ?? "000000000"}"),
                  pw.Text("Contact: ${restaurant?.phone ?? "+977-XXXXXXXXX"}"),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Invoice Details
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Invoice No: ${InvoiceFormatter.formatSalesInvoiceNumber(sale)}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text("Table: ${sale.table}"),
                    pw.Text("Order Type: ${sale.orderType}"),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      "Date: ${DateFormat('dd/MM/yyyy').format(sale.timestamp)}",
                    ),
                    pw.Text(
                      "Time: ${DateFormat('hh:mm a').format(sale.timestamp)}",
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // Items Table
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                // Header
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        "#",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        "Item",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        "Qty",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        "Rate",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        "Amount",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                // Items
                ...sale.items.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final item = entry.value;
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(index.toString()),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(item.item['item_name'] ?? ''),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(item.quantity.toString()),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          "₹${(item.item['rate'] as num).toStringAsFixed(2)}",
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          "₹${item.totalPrice.toStringAsFixed(2)}",
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),

            pw.SizedBox(height: 20),

            // Totals
            pw.Container(
              width: double.infinity,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text("Subtotal:"),
                            pw.Text("₹${sale.subtotal.toStringAsFixed(2)}"),
                          ],
                        ),
                        if (sale.discount > 0) ...[
                          pw.SizedBox(height: 5),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text("Discount:"),
                              pw.Text("-₹${sale.discount.toStringAsFixed(2)}"),
                            ],
                          ),
                        ],
                        pw.SizedBox(height: 5),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              "Tax (${(sale.taxRate * 100).toStringAsFixed(0)}%):",
                            ),
                            pw.Text("₹${sale.tax.toStringAsFixed(2)}"),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Container(height: 1, color: PdfColors.black),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              "Total:",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            pw.Text(
                              "₹${sale.total.toStringAsFixed(2)}",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // Amount in words
            pw.Text(
              "Amount in Words: ${convertNumberToWords(sale.total.toInt())}",
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
            ),

            pw.SizedBox(height: 30),

            // Footer
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    "Thank you for visiting us!",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text("Please visit us again"),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  return pdf;
}

Future<void> showPdfPrintDialog(BuildContext context, Sales sale) async {
  try {
    final pdf = await generateInvoicePdf(sale);

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Invoice_${InvoiceFormatter.formatSalesInvoiceNumber(sale).replaceAll(' ', '_')}',
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Enhanced reprint function with error handling
Future<void> reprintInvoice(BuildContext context, Sales sale) async {
  try {
    // First try thermal printing
    await generateAndSaveThermalBill(sale);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invoice ${InvoiceFormatter.formatSalesInvoiceNumber(sale)} sent to printer successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (printError) {
    print("Thermal printing failed: $printError");

    if (context.mounted) {
      // Show dialog asking user if they want to view PDF
      final result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Printing Failed'),
            content: const Text(
              'Unable to print to thermal printer. Would you like to view the invoice as PDF instead?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('View PDF'),
              ),
            ],
          );
        },
      );

      if (result == true) {
        // Show PDF print dialog
        await showPdfPrintDialog(context, sale);
      }
    }
  }
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
    bill.writeln('Bill No: ${InvoiceFormatter.formatSalesInvoiceNumber(sale)}');
    bill.writeln('Invoice Date: $currentDateTime');
    bill.writeln('Customer: Cash Customer');
    bill.writeln('Table: ${sale.table}');
    bill.writeln();

    // Items Header
    bill.writeln(''.padLeft(42, '-'));
    bill.writeln('# Items${' ' * 10}Qty     Rate     Amount');
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
      "${outputDir.path}/bill_${InvoiceFormatter.formatSalesInvoiceNumber(sale).replaceAll(' ', '_')}_$timestamp.txt",
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

    // Get available printers
    List<String> printers = await WindowsPrinter.getAvailablePrinters();

    // Print the printers list
    print("Available Printers: $printers");

    // Print to default printer
    if (printers.isNotEmpty) {
      // Print the bill to the first available printer
      await WindowsPrinter.printRawData(
        data: File(filePath).readAsBytesSync(),
        printerName: printers.first,
      );
      print("Bill sent to printer: ${printers.first}");
    } else {
      throw Exception("No printers available to print the bill.");
    }
  } catch (e) {
    print("Failed to generate thermal bill: $e");
    // Re-throw the error so calling functions can handle it
    rethrow;
  }
}
