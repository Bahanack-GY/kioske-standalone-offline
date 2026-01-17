import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class KioskeImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const KioskeImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return errorWidget ?? _buildDefaultError();
    }

    // Handle base64 / data URI
    if (imageUrl!.startsWith('data:image')) {
      try {
        final base64String = imageUrl!.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) =>
              errorWidget ?? _buildDefaultError(),
        );
      } catch (e) {
        return errorWidget ?? _buildDefaultError();
      }
    }

    // Handle network URL
    if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
      return Image.network(
        imageUrl!,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ??
              const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildDefaultError(),
      );
    }

    // Handle local file path
    final file = File(imageUrl!);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildDefaultError(),
      );
    }

    return errorWidget ?? _buildDefaultError();
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: (width != null && width! < 50) ? 20 : 48,
            color: Colors.grey.shade400,
          ),
          if (width == null || width! >= 50) ...[
            const SizedBox(height: 8),
            Text(
              'INVALID IMAGE',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
