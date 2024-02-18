import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

GlobalKey importImageKey = GlobalKey();

class ImportImageRender extends StatelessWidget {
  final img.Image image;
  final Uint8List bytes;
  final Offset pointer;
  final Function onImageTap;
  const ImportImageRender({
    required this.image,
    required this.bytes,
    required this.pointer,
    required this.onImageTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: mediaQuery.size.width,
        maxHeight: mediaQuery.size.height - 120,
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onTapDown: (details) async {
              final RenderBox? renderBox = importImageKey.currentContext
                  ?.findRenderObject() as RenderBox?;

              if (renderBox == null) {
                return;
              }

              final dx = details.localPosition.dx.toInt();
              final dy = details.localPosition.dy.toInt();

              final imageRenderSize = renderBox.size;
              final x = (image.width / imageRenderSize.width) * dx;
              final y = (image.height / imageRenderSize.height) * dy;

              final pixel = image.getPixel(x.toInt(), y.toInt());
              final color = Color.fromRGBO(
                pixel.r.toInt(),
                pixel.g.toInt(),
                pixel.b.toInt(),
                1,
              );

              onImageTap(color, dx, dy);
            },
            child: Image.memory(
              bytes,
              fit: BoxFit.contain,
              key: importImageKey,
            ),
          ),
          Positioned(
            left: pointer.dx - 4,
            top: pointer.dy - 4,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          )
        ],
      ),
    );
  }
}
