import 'dart:io';
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
    final logoPath = settingsProvider.settings.businessLogo;
    Uint8List imageBytes;

    if (logoPath != null &&
        logoPath.isNotEmpty &&
        File(logoPath).existsSync()) {
      imageBytes = await File(logoPath).readAsBytes();
    } else {
      final logoImage = await rootBundle.load('assets/images/Logo-3.png');
      imageBytes = logoImage.buffer.asUint8List();
    }

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
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (imageBytes.isNotEmpty)
                        pw.Container(
                          height: 80,
                          width: 80,
                          child: pw.Image(
                            pw.MemoryImage(imageBytes),
                            fit: pw.BoxFit.contain,
                          ),
                        ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        businessName,
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey800,
                        ),
                      ),
                      if (address != null && address.isNotEmpty)
                        pw.Text(
                          address,
                          style: pw.TextStyle(font: font, fontSize: 10),
                        ),
                      if (phone != null && phone.isNotEmpty)
                        pw.Text(
                          "Tel: $phone",
                          style: pw.TextStyle(font: font, fontSize: 10),
                        ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "INVOICE",
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey800,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        "No: #${orderId.substring(0, 8).toUpperCase()}",
                        style: pw.TextStyle(font: fontBold, fontSize: 12),
                      ),
                      pw.Text(
                        "Date: ${dateFormat.format(DateTime.now())}",
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Customer Info
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Bill To:",
                            style: pw.TextStyle(font: fontBold, fontSize: 12),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            customerName ?? "Guest Customer",
                            style: pw.TextStyle(font: font, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Served By:",
                            style: pw.TextStyle(font: fontBold, fontSize: 12),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            user ?? "N/A",
                            style: pw.TextStyle(font: font, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Items Table
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.blueGrey50,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          "Item Description",
                          style: pw.TextStyle(font: fontBold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          "Qty",
                          style: pw.TextStyle(font: fontBold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          "Price",
                          style: pw.TextStyle(font: fontBold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          "Total",
                          style: pw.TextStyle(font: fontBold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  // Table Rows
                  ...items.map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            item.productName,
                            style: pw.TextStyle(font: font),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            item.quantity.toString(),
                            style: pw.TextStyle(font: font),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            "${(item.total / item.quantity).toStringAsFixed(0)} $currency",
                            style: pw.TextStyle(font: font),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            "${item.total.toStringAsFixed(0)} $currency",
                            style: pw.TextStyle(font: font),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 20),

              // Totals & Payment Info
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Payment Method:",
                          style: pw.TextStyle(font: fontBold),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          paymentDisplay,
                          style: pw.TextStyle(font: font),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              "Subtotal:",
                              style: pw.TextStyle(font: font),
                            ),
                            pw.Text(
                              "${total.toStringAsFixed(0)} $currency",
                              style: pw.TextStyle(font: font),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Divider(),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              "TOTAL",
                              style: pw.TextStyle(font: fontBold, fontSize: 16),
                            ),
                            pw.Text(
                              "${total.toStringAsFixed(0)} $currency",
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 16,
                                color: PdfColors.blueGrey800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  "Thank you for your business!",
                  style: pw.TextStyle(
                    font: font,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  "Generated by Kioske",
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 8,
                    color: PdfColors.grey500,
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
