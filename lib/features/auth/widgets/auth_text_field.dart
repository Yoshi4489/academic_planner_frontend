import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthTextField extends StatefulWidget {
  final String? label;
  final IconData icon;
  final TextInputType type;
  final String hintText;
  final IconData? trailing;
  const AuthTextField({
    super.key,
    this.label,
    required this.icon,
    required this.type,
    required this.hintText,
    this.trailing,
  });
  @override
  State<AuthTextField> createState() => _AuthTextField();
}

class _AuthTextField extends State<AuthTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.label != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(widget.label!, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(widget.icon),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  keyboardType: widget.type,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hint: Text(widget.hintText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),)
                  ),
                ),
              ),
              if(widget.trailing != null) Icon(widget.trailing)
            ],
          ),
        )
      ],
    );
  }
}
