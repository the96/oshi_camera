import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:oshi_camera/model/image_import_dialog/chroma_setting.dart';

class ImageProcessor {
  static bool isInRange(num target, int base, double rate) {
    final min = base - (255 * rate).toInt();
    final max = base + (255 * rate).toInt();
    return min <= target && target <= max;
  }

  static bool isBack(num r, num g, num b, ChromaSetting setting) {
    int bgR = setting.r;
    int bgG = setting.g;
    int bgB = setting.b;

    return isInRange(r - g, bgR - bgG, setting.strength) &&
        isInRange(r - b, bgR - bgB, setting.strength) &&
        isInRange(g - b, bgG - bgB, setting.strength) &&
        isInRange(r, bgR, setting.strength) &&
        isInRange(g, bgG, setting.strength) &&
        isInRange(b, bgB, setting.strength);
  }

  static Uint8List setAlpha(Uint8List bytes, ChromaSetting setting) {
    for (int i = 0; i < bytes.length; i += 4) {
      final r = bytes[i];
      final g = bytes[i + 1];
      final b = bytes[i + 2];

      if (!isBack(r, g, b, setting)) {
        continue;
      }
      bytes[i + 3] = 0;
    }

    return bytes;
  }

  static Image process(Image image, ChromaSetting setting) {
    assert(image.numChannels == 4);

    final bytes = image.getBytes(order: ChannelOrder.rgba, alpha: 255);
    final width = image.width;
    final height = image.height;

    final processed = Uint8List(bytes.length);
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        final dest = y * width * 4 + x * 4;
        final index = y * image.width * 4 + x * 4;

        assert(index.toInt() + 3 < bytes.length);
        assert(dest + 3 < processed.length);

        final r = bytes[index.toInt()];
        final g = bytes[index.toInt() + 1];
        final b = bytes[index.toInt() + 2];

        processed[dest] = r;
        processed[dest + 1] = g;
        processed[dest + 2] = b;

        if (isBack(r, g, b, setting)) {
          final alphaDest = dest + 3;
          processed[alphaDest] = 0;

          // 近傍ピクセルを透過する
          const d = 0;
          if (d == 0) continue;

          const dlen = d * 2 + 1;
          for (var dx = 0; dx < dlen; dx++) {
            for (var dy = 0; dy < dlen; dy++) {
              final nx = x + dx - d;
              final ny = y + dy - d;
              if (nx < 0 || nx >= width || ny < 0 || ny >= height) {
                continue;
              }
              final nDest = ny * width * 4 + nx * 4;
              processed[nDest + 3] = 0;
            }
          }
        } else {
          processed[dest + 3] = 255;
        }
      }
    }

    return Image.fromBytes(
      width: width,
      height: height,
      bytes: processed.buffer,
      format: Format.uint8,
      numChannels: 4,
      order: ChannelOrder.rgba,
    );
  }
}
