import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShimmerImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double? width;
  final BoxFit fit;

  ShimmerImage({required this.imageUrl, required this.height, this.width, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) => _buildShimmer(isDark),
      errorWidget: (context, url, error) => Container(
        height: height, width: width,
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        child: Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    // Simple pulse animation using standard widgets
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 1000),
      builder: (context, double value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                ? [Colors.grey[850]!, Colors.grey[800]!, Colors.grey[850]!]
                : [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
              stops: [0.0, value, 1.0],
              begin: Alignment(-1.0, -0.3),
              end: Alignment(1.0, 0.3),
            ),
          ),
        );
      },
      onEnd: () {}, // Repeat logic would go here in a Stateful widget
    );
  }
}