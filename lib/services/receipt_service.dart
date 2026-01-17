import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:kioske/models/order.dart';
import 'package:kioske/providers/settings_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptService {
  /// Generate and print a receipt
  static Future<void> printReceipt({
    required List<OrderItem> items,
    required double total,
    required String orderId,
    required SettingsProvider settingsProvider,
    String? user,
    String? customerName,
    String paymentMethod = 'Cash',
  }) async {
    final pdf = await _generatePdfDocument(
      items: items,
      total: total,
      orderId: orderId,
      settingsProvider: settingsProvider,
      user: user,
      customerName: customerName,
      paymentMethod: paymentMethod,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt_${orderId.substring(0, 8)}',
    );
  }

  /// Generate receipt data for preview
  static Future<Uint8List> generateReceiptData({
    required List<OrderItem> items,
    required double total,
    required String orderId,
    required SettingsProvider settingsProvider,
    String? user,
    String? customerName,
    String paymentMethod = 'Cash',
  }) async {
    final pdf = await _generatePdfDocument(
      items: items,
      total: total,
      orderId: orderId,
      settingsProvider: settingsProvider,
      user: user,
      customerName: customerName,
      paymentMethod: paymentMethod,
    );
    return pdf.save();
  }

  /// Internal method to build the PDF document
  static Future<pw.Document> _generatePdfDocument({
    required List<OrderItem> items,
    required double total,
    required String orderId,
    required SettingsProvider settingsProvider,
    String? user,
    String? customerName,
    required String paymentMethod,
  }) async {
    final pdf = pw.Document();

    // Load font
    final font = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsBold();

    // Load Logo
    // Try to load custom logo later, for now use asset
    final logoImage = await rootBundle.load('assets/images/Logo-3.png');
    final imageBytes = logoImage.buffer.asUint8List();

    final businessName = settingsProvider.settings.businessName;
    final address = settingsProvider.settings.businessAddress;
    final phone = settingsProvider.settings.businessPhone;
    final currency = settingsProvider.settings.currencySymbol;

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Expand payment method name for display
    String paymentDisplay = paymentMethod;
    if (paymentMethod == 'om') paymentDisplay = 'Orange Money';
    if (paymentMethod == 'momo') paymentDisplay = 'MTN Momo';
    if (paymentMethod == 'cash') paymentDisplay = 'Cash';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(10), // Small margin for thermal printer
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Image(pw.MemoryImage(imageBytes), width: 60, height: 60),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      businessName,
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (address != null && address.isNotEmpty)
                      pw.Text(
                        address,
                        style: pw.TextStyle(font: font, fontSize: 10),
                        textAlign: pw.TextAlign.center,
                      ),
                    if (phone != null && phone.isNotEmpty)
                      pw.Text(
                        "Tel: $phone",
                        style: pw.TextStyle(font: font, fontSize: 10),
                      ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // Divider
              pw.Divider(thickness: 0.5),

              // Order Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Order:",
                    style: pw.TextStyle(font: font, fontSize: 10),
                  ),
                  pw.Text(
                    "#${orderId.substring(0, 8).toUpperCase()}",
                    style: pw.TextStyle(font: fontBold, fontSize: 10),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Date:",
                    style: pw.TextStyle(font: font, fontSize: 10),
                  ),
                  pw.Text(
                    dateFormat.format(DateTime.now()),
                    style: pw.TextStyle(font: font, fontSize: 10),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Client:",
                    style: pw.TextStyle(font: font, fontSize: 10),
                  ),
                  pw.Text(
                    customerName ?? "N/A",
                    style: pw.TextStyle(font: font, fontSize: 10),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Payment:",
                    style: pw.TextStyle(font: font, fontSize: 10),
                  ),
                  pw.Text(
                    paymentDisplay,
                    style: pw.TextStyle(font: fontBold, fontSize: 10),
                  ),
                ],
              ),
              if (user != null)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Cashier:",
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                    pw.Text(
                      user,
                      style: pw.TextStyle(font: font, fontSize: 10),
                    ),
                  ],
                ),

              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 5),

              // Items Header
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      "Item",
                      style: pw.TextStyle(font: fontBold, fontSize: 10),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      "Qty",
                      style: pw.TextStyle(font: fontBold, fontSize: 10),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      "Price",
                      style: pw.TextStyle(font: fontBold, fontSize: 10),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),

              // Items List
              ...items.map((item) {
                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(
                          item.productName,
                          style: pw.TextStyle(font: font, fontSize: 10),
                          maxLines: 2,
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          item.quantity.toString(),
                          style: pw.TextStyle(font: font, fontSize: 10),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          "${(item.total).toStringAsFixed(0)}",
                          style: pw.TextStyle(font: font, fontSize: 10),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              pw.SizedBox(height: 5),
              pw.Divider(thickness: 0.5),

              // Totals
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "TOTAL",
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    "${total.toStringAsFixed(0)} $currency",
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  "Thank you for your visit!",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  "Powered by Kioske",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 8,
                    color: PdfColors.grey,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf;
  }
}
