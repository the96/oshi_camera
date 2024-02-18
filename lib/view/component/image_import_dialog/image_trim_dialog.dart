import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:oshi_camera/model/image_import_dialog/crop_setting.dart';
import 'package:oshi_camera/model/import_processing_image.dart';
import 'package:oshi_camera/overlay_router.dart';
import 'package:oshi_camera/provider/image_import_dialog/process_image.dart';
import 'package:oshi_camera/view/component/image_import_dialog/image_transparentize_dialog.dart';

const imageTrimDialogRoute = '/image/trim';

class ImageTrimDialog extends ConsumerStatefulWidget {
  final img.Image image;

  const ImageTrimDialog({
    required this.image,
    super.key,
  });

  @override
  ConsumerState<ImageTrimDialog> createState() => _ImageTrimDialogState();
}

class _ImageTrimDialogState extends ConsumerState<ImageTrimDialog> {
  Uint8List? png;
  double x = 0;
  double y = 0;
  Point leftTop = const Point(0, 0);
  Point rightBottom = const Point(double.infinity, double.infinity);
  bool visibleLupeView = false;
  late Size screenSize;

  double get radius => screenSize.width / 2;

  double convertPreviewCordinate(double n) {
    return n * screenSize.width / widget.image.width;
  }

  @override
  void initState() {
    super.initState();

    png = img.encodePng(widget.image);
    rightBottom =
        Point(widget.image.width.toDouble(), widget.image.height.toDouble());
    setState(() {});
  }

  List<Widget> get previewMarker {
    final previewRadius = convertPreviewCordinate(radius);
    final previewX = convertPreviewCordinate(x);
    final previewY = convertPreviewCordinate(y);
    final previewLeftTop = Point(
      convertPreviewCordinate(leftTop.x.toDouble()),
      convertPreviewCordinate(leftTop.y.toDouble()),
    );
    final previewRightBottom = Point(
      convertPreviewCordinate(rightBottom.x.toDouble()),
      convertPreviewCordinate(rightBottom.y.toDouble()),
    );
    const previewCrosshairSize = 10;
    return [
      Positioned(
        left: previewLeftTop.x,
        top: previewLeftTop.y,
        child: IgnorePointer(
          child: Container(
            width: previewRightBottom.x - previewLeftTop.x,
            height: previewRightBottom.y - previewLeftTop.y,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 2,
              ),
            ),
          ),
        ),
      ),
      Positioned(
        top: previewY - previewRadius,
        left: previewX - previewRadius,
        child: IgnorePointer(
          child: Container(
            width: previewRadius * 2,
            height: previewRadius * 2,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red.withOpacity(0.8),
                width: 2,
              ),
            ),
          ),
        ),
      ),
      Positioned(
        top: previewY - previewCrosshairSize / 2,
        left: previewX - previewCrosshairSize / 2,
        child: IgnorePointer(
          child: CustomPaint(
            size: Size(
              previewCrosshairSize.toDouble(),
              previewCrosshairSize.toDouble(),
            ),
            painter: Crosshair(
              strokeWidth: 1,
              color: Colors.red.withOpacity(0.8),
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (png == null) {
      return Center(child: Container(color: Colors.white));
    }
    screenSize = MediaQuery.of(context).size;

    return Material(
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: screenSize.height - 300,
                      ),
                      child: GestureDetector(
                        onPanStart: (d) =>
                            setState(() => visibleLupeView = true),
                        onPanEnd: (d) =>
                            setState(() => visibleLupeView = false),
                        onPanUpdate: (details) {
                          setState(() {
                            final imageWidth = widget.image.width;
                            final imageHeight = widget.image.height;

                            final dx = x - details.delta.dx * 2;
                            final dy = y - details.delta.dy * 2;
                            if (0 <= dx && dx <= imageWidth + 1) x = dx;
                            if (0 <= dy && dy <= imageHeight + 1) y = dy;
                          });
                        },
                        child: Image.memory(
                          png!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    ...previewMarker,
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('左端'),
                          ElevatedButton(
                            onPressed: () => setState(
                              () => leftTop = Point(x.toInt(), leftTop.y),
                            ),
                            child: const Text('決定'),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('右端'),
                          ElevatedButton(
                            onPressed: () => setState(
                              () =>
                                  rightBottom = Point(x.toInt(), rightBottom.y),
                            ),
                            child: const Text('決定'),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('上端'),
                          ElevatedButton(
                            onPressed: () => setState(
                              () => leftTop = Point(leftTop.x, y.toInt()),
                            ),
                            child: const Text('決定'),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('下端'),
                          ElevatedButton(
                            onPressed: () => setState(
                              () =>
                                  rightBottom = Point(rightBottom.x, y.toInt()),
                            ),
                            child: const Text('決定'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              width: screenSize.width,
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(originalImageProvider.notifier).state =
                        widget.image;
                    ref.read(cropSettingProvider.notifier).state =
                        CropSetting.fromPoint(start: leftTop, end: rightBottom);
                    OverlayRouter.replace(
                      routeName: imageTransparentizeDialogRoute,
                      ref: ref,
                    );
                  },
                  child: const Text('次へ'),
                ),
              ),
            ),
            if (visibleLupeView)
              Center(
                child: LupeView(
                  x: x,
                  y: y,
                  radius: radius,
                  png: png!,
                  leftTop: leftTop,
                  rightBottom: rightBottom,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class LupeView extends StatelessWidget {
  final double x, y, radius;
  final Uint8List png;
  final Point leftTop, rightBottom;

  const LupeView({
    super.key,
    required this.x,
    required this.y,
    required this.radius,
    required this.png,
    required this.leftTop,
    required this.rightBottom,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: -x + radius,
            top: -y + radius,
            child: Image.memory(
              png,
              alignment: Alignment.topLeft,
              scale: 1.0,
              fit: BoxFit.none,
            ),
          ),
          Positioned(
            left: (leftTop.x - x + radius).toDouble(),
            top: (leftTop.y - y + radius).toDouble(),
            child: Container(
              width: (rightBottom.x - leftTop.x).toDouble(),
              height: (rightBottom.y - leftTop.y).toDouble(),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue.withOpacity(0.5),
                  width: 3,
                ),
              ),
            ),
          ),
          Center(
            child: CustomPaint(
              size: const Size(50, 50),
              painter: Crosshair(),
            ),
          ),
        ],
      ),
    );
  }
}

class Crosshair extends CustomPainter {
  final double strokeWidth;
  final Color color;
  @override
  Crosshair({this.strokeWidth = 3, this.color = Colors.red});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = color;
    paint.strokeWidth = strokeWidth;

    canvas.drawLine(
        Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
