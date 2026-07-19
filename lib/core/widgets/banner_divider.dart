import 'package:flutter/material.dart';

class BannerDivider extends StatelessWidget {
  const BannerDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }
}