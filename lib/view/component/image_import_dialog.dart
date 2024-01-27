import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/model/overlay_image.dart';
import 'package:oshi_camera/overlay_router.dart';
import 'package:oshi_camera/provider/overlay_images.dart';

class ImageImportDialog extends ConsumerStatefulWidget {
  final OverlayImage image;
  const ImageImportDialog({super.key, required this.image});

  @override
  ConsumerState<ImageImportDialog> createState() => _ImageImportDialogState();
}

class _ImageImportDialogState extends ConsumerState<ImageImportDialog> {
  double expandRate = 0.0;
  int updatedAt = DateTime.now().millisecondsSinceEpoch;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Theme.of(context).dialogBackgroundColor),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onTapDown: (details) {
                final x = details.localPosition.dx.toInt();
                final y = details.localPosition.dy.toInt();
                final pixel = widget.image.image.getPixel(x, y);
                widget.image.setBackgroundColor(
                  color: Color.fromRGBO(
                    pixel.r.toInt(),
                    pixel.g.toInt(),
                    pixel.b.toInt(),
                    1,
                  ),
                );
                widget.image.process();
                setState(() => {});
              },
              child: Image.memory(widget.image.bytes, fit: BoxFit.contain),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                '背景色の閾値',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: Container(
                alignment: Alignment.bottomCenter,
                margin: const EdgeInsets.only(bottom: 32),
                transformAlignment: Alignment.bottomCenter,
                height: 32,
                child: ImageImportSlider(updated: (v) {
                  widget.image.colorExpandRate = v;
                  widget.image.process();
                  setState(() => {});
                }),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.only(bottom: 32),
              child: ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  widget.image.process();
                  final overlayImages = ref.read(overlayImagesProvider);
                  ref.read(overlayImagesProvider.notifier).state = [
                    ...overlayImages,
                    widget.image,
                  ];
                  OverlayRouter.pop(ref);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ImageImportSlider extends ConsumerStatefulWidget {
  final Function updated;
  const ImageImportSlider({super.key, required this.updated});

  @override
  ConsumerState<ImageImportSlider> createState() => _ImageImportSliderState();
}

class _ImageImportSliderState extends ConsumerState<ImageImportSlider> {
  double expandRate = 0.0;
  int updatedAt = DateTime.now().millisecondsSinceEpoch;

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: expandRate,
      min: 0.0,
      max: 1.0,
      onChanged: (v) {
        setState(() => expandRate = v);
      },
      onChangeEnd: (v) {
        widget.updated(v);
      },
    );
  }
}
