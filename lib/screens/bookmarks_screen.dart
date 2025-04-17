import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/news_provider.dart';
import '../screens/news_detail_screen.dart';
import '../utils/page_transitions.dart';
import '../widgets/network_image_with_fallback.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        final bookmarkedNews = newsProvider.bookmarkedNews;
        
        if (bookmarkedNews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ).animate().scale(duration: 300.ms),
                const SizedBox(height: 16),
                const Text(
                  'No bookmarked news yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 8),
                const Text(
                  'Bookmark news articles to read them later',
                  style: TextStyle(color: Colors.grey),
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: bookmarkedNews.length,
          itemBuilder: (context, index) {
            final news = bookmarkedNews[index];
            
            return Dismissible(
              key: Key('bookmark-${news.id}'),
              background: Container(
                alignment: Alignment.centerRight,
                color: Colors.red,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                newsProvider.toggleBookmark(news);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Removed from bookmarks'),
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () => newsProvider.toggleBookmark(news),
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Hero(
                    tag: 'bookmark-image-${news.id}',
                    child: NetworkImageWithFallback(
                      imageUrl: news.imageUrl,
                      width: 60,
                      height: 60,
                    ),
                  ),
                  title: Text(
                    news.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      news.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: const Icon(Icons.bookmark),
                  onTap: () {
                    Navigator.push(
                      context, 
                      CustomPageTransition(
                        page: NewsDetailScreen(newsId: news.id),
                        transitionType: TransitionType.slideLeft,
                      ),
                    );
                  },
                ),
              )
              .animate(delay: (50 * index).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),
            );
          },
        );
      },
    );
  }
}