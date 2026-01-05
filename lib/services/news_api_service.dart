import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/live_news_model.dart';

class NewsApiService {
  static const String _apiKey = '0d2c5f0952a74b8f891b4c0078c36471';
  static const String _baseUrl = 'https://newsapi.org/v2';

  static Future<List<LiveNewsModel>> fetchTopHeadlines({String? category}) async {
    try {
      String url = '$_baseUrl/top-headlines?country=us&apiKey=$_apiKey';
      if (category != null && category.isNotEmpty) {
        url += '&category=$category';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articles = data['articles'] ?? [];

        return articles
            .where((article) => article['title'] != '[Removed]') // Filter removed articles
            .map((json) => LiveNewsModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }

  static Future<List<LiveNewsModel>> fetchNewsByCategory(String category) async {
    return fetchTopHeadlines(category: category);
  }
  static Future<List<LiveNewsModel>> searchNews(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/everything?q=$query&sortBy=publishedAt&apiKey=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articles = data['articles'] ?? [];

        return articles
            .where((article) => article['title'] != '[Removed]')
            .map((json) => LiveNewsModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      throw Exception('Error searching news: $e');
    }
  }
}
