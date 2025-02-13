import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'كتب عربية',
      home: BooksScreen(),
    );
  }
}

class BooksScreen extends StatefulWidget {
  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<dynamic> books = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

fetchBooks() async {
    final url = Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?q=رواية&langRestrict=ar');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          books = data['items'];
          isLoading = false;
        });
      } else {
        throw Exception(
            'فشل في تحميل الكتب. رمز الحالة: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'حدث خطأ أثناء جلب البيانات: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'قائمة الكتب العربية',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0XFF7067c5),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child:
                      Text(errorMessage, style: TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index]['volumeInfo'];
                    return ListTile(
                      leading: book['imageLinks'] != null
                          ? Image.network(book['imageLinks']['thumbnail'],
                              width: 50)
                          : const Icon(Icons.book, size: 50),
                      title: Text(book['title'] ?? 'عنوان غير متوفر'),
                      subtitle: Text(book['authors'] != null
                          ? (book['authors'] as List<dynamic>).join(', ')
                          : 'مؤلف غير معروف'),
                    );
                  },
                ),
    );
  }
}
