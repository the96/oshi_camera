import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:tuple/tuple.dart';

// 切り抜き設定済みの画像
class OverlayImage {
  final Image image;
  Point clopStart = Point(0, 0);
  Point clopEnd = Point(double.infinity, double.infinity);
  Point backgroundColorPoint = Point(0, 0);
  // 透過する背景色の拡張率, 0.0 ~ 1.0
  double colorExpandRate = 0.0;

  bool cached = false;
  late Image croppedImage;
  late Image processedImage;

  OverlayImage({
    required this.image,
  }) {
    croppedImage = Image.from(image);
    processedImage = Image.from(image);
  }

  void setCrop({required Point start, required Point end}) {
    final diffX = start.x - clopStart.x;
    final diffY = start.y - clopStart.y;
    backgroundColorPoint.x = math.max(0, backgroundColorPoint.x - diffX);
    backgroundColorPoint.y = math.max(0, backgroundColorPoint.y - diffY);

    clopStart = start;
    clopEnd = end;
    cached = false;
  }

  void setBackgroundColorPoint({
    required Point point,
  }) {
    backgroundColorPoint = point;
    cached = false;
  }

  void setBackgroundColorExpandRate({
    required double rate,
  }) {
    colorExpandRate = rate;
    cached = false;
  }

  bool isInRange(num target, num base, double rate) {
    final min = base - (50 * rate).toInt();
    final max = base + (50 * rate).toInt();
    return min <= target && target <= max;
  }

  bool isBack(Color color, Color backgroundColor) {
    final r = color.r;
    final g = color.g;
    final b = color.b;

    final bgR = backgroundColor.r;
    final bgG = backgroundColor.g;
    final bgB = backgroundColor.b;

    return isInRange(r, bgR, colorExpandRate) &&
        isInRange(g, bgG, colorExpandRate) &&
        isInRange(b, bgB, colorExpandRate);
  }

  // TODO: Future化したほうがいいかも
  Image process() {
    final endX = math.min(clopEnd.x, image.width);
    final endY = math.min(clopEnd.y, image.height);
    final cloppedWidth = (endX - clopStart.x).abs().toInt();
    final cloppedHeight = (endY - clopStart.y).abs().toInt();

    croppedImage = copyCrop(
      image,
      x: clopStart.x.toInt(),
      y: clopStart.y.toInt(),
      width: cloppedWidth,
      height: cloppedHeight,
    );
    processedImage = Image.from(croppedImage);

    final queue = <Tuple2<Point, Pixel>>[];
    final checkedPointMap = List.generate(
      processedImage.width,
      (_) => List.generate(
        processedImage.height,
        (_) => false,
      ),
    );

    queue.add(
      Tuple2(
        backgroundColorPoint,
        processedImage.getPixel(
          backgroundColorPoint.x.toInt(),
          backgroundColorPoint.y.toInt(),
        ),
      ),
    );
    checkedPointMap[backgroundColorPoint.x.toInt()]
        [backgroundColorPoint.y.toInt()] = true;

    print("start");
    print(
        "backgroundPoint: ${backgroundColorPoint.x}, ${backgroundColorPoint.y}");
    var count = 0;
    while (queue.isNotEmpty) {
      count++;
      final entry = queue.removeAt(0);
      final point = entry.item1;
      final pixel = entry.item2;
      processedImage.setPixelRgba(
        point.x.toInt(),
        point.y.toInt(),
        pixel.r,
        pixel.g,
        pixel.b,
        0,
      );

      final points = [
        Point(point.x + 1, point.y),
        Point(point.x - 1, point.y),
        Point(point.x, point.y + 1),
        Point(point.x, point.y - 1),
      ];

      for (var targetPoint in points) {
        if (targetPoint.x < 0) continue;
        if (targetPoint.y < 0) continue;
        if (targetPoint.x >= processedImage.width) continue;
        if (targetPoint.y >= processedImage.height) continue;
        if (checkedPointMap[targetPoint.x.toInt()][targetPoint.y.toInt()]) {
          continue;
        }

        final targetPixel = processedImage.getPixel(
          targetPoint.x.toInt(),
          targetPoint.y.toInt(),
        );
        if (!isBack(targetPixel, pixel)) continue;

        queue.add(
          Tuple2(
            targetPoint,
            targetPixel,
          ),
        );
        checkedPointMap[targetPoint.x.toInt()][targetPoint.y.toInt()] = true;
      }
    }
    print("finish");
    print("processed times: ${count}");

    cached = true;
    processedImage = processedImage;
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
