import 'package:flutter/material.dart';

class FolderListTile extends StatelessWidget {
  final String name;
  final int itemCount;
  final VoidCallback onTap;

  const FolderListTile({
    super.key,
    required this.name,
    required this.itemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: name,
      child: ListTile(
        leading: const Icon(Icons.folder_outlined),
        title: Text(name),
        subtitle: Text('$itemCount videos'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
