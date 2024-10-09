import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oshi_camera/model/overlay_image.dart';

class OverlayImagesNotifier extends StateNotifier<List<OverlayImage>> {
  OverlayImagesNotifier() : super([]);

  void add(OverlayImage image) {
    state = [...state, image];
  }

  void up(int i) {
    if (i == state.length - 1) return;
    move(i, i + 1);
  }

  void down(int i) {
    if (i == 0) return;
    move(i, i - 1);
  }

  void move(int from, int to) {
    var removed = [...state];
    var item = removed.removeAt(from);
    removed.insert(to, item);
    state = removed;
  }

  void update() {
    state = [...state];
  }

  void remove(OverlayImage image) {
    var removed = [...state];
    removed.remove(image);
    state = removed;
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

final overlayImagesProvider = StateNotifierProvider<OverlayImagesNotifier, List<OverlayImage>>((ref) {
  return OverlayImagesNotifier();
});
