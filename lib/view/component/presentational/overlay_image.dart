import 'package:flutter/material.dart';
import 'package:oshi_camera/model/overlay_image.dart' as model;

class OverlayImage extends StatelessWidget {
  final model.OverlayImage image;

  const OverlayImage({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      image.bytes,
      fit: BoxFit.contain,
    );
  }
}
