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

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text("Quick Actions", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final btn = actions[index];
            return _actionButton(context, btn['icon'], btn['label'] as String, btn['color'] as Color);
          },
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
    children: [
      GestureDetector(
        onTap: () {},
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), offset: Offset(0, 3)),
            ],
          ),
          child: Center(
            child: icon is IconData
                ? Icon(icon, color: Colors.white)
                : FaIcon(icon, color: Colors.white),
          ),
        ),
      ),
      const SizedBox(height: 5),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
