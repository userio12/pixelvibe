import 'package:flutter/material.dart';

class StandardActionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isDisabled;
  final Widget? trailing;
  final IconData? leadingIcon;
  final Color? titleColor;
  final VoidCallback? onTap;

  const StandardActionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.isDisabled = false,
    this.trailing,
    this.leadingIcon,
    this.titleColor,
    this.onTap,
  });

  Widget? get _subtitleWidget {
    if (subtitle == null) return null;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        subtitle!,
        style: const TextStyle(
          color: Color(0xFF90959A),
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, color: const Color(0xFF71C4D4), size: 22),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor ?? Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    ?_subtitleWidget,
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
