import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as image;
import 'package:oshi_camera/model/overlay_image.dart';
import 'package:oshi_camera/overlay_router.dart';
import 'package:oshi_camera/provider/overlay_images.dart';
import 'package:throttling/throttling.dart';

class ImageImportDialog extends ConsumerStatefulWidget {
  final OverlayImage image;
  const ImageImportDialog({super.key, required this.image});

  @override
  ConsumerState<ImageImportDialog> createState() => _ImageImportDialogState();
}

class _ImageImportDialogState extends ConsumerState<ImageImportDialog> {
  double expandRate = 0.0;
  int updatedAt = DateTime.now().millisecondsSinceEpoch;
  late Debouncing debouncing;

  @override
  void initState() {
    super.initState();
    debouncing = Debouncing(duration: const Duration(milliseconds: 200));
  }

  void updateCrop({
    num? startX,
    num? startY,
    num? endX,
    num? endY,
  }) {
    final start = widget.image.clopStart;
    final end = widget.image.clopEnd;
    widget.image.setCrop(
      start: image.Point(startX ?? start.x, startY ?? start.y),
      end: image.Point(endX ?? end.x, endY ?? end.y),
    );
    setState(() => widget.image.process());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Theme.of(context).dialogBackgroundColor),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 300,
                child: GestureDetector(
                  behavior: HitTestBehavior.deferToChild,
                  onTapDown: (details) {
                    final x = details.localPosition.dx.toInt();
                    final y = details.localPosition.dy.toInt();
                    widget.image.setBackgroundColorPoint(
                      point: image.Point(x, y),
                    );
                    setState(() => widget.image.process());
                  },
                  child: Image.memory(
                    widget.image.bytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: Row(
                  children: [
                    ImageImportClopper(
                      max: widget.image.image.width - 1,
                      initValue: 0,
                      updated: (num v) =>
                          debouncing.debounce(() => updateCrop(startX: v)),
                    ),
                    ImageImportClopper(
                      max: widget.image.image.width - 1,
                      initValue: widget.image.image.width - 1,
                      updated: (num v) =>
                          debouncing.debounce(() => updateCrop(endX: v)),
                    ),
                    ImageImportClopper(
                      max: widget.image.image.height - 1,
                      initValue: 0,
                      updated: (num v) =>
                          debouncing.debounce(() => updateCrop(startY: v)),
                    ),
                    ImageImportClopper(
                      max: widget.image.image.height - 1,
                      initValue: widget.image.image.height - 1,
                      updated: (num v) =>
                          debouncing.debounce(() => updateCrop(endY: v)),
                    ),
                  ],
                ),
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
                  child: ImageImportSlider(
                      updated: (double v) => debouncing.debounce(() {
                            widget.image.setBackgroundColorExpandRate(rate: v);
                            widget.image.process();
                            setState(() => {});
                          })),
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
      ),
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
  double prevExpandRate = 0.0;
  int updatedAt = DateTime.now().millisecondsSinceEpoch;

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: expandRate,
      min: 0.0,
      max: 1.0,
      onChanged: (v) {
        setState(() {
          prevExpandRate = expandRate;
          expandRate = v;
          final now = DateTime.now().millisecondsSinceEpoch;
          if (now - updatedAt > 500) {
            widget.updated(v);
            updatedAt = now;
          }
        });
      },
      onChangeEnd: (v) {
        widget.updated(v);
      },
    );
  }
}

class ImageImportClopper extends ConsumerStatefulWidget {
  final Function updated;
  final int initValue;
  final int max;
  const ImageImportClopper(
      {super.key,
      required this.updated,
      required this.max,
      required this.initValue});

  @override
  ConsumerState<ImageImportClopper> createState() => _ImageImportClopperState();
}

class _ImageImportClopperState extends ConsumerState<ImageImportClopper> {
  int i = 0;
  late TextEditingController controller;

  int getInRangeValue(int v, {required int min, required int max}) {
    return math.min(math.max(min, v), max);
  }

  @override
  void initState() {
    super.initState();
    i = widget.initValue;
    controller = TextEditingController(text: widget.initValue.toString());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 4),
          width: 48,
          child: IconButton(
            iconSize: 32,
            icon: const Icon(Icons.keyboard_arrow_up),
            onPressed: () {
              setState(() {
                i = getInRangeValue(i + 1, min: 0, max: widget.max);
                controller.value = TextEditingValue(text: i.toString());
                widget.updated(i);
              });
            },
          ),
        ),
        Row(
          children: [
            Container(
              width: 48,
              padding: const EdgeInsets.only(left: 8),
              child: TextField(
                controller: controller,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) => setState(() {
                  late int value;
                  try {
                    value = int.parse(v);
                  } catch (e) {
                    value = 0;
                  }
                  i = getInRangeValue(
                    value,
                    min: 0,
                    max: widget.max,
                  );
                  controller.value = TextEditingValue(text: i.toString());
                  widget.updated(i);
                  return;
                }),
              ),
            ),
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.touch_app),
              onPressed: () {},
            ),
          ],
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 4),
          width: 48,
          child: IconButton(
            iconSize: 32,
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () {
              setState(() {
                i = getInRangeValue(i - 1, min: 0, max: widget.max);
                controller.value = TextEditingValue(text: i.toString());
                widget.updated(i);
              });
            },
          ),
        ),
      ],
    );
  }
}
