import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/model/overlay_image.dart';

final overlayImagesProvider = StateProvider<List<OverlayImage>>((ref) => []);
