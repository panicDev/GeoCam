import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_model.dart';

class NewsProvider extends ChangeNotifier {
  List<NewsModel> _news = [];
  List<NewsModel> _bookmarkedNews = [];
  bool _isLoading = false;
  String? _error;
  static const String _bookmarksKey = 'bookmarked_news';

  List<NewsModel> get news => _news;
  List<NewsModel> get bookmarkedNews => _bookmarkedNews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  NewsProvider() {
    _loadBookmarkedNews();
  }

  Future<void> _loadBookmarkedNews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarkedJson = prefs.getStringList(_bookmarksKey) ?? [];
      
      _bookmarkedNews = bookmarkedJson
          .map((json) => NewsModel.fromJson(jsonDecode(json)))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _error = 'Error loading bookmarked news: $e';
    }
  }

  Future<void> fetchNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Using JSONPlaceholder for demo purposes
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _news = data.map((json) => NewsModel.fromJson(json)).toList();
        _updateBookmarkStatus();
      } else {
        _error = 'Failed to load news. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching news: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  NewsModel? getNewsById(int id) {
    try {
      return _news.firstWhere((news) => news.id == id);
    } catch (e) {
      // If not found in regular news, check bookmarked news
      try {
        return _bookmarkedNews.firstWhere((news) => news.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  bool isBookmarked(int newsId) {
    return _bookmarkedNews.any((news) => news.id == newsId);
  }

  Future<void> toggleBookmark(NewsModel news) async {
    final isCurrentlyBookmarked = isBookmarked(news.id);
    
    if (isCurrentlyBookmarked) {
      _bookmarkedNews.removeWhere((item) => item.id == news.id);
    } else {
      _bookmarkedNews.add(news);
    }
    
    await _saveBookmarks();
    _updateBookmarkStatus();
    notifyListeners();
  }

  void _updateBookmarkStatus() {
    // Update the bookmark status of news in the regular list
    if (_news.isNotEmpty && _bookmarkedNews.isNotEmpty) {
      for (var news in _news) {
        final isBookmark = _bookmarkedNews.any((bookmark) => bookmark.id == news.id);
        news.isBookmarked = isBookmark;
      }
    }
  }

  Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = _bookmarkedNews
          .map((news) => jsonEncode(news.toJson()))
          .toList();
      
      await prefs.setStringList(_bookmarksKey, bookmarksJson);
    } catch (e) {
      _error = 'Error saving bookmarks: $e';
    }
  }
}