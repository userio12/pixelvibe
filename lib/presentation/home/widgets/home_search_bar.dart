import 'package:flutter/material.dart';

class BrowserSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const BrowserSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search videos...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear), onPressed: onClear)
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
      ),
    );
  }
}
