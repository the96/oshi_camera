import 'dart:typed_data';

class OverlayImage {
  final Uint8List image;
  final int width, height;
  double x, y;
  double scale;
  double angle;

  OverlayImage({
    required this.image,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.angle,
    required this.scale,
  });

  OverlayImage.create({
    required this.image,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.angle,
  }) : scale = 200 / width;
}
