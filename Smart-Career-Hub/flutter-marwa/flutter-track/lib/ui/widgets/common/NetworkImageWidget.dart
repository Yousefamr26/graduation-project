// lib/widgets/common/network_image_widget.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/Constants/apiConstants.dart';


/// Reusable widget for displaying images from network or local storage
class NetworkImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const NetworkImageWidget({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Handle null or empty image URL
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _buildDefaultPlaceholder();
    }

    final fullImageUrl = ApiConstants.getImageUrl(imageUrl);

    // Network image
    if (fullImageUrl.startsWith('http://') || fullImageUrl.startsWith('https://')) {
      return _buildNetworkImage(fullImageUrl);
    }

    // Local file image
    return _buildFileImage(fullImageUrl);
  }

  Widget _buildNetworkImage(String url) {
    Widget imageWidget = CachedNetworkImage(
      imageUrl: url,
      httpHeaders: ApiConstants.imageHeaders,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildLoadingPlaceholder(),
      errorWidget: (context, url, error) {
        debugPrint("❌ Error loading image: $error");
        debugPrint("❌ URL: $url");
        return errorWidget ?? _buildErrorPlaceholder(url);
      },
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildFileImage(String path) {
    Widget imageWidget = Image.file(
      File(path),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint("❌ Error loading file image: $error");
        return errorWidget ?? _buildFileErrorPlaceholder();
      },
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[100]!, Colors.blue[300]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 50, color: Colors.blue[700]),
            const SizedBox(height: 8),
            Text(
              "No Image",
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 150,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xff1893ff),
              strokeWidth: 3,
            ),
            const SizedBox(height: 12),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(String url) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[100]!, Colors.red[300]!],
        ),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 50, color: Colors.red[700]),
            const SizedBox(height: 8),
            Text(
              "Failed to load",
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (url.length <= 40) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  url,
                  style: TextStyle(
                    color: Colors.red[600],
                    fontSize: 9,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileErrorPlaceholder() {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[100]!, Colors.orange[300]!],
        ),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 50, color: Colors.orange[700]),
            const SizedBox(height: 8),
            Text(
              "File not found",
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small variant for thumbnails
class NetworkImageThumbnail extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const NetworkImageThumbnail({
    Key? key,
    required this.imageUrl,
    this.size = 70,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NetworkImageWidget(
      imageUrl: imageUrl,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(8),
    );
  }
}