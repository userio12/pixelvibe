import 'package:flutter/material.dart';

const commonLanguages = [
  ('en', 'English'),
  ('es', 'Spanish'),
  ('fr', 'French'),
  ('de', 'German'),
  ('it', 'Italian'),
  ('pt', 'Portuguese'),
  ('ru', 'Russian'),
  ('ja', 'Japanese'),
  ('ko', 'Korean'),
  ('zh', 'Chinese'),
  ('ar', 'Arabic'),
  ('hi', 'Hindi'),
  ('nl', 'Dutch'),
  ('pl', 'Polish'),
  ('tr', 'Turkish'),
  ('sv', 'Swedish'),
  ('da', 'Danish'),
  ('fi', 'Finnish'),
  ('no', 'Norwegian'),
  ('cs', 'Czech'),
  ('hu', 'Hungarian'),
  ('ro', 'Romanian'),
  ('th', 'Thai'),
  ('vi', 'Vietnamese'),
  ('el', 'Greek'),
  ('he', 'Hebrew'),
];

void showLanguagePicker(
  BuildContext context,
  String currentValue,
  void Function(String) onSave,
) {
  final selected = currentValue.isEmpty
      ? <String>{}
      : currentValue.split(',').map((s) => s.trim().toLowerCase()).toSet();

  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E2227),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          final localSelected = {...selected};
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: const Text(
                  'Select Languages',
                  style: TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFF2C3136)),
              SizedBox(
                height: 300,
                child: ListView(
                  children: commonLanguages.map((entry) {
                    final (code, name) = entry;
                    final sel = localSelected.contains(code);
                    return CheckboxListTile(
                      title: Text(name, style: const TextStyle(color: Colors.white70)),
                      subtitle: Text(code, style: const TextStyle(color: Color(0xFF90959A), fontSize: 12)),
                      value: sel,
                      activeColor: const Color(0xFF71C4D4),
                      checkColor: const Color(0xFF0D2228),
                      onChanged: (v) {
                        setSheetState(() {
                          if (v == true) { localSelected.add(code); }
                          else { localSelected.remove(code); }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF71C4D4),
                      foregroundColor: const Color(0xFF0D2228),
                    ),
                    onPressed: () {
                      onSave(localSelected.join(','));
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
