import 'package:flutter/material.dart';

class FolderListTile extends StatelessWidget {
  final String name;
  final String? subtitle;
  final int? itemCount;
  final VoidCallback onTap;

  const FolderListTile({
    super.key,
    required this.name,
    this.subtitle,
    this.itemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: name,
      child: ListTile(
        leading: const Icon(Icons.folder_outlined),
        title: Text(name),
        subtitle: subtitle != null
            ? Text(subtitle!)
            : (itemCount != null ? Text('$itemCount items') : null),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
