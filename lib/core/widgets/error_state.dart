import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  final String error;
  const ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(error, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
