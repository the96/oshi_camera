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
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    debouncing = Debouncing(duration: const Duration(milliseconds: 200));
  }

  Future<void> updateCrop({
    num? startX,
    num? startY,
    num? endX,
    num? endY,
  }) async {
    final start = widget.image.cropStart;
    final end = widget.image.cropEnd;
    widget.image.setCrop(
      start: image.Point(startX ?? start.x, startY ?? start.y),
      end: image.Point(endX ?? end.x, endY ?? end.y),
    );
    await widget.image.process();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = isDarkMode
        ? ColorScheme.fromSeed(
            seedColor: Colors.blueGrey,
            brightness: Brightness.dark,
          )
        : ColorScheme.fromSeed(
            seedColor: Colors.blueGrey,
            brightness: Brightness.light,
          );

    return Theme(
      data: ThemeData.from(colorScheme: colorScheme),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: colorScheme.background),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 300,
                  child: GestureDetector(
                    behavior: HitTestBehavior.deferToChild,
                    onTapDown: (details) async {
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
                      await widget.image.process();
                      setState(() {});
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
                        updated: (num v) async {
                          await updateCrop(startX: v);
                        },
                      ),
                      ImageImportClopper(
                        max: widget.image.image.width - 1,
                        initValue: widget.image.image.width - 1,
                        updated: (num v) async {
                          await updateCrop(endX: v);
                        },
                      ),
                      ImageImportClopper(
                        max: widget.image.image.height - 1,
                        initValue: 0,
                        updated: (num v) async {
                          await updateCrop(startY: v);
                        },
                      ),
                      ImageImportClopper(
                        max: widget.image.image.height - 1,
                        initValue: widget.image.image.height - 1,
                        updated: (num v) async {
                          await updateCrop(endY: v);
                        },
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
                    child: ImageImportSlider(updated: (v) async {
                      widget.image.colorExpandRate = v;
                      await widget.image.process();
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
            Container(
              alignment: Alignment.topRight,
              child: IconButton(
                iconSize: 32,
                icon: const Icon(Icons.light_mode),
                color: colorScheme.primary,
                onPressed: () {
                  isDarkMode = !isDarkMode;
                  setState(() {});
                },
              ),
            ),
          ],
        ),
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
  Throttling throttling =
      Throttling(duration: const Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          iconSize: 24,
          icon: const Icon(Icons.keyboard_arrow_left),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () {
            expandRate = math.max(0.0, expandRate - 0.01);
            throttling.throttle(() async {
              await widget.updated(expandRate);
            });
            setState(() {});
          },
        ),
        Expanded(
          child: Slider(
            value: expandRate,
            min: 0.0,
            max: 1.0,
            onChanged: (v) async {
              prevExpandRate = expandRate;
              expandRate = v;
              throttling.throttle(() async {
                await widget.updated(v);
              });
              setState(() {});
            },
            onChangeEnd: (v) async {
              await widget.updated(v);
            },
          ),
        ),
        IconButton(
          iconSize: 24,
          icon: const Icon(Icons.keyboard_arrow_right),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () {
            expandRate = math.min(1.0, expandRate + 0.01);
            throttling.throttle(() async {
              await widget.updated(expandRate);
            });
            setState(() {});
          },
        )
      ],
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
  final Debouncing debouncing =
      Debouncing(duration: const Duration(milliseconds: 200));

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
            color: Theme.of(context).colorScheme.primary,
            onPressed: () {
              i = getInRangeValue(i + 1, min: 0, max: widget.max);
              controller.value = TextEditingValue(text: i.toString());
              debouncing.debounce(() async {
                await widget.updated(i);
              });
              setState(() {});
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
                onChanged: (v) {
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
                  debouncing.debounce(() async {
                    await widget.updated(i);
                  });
                  setState(() {});
                },
              ),
            ),
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.touch_app),
              color: Theme.of(context).colorScheme.primary,
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
            color: Theme.of(context).colorScheme.primary,
            onPressed: () {
              i = getInRangeValue(i - 1, min: 0, max: widget.max);
              controller.value = TextEditingValue(text: i.toString());
              debouncing.debounce(() async {
                await widget.updated(i);
              });
              setState(() {});
            },
          ),
        ),
      ],
    );
  }
}
