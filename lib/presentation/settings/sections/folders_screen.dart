import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../settings_provider.dart';
import '../../../core/widgets/app_states.dart';
import '../../../services/logger.dart';

class FoldersScreen extends ConsumerWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(blacklistedFoldersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121518),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121518),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Folders',
          style: TextStyle(
            color: Color(0xFF71C4D4),
            fontSize: 22,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Manage folder blacklist',
                style: TextStyle(
                  color: Color(0xFF90959A),
                  fontSize: 13,
                ),
              ),
            ),
            if (folders.isEmpty)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C3136),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Icon(
                        Icons.folder_off_outlined,
                        size: 48,
                        color: Color(0xFF90959A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No blacklisted folders',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Tap the button below to add folders you want to hide from the folder list',
                        style: TextStyle(
                          color: Color(0xFF90959A),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final path = folders[index];
                    return Dismissible(
                      key: ValueKey(path),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        color: const Color(0xFFDCA7A7),
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        final confirmed = await showConfirmDialog(
                          context: context,
                          title: 'Remove folder?',
                          message: path,
                        );
                        return confirmed == true;
                      },
                      onDismissed: (_) {
                        ref.read(blacklistedFoldersProvider.notifier).remove(path);
                      },
                      child: ListTile(
                        leading: const Icon(Icons.folder_off_outlined, color: Color(0xFF90959A)),
                        title: Text(
                          path,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C5D75),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final result = await FilePicker.platform.getDirectoryPath(
                          dialogTitle: 'Select folder to blacklist',
                        );
                        if (result != null) {
                          await ref.read(blacklistedFoldersProvider.notifier).add(result);
                        }
                      } catch (e) {
                        Logger.error('Failed to pick folder', e);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to select folder')),
                          );
                        }
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Add Folder to Blacklist',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
