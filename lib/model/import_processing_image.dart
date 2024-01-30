import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:image/image.dart';

// 切り抜き設定済みの画像
class ImportProcessingImage {
  final Image image;
  Point cropStart = Point(0, 0);
  Point cropEnd = Point(double.infinity, double.infinity);
  material.Color backgroundColor = material.Colors.black;
  // 透過する背景色の拡張率, 0.0 ~ 1.0
  double colorExpandRate = 0.0;

  bool cached = false;
  Future<Image>? processImage;
  Image? processedImage;

  ImportProcessingImage({
    required this.image,
  });

  void setCrop({required Point start, required Point end}) {
    cropStart = start;
    cropEnd = end;
    cached = false;
  }

  void setBackgroundColor({
    required material.Color color,
  }) {
    backgroundColor = color;
    cached = false;
  }

  void setColorExpandRate({
    required double rate,
  }) {
    colorExpandRate = rate;
    cached = false;
  }

  bool isInRange(num target, int base, double rate) {
    final min = base - (255 * rate).toInt();
    final max = base + (255 * rate).toInt();
    return min <= target && target <= max;
  }

  bool isBack(num r, num g, num b) {
    int bgR = backgroundColor.red;
    int bgG = backgroundColor.green;
    int bgB = backgroundColor.blue;

    return isInRange(r - g, bgR - bgG, colorExpandRate) &&
        isInRange(r - b, bgR - bgB, colorExpandRate) &&
        isInRange(g - b, bgG - bgB, colorExpandRate);
  }

  Uint8List setAlpha(Uint8List splitedBytes) {
    for (int i = 0; i < splitedBytes.length; i += 4) {
      final r = splitedBytes[i];
      final g = splitedBytes[i + 1];
      final b = splitedBytes[i + 2];
      // if (r < 10 && g > 220 && b < 10) {
      if (!isBack(r, g, b)) {
        continue;
      }
      splitedBytes[i + 3] = 0;
    }
    return splitedBytes;
  }

  int get croppedWidth {
    final endX = math.min(cropEnd.x, image.width);
    final startX = math.max(cropStart.x, 0);
    return (endX - startX).abs().toInt();
  }

  int get croppedHeight {
    final endY = math.min(cropEnd.y, image.height);
    final startY = math.max(cropStart.y, 0);
    return (endY - startY).abs().toInt();
  }

  void process() {
    processImage = Future(
      () {
        assert(image.numChannels == 4);

        final bytes = image.getBytes(order: ChannelOrder.rgba, alpha: 255);
        final croppedBytes = Uint8List(croppedWidth * croppedHeight * 4);
        for (var x = 0; x < croppedWidth; x++) {
          for (var y = 0; y < croppedHeight; y++) {
            final dest = y * croppedWidth * 4 + x * 4;
            final index =
                (y + cropStart.y) * image.width * 4 + (x + cropStart.x) * 4;

            assert(index.toInt() + 3 < bytes.length);
            assert(dest + 3 < croppedBytes.length);

            final r = bytes[index.toInt()];
            final g = bytes[index.toInt() + 1];
            final b = bytes[index.toInt() + 2];

            croppedBytes[dest] = r;
            croppedBytes[dest + 1] = g;
            croppedBytes[dest + 2] = b;

            if (isBack(r, g, b)) {
              final alphaDest = dest + 3;
              croppedBytes[alphaDest] = 0;

              // 近傍ピクセルを透過する
              const d = 0;
              const dlen = d * 2 + 1;
              for (var dx = 0; dx < dlen; dx++) {
                for (var dy = 0; dy < dlen; dy++) {
                  final nx = x + dx - d;
                  final ny = y + dy - d;
                  if (nx < 0 ||
                      nx >= croppedWidth ||
                      ny < 0 ||
                      ny >= croppedHeight) {
                    continue;
                  }
                  final nDest = ny * croppedWidth * 4 + nx * 4;
                  croppedBytes[nDest + 3] = 0;
                }
              }
            } else {
              croppedBytes[dest + 3] = 255;
            }
          }
        }
        cached = true;
        processedImage = Image.fromBytes(
          width: croppedWidth,
          height: croppedHeight,
          bytes: croppedBytes.buffer,
          format: Format.uint8,
          numChannels: 4,
          order: ChannelOrder.rgba,
        );

        return processedImage!;
      },
    );
  }

  Uint8List? get bytes {
    if (!cached || processedImage == null) {
      return null;
    }

    return encodePng(processedImage!);
  }
}
