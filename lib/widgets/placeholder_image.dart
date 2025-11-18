import 'package:flutter/material.dart';

class PlaceholderImage extends StatelessWidget {
  final double? width;
  final double? height;
  final double iconSize;
  final BorderRadius? borderRadius;

  const PlaceholderImage({
    super.key,
    this.width,
    this.height,
    this.iconSize = 80,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          colors: [Colors.grey[200]!, Colors.grey[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: iconSize,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}

// Widget สำหรับแสดงรูปภาพที่มี fallback
class ArtworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double placeholderIconSize;

  const ArtworkImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    // ถ้าไม่มี URL หรือต้องการใช้ placeholder เสมอ
    if (imageUrl == null || imageUrl!.isEmpty) {
      return PlaceholderImage(
        width: width,
        height: height,
        iconSize: placeholderIconSize,
        borderRadius: borderRadius,
      );
    }

    // ถ้าเป็น avatar style (เหมือนรูปโปรไฟล์)
    if (imageUrl!.startsWith('avatar://')) {
      final letter = imageUrl!.replaceFirst('avatar://', '');
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            colors: [Colors.blue[300]!, Colors.blue[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: placeholderIconSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // ถ้าเป็น placeholder style
    if (imageUrl!.startsWith('placeholder://')) {
      return PlaceholderImage(
        width: width,
        height: height,
        iconSize: placeholderIconSize,
        borderRadius: borderRadius,
      );
    }

    // ตรวจสอบว่าเป็น SVG หรือไม่ (ซึ่งไม่รองรับโดย Image.network)
    final lowerUrl = imageUrl!.toLowerCase();
    if (lowerUrl.endsWith('.svg') || lowerUrl.contains('.svg?')) {
      // แสดง placeholder แทน SVG เนื่องจาก Image.network ไม่รองรับ SVG
      return PlaceholderImage(
        width: width,
        height: height,
        iconSize: placeholderIconSize,
        borderRadius: borderRadius,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return PlaceholderImage(
            width: width,
            height: height,
            iconSize: placeholderIconSize,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return PlaceholderImage(
            width: width,
            height: height,
            iconSize: placeholderIconSize,
          );
        },
      ),
    );
  }
}
