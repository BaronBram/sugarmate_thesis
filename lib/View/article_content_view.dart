import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title, style: GoogleFonts.poppins(color: Colors.black,))),
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
            Text(widget.title, style: GoogleFonts.poppins(color: Colors.black,fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('By ${widget.author}', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
            Divider(thickness: 1, height: 20),
            Text(widget.content, textAlign: TextAlign.justify, style: GoogleFonts.poppins(color: Colors.black, fontSize: 16)),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
