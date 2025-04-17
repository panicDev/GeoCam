import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/news_provider.dart';
import '../widgets/network_image_with_fallback.dart';

class NewsDetailScreen extends StatelessWidget {
  final int newsId;
  
  const NewsDetailScreen({
    super.key,
    required this.newsId,
  });

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final news = newsProvider.getNewsById(newsId);
    
    if (news == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('News Details')),
        body: const Center(child: Text('News not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('News Details'),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: IconButton(
              key: ValueKey(news.isBookmarked),
              icon: Icon(
                news.isBookmarked 
                    ? Icons.bookmark 
                    : Icons.bookmark_border,
                color: news.isBookmarked ? Colors.amber : null,
              ),
              onPressed: () {
                // Store the current state before toggling
                final wasBookmarked = news.isBookmarked;
                
                // Toggle bookmark
                newsProvider.toggleBookmark(news);
                
                // Show confirmation with correct message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      wasBookmarked
                          ? 'Removed from bookmarks'
                          : 'Added to bookmarks'
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              news.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: -0.2, end: 0),
            
            const SizedBox(height: 16),
            
            Hero(
              tag: 'news-image-${news.id}',
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: NetworkImageWithFallback(
                  imageUrl: news.imageUrl,
                  width: MediaQuery.of(context).size.width - 32, 
                  height: (MediaQuery.of(context).size.width - 32) * 9 / 16, 
                ),
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .scale(delay: 200.ms, duration: 600.ms),
            
            const SizedBox(height: 24),
            
            // Content card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  news.body,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
              ),
            )
            .animate(delay: 400.ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.3, end: 0, duration: 800.ms)
          ],
        ),
      ),
    );
  }
}