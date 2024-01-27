import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart' as material;
import 'package:image/image.dart';

// 切り抜き設定済みの画像
class OverlayImage {
  final Image image;
  Point clopStart = Point(0, 0);
  Point clopEnd = Point(double.infinity, double.infinity);
  material.Color backgroundColor = material.Colors.black;
  // 透過する背景色の拡張率, 0.0 ~ 1.0
  double colorExpandRate = 0.0;

  bool cached = false;
  late Image processedImage;

  OverlayImage({
    required this.image,
  });

  void setCrop({required Point start, required Point end}) {
    clopStart = start;
    clopEnd = end;
    cached = false;
  }

  void setBackgroundColor({
    required material.Color color,
    double expandRate = 0.0,
  }) {
    backgroundColor = color;
    colorExpandRate = expandRate;
    cached = false;
  }

  bool isInRange(num target, int base, double rate) {
    final min = base - (base * rate).toInt();
    final max = base + (base * rate).toInt();
    return min <= target && target <= max;
  }

  bool isBack(num r, num g, num b) {
    int bg_r = backgroundColor.red;
    int bg_g = backgroundColor.green;
    int bg_b = backgroundColor.blue;

    return isInRange(r, bg_r, colorExpandRate) &&
        isInRange(g, bg_g, colorExpandRate) &&
        isInRange(b, bg_b, colorExpandRate);
  }

  // TODO: Future化したほうがいいかも
  Image process() {
    final endX = math.min(clopEnd.x, image.width - 1);
    final endY = math.min(clopEnd.y, image.height - 1);
    final cloppedWidth = (endX - clopStart.x).abs().toInt();
    final cloppedHeight = (endY - clopStart.y).abs().toInt();

    processedImage = Image(
      width: cloppedWidth,
      height: cloppedHeight,
      numChannels: 4,
    );

    for (int x = clopStart.x.toInt(); x < endX.toInt(); x++) {
      for (int y = clopStart.y.toInt(); y < endY.toInt(); y++) {
        final pixel = image.getPixel(x, y);

        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        final a = isBack(r, g, b) ? 0 : 255;
        processedImage.setPixelRgba(x, y, r, g, b, a);
      }
    }

    cached = true;
    return processedImage;
  }

  Uint8List get bytes {
    if (!cached) {
      print('please cache processing result with editing operation');
      process();
    }
    return encodePng(processedImage);
  }
}
