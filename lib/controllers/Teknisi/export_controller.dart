import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExportController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Format tanggal (DD/MM/YY)
  String _formatDate(DateTime date) {
    String yearStr = date.year.toString().substring(2);
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/$yearStr";
  }

  // Format jam (HH:MM)
  String _formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  Future<void> exportTransactions({
    required BuildContext context,
    required DateTime startDate,
    required DateTime endDate,
    required String format,
    String category = 'equipment',
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Set end date to the end of the day to include all transactions on that day
      DateTime endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      // Fetch transactions by date range only to avoid needing a composite index
      QuerySnapshot querySnapshot = await _firestore
          .collection('transactions')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      // Filter category manually in Dart
      List<QueryDocumentSnapshot> exportDocs = querySnapshot.docs.where((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['category'] == category;
      }).toList();

      if (exportDocs.isEmpty) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada riwayat peminjaman di rentang tanggal tersebut.')),
          );
        }
        return;
      }

      int rowIndex = 3;
      int displayNo = 1;
      List<List<dynamic>> allRows = [];

      for (var doc in exportDocs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Items string
        List<dynamic> itemsList = data['items'] ?? [];
        String itemsStr = itemsList.map((i) => i['name'] ?? '').join(', ');

        String borrowerId = data['borrowerId'] ?? '';
        String borrowerName = data['borrowerName'] ?? '';
        DateTime startDate = data['startDate'] != null ? (data['startDate'] as Timestamp).toDate() : DateTime.now();
        DateTime? actualReturnDate = data['actualReturnDate'] != null ? (data['actualReturnDate'] as Timestamp).toDate() : null;

        // Fetch User Data for NIM, Kelas, KTM
        String nim = '';
        String kelas = '';
        String ktmUrl = '';
        
        if (borrowerId.isNotEmpty) {
          try {
            DocumentSnapshot userDoc = await _firestore.collection('users').doc(borrowerId).get();
            if (userDoc.exists && userDoc.data() != null) {
              var userData = userDoc.data() as Map<String, dynamic>;
              nim = userData['identifier'] ?? '';
              kelas = userData['kelas'] ?? '';
              ktmUrl = userData['ktm'] ?? '';
            }
          } catch (e) {
            debugPrint("Error fetching user data: $e");
          }
        }

        // Fill row based on format logic
        List<dynamic> rowData = [
          displayNo.toString(),
          itemsStr,
          borrowerName,
          nim,
          kelas,
          _formatDate(startDate),
          _formatTime(startDate),
          ktmUrl,
          actualReturnDate != null ? borrowerName : '',
          actualReturnDate != null ? _formatDate(actualReturnDate) : '',
          actualReturnDate != null ? _formatTime(actualReturnDate) : '',
          '', // Petugas
        ];
        
        allRows.add(rowData);
        displayNo++;
        rowIndex++;
      }

      if (format == 'excel') {
        await _generateExcel(allRows, context);
      } else if (format == 'pdf') {
        await _generatePdf(allRows, context);
      } else if (format == 'doc') {
        await _generateDoc(allRows, context);
      }

    } catch (e) {
      debugPrint("Error export: $e");
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat file export: $e')),
        );
      }
    }
  }

  Future<void> _generateExcel(List<List<dynamic>> allRows, BuildContext context) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    excel.setDefaultSheet('Sheet1');

    CellStyle headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    // Row 1
    sheetObject.updateCell(CellIndex.indexByString("A1"), TextCellValue('No'), cellStyle: headerStyle);
    sheetObject.updateCell(CellIndex.indexByString("B1"), TextCellValue('Nama Barang'), cellStyle: headerStyle);
    sheetObject.merge(CellIndex.indexByString("C1"), CellIndex.indexByString("H1"), customValue: TextCellValue('Peminjaman'));
    sheetObject.updateCell(CellIndex.indexByString("C1"), TextCellValue('Peminjaman'), cellStyle: headerStyle);
    sheetObject.merge(CellIndex.indexByString("I1"), CellIndex.indexByString("L1"), customValue: TextCellValue('Pengembalian'));
    sheetObject.updateCell(CellIndex.indexByString("I1"), TextCellValue('Pengembalian'), cellStyle: headerStyle);

    // Row 2
    sheetObject.updateCell(CellIndex.indexByString("A2"), TextCellValue(''), cellStyle: headerStyle);
    sheetObject.updateCell(CellIndex.indexByString("B2"), TextCellValue(''), cellStyle: headerStyle);
    sheetObject.updateCell(CellIndex.indexByString("C2"), TextCellValue('Nama'), cellStyle: headerStyle);
    sheetObject.updateCell(CellIndex.indexByString("D2"), TextCellValue('NIM'), cellStyle: headerStyle);
    sheetObject.updateCell(CellIndex.indexByString("E2"), TextCellValue('Kelas'), cellStyle: headerStyle);
    sheetObject.updateCell(CellIndex.indexByString("F2"), TextCellValue('Tanggal'), cellStyle: headerStyle);
    sheetObject.updateCell(CellIndex.indexByString("G2"), TextCellValue('Waktu'), cellStyle: headerStyle);
    sheetObject.updateCell(CellIndex.indexByString("H2"), TextCellValue('Identitas'), cellStyle: headerStyle);
    sheetObject.updateCell(CellIndex.indexByString("I2"), TextCellValue('Nama'), cellStyle: headerStyle);
    sheetObject.updateCell(CellIndex.indexByString("J2"), TextCellValue('Tanggal'), cellStyle: headerStyle);
    sheetObject.updateCell(CellIndex.indexByString("K2"), TextCellValue('Waktu'), cellStyle: headerStyle);
    sheetObject.updateCell(CellIndex.indexByString("L2"), TextCellValue('Petugas'), cellStyle: headerStyle);

    // Set widths
    sheetObject.setColumnWidth(0, 5.0);
    sheetObject.setColumnWidth(1, 20.0);
    sheetObject.setColumnWidth(2, 20.0);
    sheetObject.setColumnWidth(3, 15.0);
    sheetObject.setColumnWidth(4, 10.0);
    sheetObject.setColumnWidth(5, 12.0);
    sheetObject.setColumnWidth(6, 10.0);
    sheetObject.setColumnWidth(7, 35.0);
    sheetObject.setColumnWidth(8, 20.0);
    sheetObject.setColumnWidth(9, 12.0);
    sheetObject.setColumnWidth(10, 10.0);
    sheetObject.setColumnWidth(11, 15.0);

    for (var row in allRows) {
      sheetObject.appendRow(row.map((e) => TextCellValue(e.toString())).toList());
    }

    var fileBytes = excel.save();
    await _saveAndShareFile(fileBytes!, "Riwayat_Peminjaman_Alat_${DateTime.now().millisecondsSinceEpoch}.xlsx", context);
  }

  Future<void> _generatePdf(List<List<dynamic>> allRows, BuildContext context) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    final headers = [
      'No', 'Nama Barang', 'Nama Peminjam', 'NIM', 'Kelas', 'Tgl Pinjam', 'Wkt Pinjam', 'Identitas', 'Nama Pengembali', 'Tgl Kembali', 'Wkt Kembali', 'Petugas'
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Laporan Riwayat Peminjaman Alat/Barang', style: pw.TextStyle(font: fontBold, fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: allRows,
              border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
              headerStyle: pw.TextStyle(font: fontBold, fontWeight: pw.FontWeight.bold, fontSize: 8),
              cellStyle: pw.TextStyle(font: font, fontSize: 8),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            ),
          ];
        },
      ),
    );

    var fileBytes = await pdf.save();
    await _saveAndShareFile(fileBytes, "Riwayat_Peminjaman_Alat_${DateTime.now().millisecondsSinceEpoch}.pdf", context);
  }

  Future<void> _generateDoc(List<List<dynamic>> allRows, BuildContext context) async {
    // Generate simple HTML Table representing the document
    StringBuffer html = StringBuffer();
    html.writeln('<html><head><meta charset="utf-8"></head><body>');
    html.writeln('<h2>Laporan Riwayat Peminjaman Alat/Barang</h2>');
    html.writeln('<table border="1" cellpadding="5" cellspacing="0">');
    
    // Headers
    html.writeln('<tr style="background-color: #f2f2f2;">');
    final headers = [
      'No', 'Nama Barang', 'Nama Peminjam', 'NIM', 'Kelas', 'Tgl Pinjam', 'Wkt Pinjam', 'Identitas', 'Nama Pengembali', 'Tgl Kembali', 'Wkt Kembali', 'Petugas'
    ];
    for (var h in headers) {
      html.writeln('<th>\$h</th>');
    }
    html.writeln('</tr>');

    // Data
    for (var row in allRows) {
      html.writeln('<tr>');
      for (var cell in row) {
        html.writeln('<td>${cell.toString()}</td>');
      }
      html.writeln('</tr>');
    }
    html.writeln('</table></body></html>');

    // String to bytes
    List<int> fileBytes = html.toString().codeUnits;
    await _saveAndShareFile(fileBytes, "Riwayat_Peminjaman_Alat_${DateTime.now().millisecondsSinceEpoch}.doc", context);
  }

  Future<void> _saveAndShareFile(List<int> bytes, String fileName, BuildContext context) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$fileName';
    
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes);

    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Laporan Peminjaman Alat/Barang',
      );
    }
  }
}
