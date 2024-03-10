import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/model/overlay_image.dart';

class OverlayImagesNotifier extends StateNotifier<List<OverlayImage>> {
  OverlayImagesNotifier() : super([]);

  void add(OverlayImage image) {
    state = [...state, image];
  }

  void move(int from, int to) {
    var removed = [...state];
    var item = removed.removeAt(from);
    to = to > from ? to - 1 : to;
    removed.insert(to, item);
    state = removed;
  }

  void update() {
    state = [...state];
  }

  void removeAt(int i) {
    var removed = [...state];
    removed.removeAt(i);
    state = removed;
  }

  void clear() {
    state = [];
  }
}

final overlayImagesProvider =
    StateNotifierProvider<OverlayImagesNotifier, List<OverlayImage>>((ref) {
  return OverlayImagesNotifier();
});
