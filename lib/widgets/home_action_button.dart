import 'package:flutter/material.dart';

class HomeActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const HomeActionButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(250, 50),
        textStyle: const TextStyle(fontSize: 18),
      ),
    );
  }
}