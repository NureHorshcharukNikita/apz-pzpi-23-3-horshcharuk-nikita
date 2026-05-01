import 'dart:typed_data';

import 'package:flutter/material.dart';

class ProfileAvatarCircle extends StatelessWidget {
  const ProfileAvatarCircle({
    super.key,
    required this.radius,
    this.bytes,
  });

  final double radius;
  final List<int>? bytes;

  static const double _coverOvershoot = 1.08;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;

    if (bytes == null || bytes!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: Icon(Icons.person, size: radius * 1.1),
      );
    }

    final outer = size * _coverOvershoot;

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: OverflowBox(
          alignment: Alignment.center,
          minWidth: outer,
          minHeight: outer,
          maxWidth: outer,
          maxHeight: outer,
          child: Image.memory(
            Uint8List.fromList(bytes!),
            fit: BoxFit.cover,
            width: outer,
            height: outer,
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}
