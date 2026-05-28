import 'package:flutter/material.dart';

class SettingsCardGroup extends StatelessWidget {
  final String sectionTitle;
  final List<Widget> children;
  final double horizontalPadding;
  final Set<int> skipDividerAfter;

  const SettingsCardGroup({
    super.key,
    required this.sectionTitle,
    required this.children,
    this.horizontalPadding = 16,
    this.skipDividerAfter = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              sectionTitle,
              style: const TextStyle(
                color: Color(0xFF71C4D4),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E2227),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: _buildChildrenWithDividers(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChildrenWithDividers() {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i < children.length - 1 && !skipDividerAfter.contains(i)) {
        items.add(
          const Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: Color(0xFF2C3136),
          ),
        );
      }
    }
    return items;
  }
}
