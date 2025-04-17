import 'package:flutter/material.dart';
import 'dart:math';

/// A utility class for handling images in the application
class ImageHelper {
  // Random categories for unsplash images
  static const List<String> _categories = [
    'news',
    'technology',
    'business',
    'politics',
    'science',
    'health',
    'education',
    'environment',
    'sports',
    'travel'
  ];

  // Random image sizes
  static const List<String> _sizes = [
    '400x300',
    '500x300',
    '600x400',
    '800x600'
  ];

  /// Get a properly sized image URL for a news item
  /// If a URL is provided, it will be validated
  /// If no URL is provided or the URL is invalid, a random image will be generated
  static String getNewsImageUrl(String? url) {
    // Check if we have a valid URL
    if (url != null && 
        url.isNotEmpty && 
        url.startsWith('http') && 
        !url.contains('placeholder.com')) {
      return url;
    }

    // Get random category and size for more relevant and varied images
    final category = _categories[Random().nextInt(_categories.length)];
    final size = _sizes[Random().nextInt(_sizes.length)];
    
    // Use source.unsplash.com for random relevant images with ID to maintain consistency
    return 'https://source.unsplash.com/$size?$category&sig=${Random().nextInt(1000)}';
  }

  /// Build an optimized network image with proper error handling and placeholder
  static Widget buildNetworkImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return Container(
            width: width,
            height: height,
            color: Colors.grey.withAlpha(70),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // On error, show a gradient placeholder with an icon
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade100,
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey,
                size: 30,
              ),
            ),
          );
        },
      ),
    );
  }
}