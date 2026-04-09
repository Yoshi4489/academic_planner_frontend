import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class QuickActions extends StatelessWidget {
  QuickActions({super.key});

  final actions = [
    {
      "label": "Term",
      "icon": Icons.add,
      "color": Color.fromRGBO(7, 116, 240, 0.76),
    },
    {
      "label": "Course",
      "icon": FontAwesomeIcons.bookOpen,
      "color": Color.fromRGBO(178, 5, 255, 1),
    },
    {
      "label": "Goal",
      "icon": FontAwesomeIcons.bullseye,
      "color": Color.fromRGBO(27, 228, 9, 1),
    },
    {
      "label": "Graph",
      "icon": FontAwesomeIcons.chartLine,
      "color": Color.fromRGBO(255, 157, 0, 1),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text("Quick Actions", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 20),
        // Replace GridView with a responsive Row
        Row(
          children: actions.map((btn) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10), // Spacing between buttons
                child: _actionButton(
                  context,
                  btn['icon'],
                  btn['label'] as String,
                  btn['color'] as Color,
                ),
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}

Widget _actionButton(
    BuildContext context,
    dynamic icon,
    String label,
    Color color,
    ) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      GestureDetector(
        onTap: () {},
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.4), offset: const Offset(0, 3), blurRadius: 2),
              ],
            ),
            child: Center(
              child: icon is IconData
                  ? Icon(icon, color: Colors.white)
                  : FaIcon(icon, color: Colors.white),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label, style: Theme.of(context).textTheme.bodySmall),
      ),
    ],
  );
}
