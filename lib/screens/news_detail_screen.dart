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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    if (news == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('News Details', style: TextStyle(color: colorScheme.onSurface)),
          centerTitle: true,
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('News not found', style: textTheme.titleLarge),
            ],
          ),
        ),
      );
    }

    // Simple date display
    final formattedDate = 'Today';

    return Scaffold(
      appBar: AppBar(
        title: const Text('News Details'),
        centerTitle: true,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: colorScheme.surfaceTint,
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
                color: news.isBookmarked ? colorScheme.primary : null,
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
                          : 'Added to bookmarks',
                      style: TextStyle(color: colorScheme.onInverseSurface),
                    ),
                    backgroundColor: colorScheme.inverseSurface,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image at the top
            Hero(
              tag: 'news-image-${news.id}',
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.width * 9 / 16,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NetworkImageWithFallback(
                      imageUrl: news.imageUrl,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width * 9 / 16,
                    ),
                    // Gradient overlay for better text visibility
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(179),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .scale(delay: 200.ms, duration: 600.ms),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  
                  // Title with animation
                  Text(
                    news.title,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.2, end: 0),
                  
                  const SizedBox(height: 12),
                  
                  // Metadata row (date, category, etc.)
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: colorScheme.secondary),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Source info
                      Icon(Icons.source_outlined, size: 16, color: colorScheme.secondary),
                      const SizedBox(width: 6),
                      Text(
                        'GeoCam News',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Content card with shadow and rounded corners
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: colorScheme.surfaceContainerLow,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        news.body,
                        style: textTheme.bodyLarge?.copyWith(
                          height: 1.7,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0, duration: 800.ms),
                  
                  const SizedBox(height: 32),
                  
                  // Share and related information section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        context: context, 
                        icon: Icons.share, 
                        label: 'Share', 
                        color: colorScheme.primary,
                        onTap: () {},
                      ),
                      _buildActionButton(
                        context: context, 
                        icon: Icons.comment_outlined, 
                        label: 'Comment', 
                        color: colorScheme.secondary,
                        onTap: () {},
                      ),
                      _buildActionButton(
                        context: context, 
                        icon: Icons.thumb_up_outlined, 
                        label: 'Like', 
                        color: colorScheme.tertiary,
                        onTap: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}