import 'package:flutter/material.dart';

class AuthTextField extends StatefulWidget {
  final String? label;
  final IconData icon;
  final TextInputType type;
  final String hintText;
  final IconData? trailing;
  final TextEditingController? controller;
  final Function(String?) validator;

  const AuthTextField({
    super.key,
    this.label,
    required this.icon,
    required this.type,
    required this.hintText,
    this.trailing,
    this.controller,
    required this.validator,
  });
  @override
  State<AuthTextField> createState() => _AuthTextField();
}

class _AuthTextField extends State<AuthTextField> {
  bool isVisible = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.label != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.label!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
                child: TextFormField(
                  controller: widget.controller,
                  obscureText:
                      widget.type == TextInputType.visiblePassword && !isVisible
                      ? true
                      : false,
                  keyboardType: widget.type,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade400,
                    ),
                  ),
                  validator: (value) => widget.validator(value),
                ),
              ),
              if (widget.type == TextInputType.visiblePassword)
                IconButton(
                  onPressed: () {
                    setState(() {
                      isVisible = !isVisible;
                    });
                  },
                  icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
                )
              else if (widget.trailing != null)
                Icon(widget.trailing!),
            ],
          ),
        ),
      ],
    );
  }
}
