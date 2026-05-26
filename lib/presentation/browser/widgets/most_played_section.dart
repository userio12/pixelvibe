import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/providers.dart';
import '../../../data/database/app_database.dart';

final mostPlayedProvider = FutureProvider.autoDispose<List<VideoMetadataData>>((ref) {
  return ref.watch(videoMetadataDaoProvider).mostPlayed(20);
});

class MostPlayedSection extends ConsumerWidget {
  const MostPlayedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mostPlayed = ref.watch(mostPlayedProvider);
    final theme = Theme.of(context);

    return mostPlayed.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text('Could not load: $e')),
      ),
      data: (items) {
        final filtered = items.where((i) => i.playCount > 0).toList();
        if (filtered.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('No frequently played videos yet')),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.trending_up, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Most Played', style: theme.textTheme.titleMedium),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final item = filtered[i];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      final encoded = Uri.encodeComponent(item.filePath);
                      context.push('/player/$encoded');
                    },
                    child: Container(
                      width: 160,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHigh,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              ),
                              child: Center(
                                child: Icon(Icons.movie_outlined, color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title ?? item.filePath.split('/').last,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  '${item.playCount} plays',
                                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
