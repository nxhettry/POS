class InvoiceFormatter {
  static String formatInvoiceNumber(int salesId) {
    return 'INV ${salesId.toString().padLeft(3, '0')}';
  }

  static int extractSalesIdFromInvoice(String invoiceNumber) {
    final numericPart = invoiceNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numericPart) ?? 0;
  }

  static String formatSalesInvoiceNumber(dynamic sales) {
    if (sales != null &&
        sales.invoiceNo != null &&
        sales.invoiceNo.isNotEmpty) {
      if (sales.invoiceNo.contains('INV')) {
        return sales.invoiceNo;
      }

      final numericPart = sales.invoiceNo.replaceAll(RegExp(r'[^0-9]'), '');
      if (numericPart.isNotEmpty) {
        final number = int.tryParse(numericPart) ?? 0;
        return formatInvoiceNumber(number);
      }
    }

    if (sales != null && sales.id != null) {
      return formatInvoiceNumber(sales.id);
    }

    return 'INV 001';
  }

  static bool isValidInvoiceFormat(String invoiceNumber) {
    final pattern = RegExp(r'^INV \d{3}$');
    return pattern.hasMatch(invoiceNumber);
  }

  static String normalizeInvoiceNumber(String invoiceNumber) {
    if (isValidInvoiceFormat(invoiceNumber)) {
      return invoiceNumber;
    }

    final numericPart = invoiceNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericPart.isNotEmpty) {
      final number = int.tryParse(numericPart) ?? 1;
      return formatInvoiceNumber(number);
    }

    return 'INV 001';
  }
}
