import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:image/image.dart';
import 'package:uuid/uuid.dart';

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
  }) {
    processedImage = image;
  }

  void setCrop({required Point start, required Point end}) {
    clopStart = start;
    clopEnd = end;
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
    final min = base - (160 * rate).toInt();
    final max = base + (160 * rate).toInt();
    return min <= target && target <= max;
  }

  bool isBack(num r, num g, num b) {
    int bgR = backgroundColor.red;
    int bgG = backgroundColor.green;
    int bgB = backgroundColor.blue;

    return isInRange(r, bgR, colorExpandRate) &&
        isInRange(g, bgG, colorExpandRate) &&
        isInRange(b, bgB, colorExpandRate);
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

  Future<Image> process() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final endX = math.min(clopEnd.x, image.width);
    final endY = math.min(clopEnd.y, image.height);
    final cloppedWidth = (endX - clopStart.x).abs().toInt();
    final cloppedHeight = (endY - clopStart.y).abs().toInt();

    assert(image.numChannels == 4);

    final bytes = image.getBytes(order: ChannelOrder.rgba, alpha: 255);
    final pixelLength = bytes.length ~/ 4;
    const isolateCount = 8;

    final splitedBytes = List.generate(
      isolateCount,
      (index) => bytes.sublist(
        (pixelLength * index ~/ isolateCount) * 4,
        index == isolateCount - 1
            ? bytes.length
            : ((index + 1) * pixelLength ~/ isolateCount) * 4,
      ),
    );

    final computedSplitedBytes = await Future.wait([
      for (final splitedBytes in splitedBytes) compute(setAlpha, splitedBytes),
    ]);

    final processedBytes = Uint8List(bytes.length);
    computedSplitedBytes.fold(0, (value, element) {
      processedBytes.setAll(value, element);
      return value + element.length;
    });

    processedImage = Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: bytes.buffer,
      format: Format.uint8,
      numChannels: 4,
      order: ChannelOrder.rgba,
    );

    cached = true;
    print('process time: ${DateTime.now().millisecondsSinceEpoch - now}');
    return processedImage;
  }

  Uint8List get bytes {
    if (!cached) {
      print('please cache processing result with editing operation');
    }
    return encodePng(processedImage);
  }
}
