import 'dart:ui';

import 'package:flutter/material.dart';


class AcrylicFAB extends StatelessWidget {
  final void Function()? onTap;

  const AcrylicFAB({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color.fromARGB(108, 0, 0, 0),
      shape: RoundedRectangleBorder(
        borderRadius: .circular(16),
      ),
      onPressed: onTap,
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: .circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Center(
              child: const Icon(Icons.search),
            ),
          ),
        ),
      ),
    );
  }
}