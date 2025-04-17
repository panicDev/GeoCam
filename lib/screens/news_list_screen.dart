import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/news_provider.dart';
import '../screens/news_detail_screen.dart';
import '../utils/page_transitions.dart';
import '../widgets/network_image_with_fallback.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch news when the screen is first loaded
    Future.microtask(() => 
      Provider.of<NewsProvider>(context, listen: false).fetchNews()
    );
  }

  Future<void> _refreshNews() async {
    await Provider.of<NewsProvider>(context, listen: false).fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        if (newsProvider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(delay: 200.ms),
                const SizedBox(height: 16),
                const Text('Loading news...')
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: 0.5, end: 0)
              ],
            ),
          );
        }

        if (newsProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ).animate().shake(delay: 200.ms),
                const SizedBox(height: 16),
                Text(
                  'Error: ${newsProvider.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ).animate().fadeIn(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshNews,
                  child: const Text('Try Again'),
                ).animate().scale(delay: 400.ms),
              ],
            ),
          );
        }

        if (newsProvider.news.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No news available')
                    .animate()
                    .fadeIn(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshNews,
                  child: const Text('Refresh'),
                ).animate().fadeIn(delay: 200.ms),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshNews,
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: newsProvider.news.length,
            itemBuilder: (context, index) {
              final news = newsProvider.news[index];
              
              // Stagger animation based on index
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Hero(
                    tag: 'news-image-${news.id}',
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
                  trailing: IconButton(
                    icon: Icon(
                      news.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      color: news.isBookmarked ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () {
                      // Store current state before toggling
                      final wasBookmarked = news.isBookmarked;
                      
                      // Toggle bookmark
                      newsProvider.toggleBookmark(news);
                      
                      // Show feedback with correct message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            wasBookmarked
                                ? 'Removed from bookmarks'
                                : 'Saved to bookmarks'
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
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
              ).animate(delay: (50 * index).ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
            },
          ),
        );
      },
    );
  }
}