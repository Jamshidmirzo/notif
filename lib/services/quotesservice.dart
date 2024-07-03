import 'dart:convert';

import 'package:http/http.dart' as http;

class Quotesservice {
  final mainurl = 'https://type.fit/api/quotes';
  Future<List> getQuotes() async {
    final url = Uri.parse(mainurl);
    final data = await http.get(url);
    List decode = jsonDecode(data.body);
    return [...decode];
  }
}
