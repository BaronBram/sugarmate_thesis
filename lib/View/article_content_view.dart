import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class ArticleViewPage extends StatefulWidget {
  final String title;
  final String author;
  final String imgUrl;
  final String content;

  const ArticleViewPage({
    required this.title,
    required this.author,
    required this.imgUrl,
    required this.content,
  });

  @override
  _ArticleViewPageState createState() => _ArticleViewPageState();
}

class _ArticleViewPageState extends State<ArticleViewPage> {
  bool _isDownloading = false;

  Future<void> _downloadPDF() async {
    setState(() {
      _isDownloading = true;
    });

    // Request storage permissions
    if (await Permission.storage.request().isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Storage permission is required!")),
      );
      setState(() {
        _isDownloading = false;
      });
      return;
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(widget.title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('By ${widget.author}', style: pw.TextStyle(fontSize: 16, color: PdfColors.grey)),
              pw.Divider(),
              pw.Text(widget.content, style: pw.TextStyle(fontSize: 14)),
            ],
          );
        },
      ),
    );

    try {
      // Get the default Downloads directory
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync(recursive: true);
      }

      final filePath = '${downloadsDir.path}/${widget.title.replaceAll(" ", "_")}.pdf';
      final file = File(filePath);

      await file.writeAsBytes(await pdf.save()); // Save the PDF

      setState(() {
        _isDownloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF saved in Downloads: $filePath")),
      );

      OpenFile.open(filePath); // Open the saved PDF
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save PDF: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.imgUrl.isNotEmpty
                ? Image.network(
              widget.imgUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 200),
            )
                : Icon(Icons.image, size: 200),
            SizedBox(height: 10),
            Text(widget.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('By ${widget.author}', style: TextStyle(fontSize: 16, color: Colors.grey)),
            Divider(thickness: 1, height: 20),
            Text(widget.content, textAlign: TextAlign.justify, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isDownloading ? null : _downloadPDF,
              icon: Icon(Icons.download),
              label: Text(_isDownloading ? 'Downloading...' : 'Download as PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
