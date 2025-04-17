import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/news_provider.dart';
import '../screens/news_detail_screen.dart';
import '../utils/page_transitions.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  late ScrollController _scrollController;
  bool _showTopShadow = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 0 && !_showTopShadow) {
      setState(() => _showTopShadow = true);
    } else if (_scrollController.offset <= 0 && _showTopShadow) {
      setState(() => _showTopShadow = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Consumer<NewsProvider>(
          builder: (context, newsProvider, child) {
            final bookmarkedNews = newsProvider.bookmarkedNews;

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Custom Header (sesuai dengan NewsListScreen)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      boxShadow: _showTopShadow
                          ? [BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.05),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      )]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.bookmark_rounded,
                            color: colorScheme.secondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'My Bookmarks',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        // Count
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${bookmarkedNews.length} saved',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Konten Utama
                if (bookmarkedNews.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyBookmarksState(colorScheme),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header text with divider
                          Row(
                            children: [
                              Text(
                                'Saved Articles',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Divider(
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                if (bookmarkedNews.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final news = bookmarkedNews[index];
                          return _buildBookmarkedNewsCard(news, index, colorScheme);
                        },
                        childCount: bookmarkedNews.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookmarkedNewsCard(news, int index, ColorScheme colorScheme) {
    return Dismissible(
      key: Key('bookmark-${news.id}'),
      background: Container(
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete,
          color: colorScheme.onErrorContainer,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        Provider.of<NewsProvider>(context, listen: false).toggleBookmark(news);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Removed from bookmarks'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => Provider.of<NewsProvider>(context, listen: false).toggleBookmark(news),
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              CustomPageTransition(
                page: NewsDetailScreen(newsId: news.id),
                transitionType: TransitionType.slideLeft,
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with stack for category chip
              Stack(
                children: [
                  // Image with safe null check
                  if (news.imageUrl != null && news.imageUrl.isNotEmpty)
                    Hero(
                      tag: 'bookmark-image-${news.id}',
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          news.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: colorScheme.surfaceVariant,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: colorScheme.surfaceVariant,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),

                  // Bookmark indicator badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark,
                        color: colorScheme.secondary,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title ?? 'No title',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (news.body != null)
                      Text(
                        news.body,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 16),
                    // Swipe hint
                    Row(
                      children: [
                        Icon(
                          Icons.swipe_left,
                          size: 16,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Swipe to remove',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (50 * index).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
  }

  Widget _buildEmptyBookmarksState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_outline,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.8),
            ),
          ).animate().scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 300.ms),
          const SizedBox(height: 24),
          Text(
            'No bookmarked articles yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Bookmark articles that you want to read later',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 32),
          FilledButton.tonalIcon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back to News'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(200, 48),
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}
