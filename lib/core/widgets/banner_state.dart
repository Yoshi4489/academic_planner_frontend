import 'package:flutter/material.dart';

class BannerStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const BannerStat({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }
}
