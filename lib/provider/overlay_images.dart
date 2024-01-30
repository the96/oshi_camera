import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final overlayImagesProvider = StateProvider<List<Uint8List>>((ref) => []);
