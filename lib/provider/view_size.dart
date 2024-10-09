import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final viewSizeProvider = StateProvider<Size>((ref) {
  return const Size(0, 0);
});
