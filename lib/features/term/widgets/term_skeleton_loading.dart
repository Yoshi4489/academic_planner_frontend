import 'package:academic_planner_fe/core/widgets/skeleton_bone.dart';
import 'package:flutter/material.dart';

class TermSkeletonLoading extends StatefulWidget {
  const TermSkeletonLoading({super.key});

  @override
  State<TermSkeletonLoading> createState() => _TermSkeletonLoadingState();
}

class _TermSkeletonLoadingState extends State<TermSkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Pulse opacity between 40% and 100%
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. The Main Card (Solid, does NOT fade)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Pure white
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200), // Clear edge boundary
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Soft shadow stops it from blending into white app backgrounds
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // 2. The Inner Skeleton (Fades in and out)
      child: FadeTransition(
        opacity: _animation,
        child: Row(
          children: [
            // The Box Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.grey.shade300, // Darker grey for strong contrast
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 14),
            // The Main Text Lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBone(width: 100, height: 8),
                  const SizedBox(height: 10),
                  SkeletonBone(width: 60, height: 8),
                  const SizedBox(height: 20),
                  SkeletonBone(width: double.infinity, height: 8),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // The Trailing Text Lines
            Column(
              children: [
                SkeletonBone(width: 30, height: 8),
                const SizedBox(height: 10),
                SkeletonBone(width: 40, height: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}