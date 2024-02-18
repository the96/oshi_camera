import 'dart:math';

class CropSetting {
  final int x;
  final int y;
  final int width;
  final int height;

  CropSetting({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  CropSetting.fromPoint({
    required Point start,
    required Point end,
  })  : x = start.x.toInt(),
        y = start.y.toInt(),
        width = (end.x - start.x).toInt(),
        height = (end.y - start.y).toInt();
}
