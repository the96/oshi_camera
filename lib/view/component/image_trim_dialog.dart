import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:oshi_camera/model/import_processing_image.dart';
import 'package:image/image.dart' as img;

class ImageTrimDialog extends StatefulWidget {
  final ImportProcessingImage image;

  const ImageTrimDialog({
    required this.image,
    super.key,
  });

  @override
  State<ImageTrimDialog> createState() => _ImageTrimDialogState();
}

class _ImageTrimDialogState extends State<ImageTrimDialog> {
  Uint8List? png;
  double x = 0;
  double y = 0;
  Point leftTop = const Point(0, 0);
  Point rightBottom = const Point(double.infinity, double.infinity);
  bool visibleLupeView = false;
  late Size screenSize;

  @override
  void initState() {
    super.initState();

    widget.image.process();
    widget.image.processImage!.then((image) {
      png = widget.image.encoded;
      rightBottom = Point(
        widget.image.image.width.toDouble(),
        widget.image.image.height.toDouble(),
      );
      setState(() {});
    });
  }

  double convertPreviewCordinate(double n) {
    return n * screenSize.width / widget.image.image.width;
  }

  @override
  Widget build(BuildContext context) {
    if (png == null) {
      return Container(
        alignment: Alignment.center,
        child: const AspectRatio(
          aspectRatio: 1.0,
          child: CircularProgressIndicator(),
        ),
      );
    }
    screenSize = MediaQuery.of(context).size;

    final radius = screenSize.width / 2;

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

    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            children: [
              GestureDetector(
                onPanStart: (d) => setState(() => visibleLupeView = true),
                onPanEnd: (d) => setState(() => visibleLupeView = false),
                onPanUpdate: (details) {
                  setState(() {
                    final imageWidth = widget.image.image.width;
                    final imageHeight = widget.image.image.height;

                    final dx = x - details.delta.dx;
                    final dy = y - details.delta.dy;
                    if (0 <= dx && dx < imageWidth) x = dx;
                    if (0 <= dy && dy < imageHeight) y = dy;
                  });
                },
                child: Image.memory(
                  png!,
                  fit: BoxFit.contain,
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
                        color: Colors.red,
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
                    painter: Crosshair(strokeWidth: 1),
                  ),
                ),
              ),
              Positioned(
                left: previewLeftTop.x,
                top: previewLeftTop.y,
                child: IgnorePointer(
                  child: Container(
                    width: previewRightBottom.x - previewLeftTop.x,
                    height: previewRightBottom.y - previewLeftTop.y,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (visibleLupeView)
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Expanded(
                      child: Container(
                    color: Colors.white,
                  )),
                  Positioned(
                    top: -y + radius,
                    left: -x + radius,
                    child: Image.memory(
                      png!,
                      alignment: Alignment.topLeft,
                      scale: 1.0,
                      fit: BoxFit.none,
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
            ),
        ],
      ),
    );
  }
}

class Crosshair extends CustomPainter {
  final double strokeWidth;
  @override
  Crosshair({this.strokeWidth = 3});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.red;
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
