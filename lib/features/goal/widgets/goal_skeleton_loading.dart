import 'package:academic_planner_fe/core/widgets/skeleton_bone.dart';
import 'package:flutter/material.dart';

class GoalSkeletonLoading extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GoalSkeletonLoadingState();
}

class _GoalSkeletonLoadingState extends State<GoalSkeletonLoading>
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

    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FadeTransition(
        opacity: _animation,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBone(width: 30, height: 10),
                        const SizedBox(height: 5,),
                        SkeletonBone(width: 50, height: 10)
                      ],
                    )
                  ],
                ),
                Container(
                  height: 20,
                  width: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
            const SizedBox(height:  10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBone(width: 70, height: 20),
                    SkeletonBone(width: 50, height: 20),
                  ],
                ),
                const SizedBox(height:  10,),
                Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
