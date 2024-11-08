import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String url = "https://jsonplaceholder.typicode.com/posts";

  Future<List<dynamic>> fetchPosts() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load posts");
    }
  }
}
