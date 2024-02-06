import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

GlobalKey importImageKey = GlobalKey();

class ImportImageRender extends StatefulWidget {
  final img.Image image;
  final Function onImageTap;
  const ImportImageRender({
    required this.image,
    required this.onImageTap,
    super.key,
  });

  @override
  State<ImportImageRender> createState() => _ImportImageRenderState();
}

class _ImportImageRenderState extends State<ImportImageRender> {
  Offset? offset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTapDown: (details) async {
            final RenderBox? renderBox =
                importImageKey.currentContext?.findRenderObject() as RenderBox?;

            if (renderBox == null) {
              return;
            }

            final dx = details.localPosition.dx.toInt();
            final dy = details.localPosition.dy.toInt();

            final imageRenderSize = renderBox.size;
            final x = (widget.image.width / imageRenderSize.width) * dx;
            final y = (widget.image.height / imageRenderSize.height) * dy;

            final pixel = widget.image.getPixel(x.toInt(), y.toInt());
            offset = Offset(dx.toDouble(), dy.toDouble());
            setState(() {});

            final color = Color.fromRGBO(
              pixel.r.toInt(),
              pixel.g.toInt(),
              pixel.b.toInt(),
              1,
            );

            widget.onImageTap(color);
          },
          child: Image.memory(
            img.encodePng(widget.image),
            fit: BoxFit.contain,
            key: importImageKey,
          ),
        ),
        Positioned(
          left: (offset?.dx ?? 0),
          top: (offset?.dy ?? 0),
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
    );
  }
}
