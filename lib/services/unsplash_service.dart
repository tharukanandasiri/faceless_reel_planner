import 'dart:convert';
import 'package:http/http.dart' as http;

class UnsplashService {
  // Replace with your actual Unsplash Access Key
  static const String _accessKey =
      'HbpFu-gGbKQ02qCuPT0zptjYQvnQO8e40Xb3mplR2gs';
  static const String _baseUrl = 'https://api.unsplash.com/photos/random';

  Future<String?> fetchAestheticBackground() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl?query=aesthetic,dark,minimal&orientation=portrait',
        ),
        headers: {'Authorization': 'Client-ID $_accessKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['urls']['regular']; // Returns the image URL
      }
    } catch (e) {
      print('Error fetching image: $e');
    }
    return null;
  }
}
