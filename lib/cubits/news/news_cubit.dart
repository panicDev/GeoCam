import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/news_model.dart';
import 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  static const String _bookmarksKey = 'bookmarked_news';

  NewsCubit() : super(const NewsState()) {
    _loadBookmarkedNews();
  }

  Future<void> _loadBookmarkedNews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarkedJson = prefs.getStringList(_bookmarksKey) ?? [];
      
      final bookmarkedNews = bookmarkedJson
          .map((json) => NewsModel.fromJson(jsonDecode(json)))
          .toList();
      
      emit(state.copyWith(bookmarkedNews: bookmarkedNews));
    } catch (e) {
      emit(state.copyWith(error: 'Error loading bookmarked news: $e'));
    }
  }

  Future<void> fetchNews() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Using JSONPlaceholder for demo purposes
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final news = data.map((json) => NewsModel.fromJson(json)).toList();
        _updateBookmarkStatus(news);
        emit(state.copyWith(news: news, isLoading: false));
      } else {
        emit(state.copyWith(
          error: 'Failed to load news. Status code: ${response.statusCode}',
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: 'Error fetching news: $e',
        isLoading: false,
      ));
    }
  }

  NewsModel? getNewsById(int id) {
    try {
      return state.news.firstWhere((news) => news.id == id);
    } catch (e) {
      // If not found in regular news, check bookmarked news
      try {
        return state.bookmarkedNews.firstWhere((news) => news.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  bool isBookmarked(int newsId) {
    return state.bookmarkedNews.any((news) => news.id == newsId);
  }

  Future<void> toggleBookmark(NewsModel news) async {
    final isCurrentlyBookmarked = isBookmarked(news.id);
    List<NewsModel> updatedBookmarks = List.from(state.bookmarkedNews);
    
    if (isCurrentlyBookmarked) {
      updatedBookmarks.removeWhere((item) => item.id == news.id);
    } else {
      updatedBookmarks.add(news.copyWith(isBookmarked: true));
    }
    
    emit(state.copyWith(bookmarkedNews: updatedBookmarks));
    await _saveBookmarks();
    _updateBookmarkStatus(state.news);
  }

  void _updateBookmarkStatus(List<NewsModel> news) {
    if (news.isNotEmpty && state.bookmarkedNews.isNotEmpty) {
      for (var i = 0; i < news.length; i++) {
        final isBookmark = state.bookmarkedNews.any((bookmark) => bookmark.id == news[i].id);
        news[i] = news[i].copyWith(isBookmarked: isBookmark);
      }
    }
  }

  Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = state.bookmarkedNews
          .map((news) => jsonEncode(news.toJson()))
          .toList();
      
      await prefs.setStringList(_bookmarksKey, bookmarksJson);
    } catch (e) {
      emit(state.copyWith(error: 'Error saving bookmarks: $e'));
    }
  }
}