import 'package:equatable/equatable.dart';
import '../../models/news_model.dart';

class NewsState extends Equatable {
  final List<NewsModel> news;
  final List<NewsModel> bookmarkedNews;
  final bool isLoading;
  final String? error;

  const NewsState({
    this.news = const [],
    this.bookmarkedNews = const [],
    this.isLoading = false,
    this.error,
  });

  NewsState copyWith({
    List<NewsModel>? news,
    List<NewsModel>? bookmarkedNews,
    bool? isLoading,
    String? error,
  }) {
    return NewsState(
      news: news ?? this.news,
      bookmarkedNews: bookmarkedNews ?? this.bookmarkedNews,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  NewsState clearError() {
    return copyWith(error: null);
  }

  @override
  List<Object?> get props => [news, bookmarkedNews, isLoading, error];
}