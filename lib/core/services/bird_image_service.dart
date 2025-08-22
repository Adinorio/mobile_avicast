import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BirdImageService {
  static final BirdImageService _instance = BirdImageService._internal();
  static BirdImageService get instance => _instance;
  
  BirdImageService._internal();

  // Get bird image widget with fallback
  Widget getBirdImage({
    String? imagePath,
    String? imageUrl,
    double width = 64,
    double height = 64,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    // If we have a local image path, use it
    if (imagePath != null && imagePath.isNotEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder(width, height, borderRadius);
            },
          ),
        ),
      );
    }
    
    // If we have a network image URL, use it with caching
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: width,
            height: height,
            fit: fit,
            placeholder: (context, url) => _buildLoadingPlaceholder(width, height, borderRadius),
            errorWidget: (context, url, error) => _buildPlaceholder(width, height, borderRadius),
          ),
        ),
      );
    }
    
    // Fallback to placeholder
    return _buildPlaceholder(width, height, borderRadius);
  }

  // Build placeholder widget
  Widget _buildPlaceholder(double width, double height, BorderRadius? borderRadius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Icon(
        Icons.photo_camera,
        size: width * 0.4,
        color: Colors.grey[600],
      ),
    );
  }

  // Build loading placeholder
  Widget _buildLoadingPlaceholder(double width, double height, BorderRadius? borderRadius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Center(
        child: SizedBox(
          width: width * 0.3,
          height: width * 0.3,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
      ),
    );
  }

  // Get common bird image paths
  static Map<String, String> getCommonBirdImages() {
    return {
      'American Robin': 'assets/images/birds/american_robin.jpg',
      'Blue Jay': 'assets/images/birds/blue_jay.jpg',
      'Cardinal': 'assets/images/birds/cardinal.jpg',
      'Sparrow': 'assets/images/birds/sparrow.jpg',
      'Eagle': 'assets/images/birds/eagle.jpg',
      'Hawk': 'assets/images/birds/hawk.jpg',
      'Owl': 'assets/images/birds/owl.jpg',
      'Woodpecker': 'assets/images/birds/woodpecker.jpg',
      'Hummingbird': 'assets/images/birds/hummingbird.jpg',
      'Duck': 'assets/images/birds/duck.jpg',
    };
  }

  // Get bird image by name
  String? getBirdImagePath(String birdName) {
    final commonImages = getCommonBirdImages();
    return commonImages[birdName];
  }

  // Check if bird has a local image
  bool hasLocalImage(String birdName) {
    final commonImages = getCommonBirdImages();
    return commonImages.containsKey(birdName);
  }
} 