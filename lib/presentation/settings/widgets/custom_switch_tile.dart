import 'package:flutter/material.dart';

class CustomSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isDisabled;
  final bool isSubtitleError;
  final Widget? customSubtitle;

  const CustomSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.isDisabled = false,
    this.isSubtitleError = false,
    this.customSubtitle,
  });

  Widget? get _subtitleWidget {
    if (customSubtitle case final cs?) {
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: cs,
      );
    }
    if (subtitle case final s?) {
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          s,
          style: TextStyle(
            color: isSubtitleError
                ? const Color(0xFFDCA7A7)
                : const Color(0xFF90959A),
            fontSize: 13,
          ),
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  ?_subtitleWidget,
                ],
              ),
            ),
            const SizedBox(width: 8),
            _CustomSwitch(
              value: value,
              onChanged: isDisabled ? null : onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _CustomSwitch({required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: const Color(0xFF71C4D4),
        activeThumbColor: const Color(0xFF0D2228),
        inactiveTrackColor: const Color(0xFF2C3136),
        inactiveThumbColor: const Color(0xFF8A929A),
      ),
    );
  }
}
