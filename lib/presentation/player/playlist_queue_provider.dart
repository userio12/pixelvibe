import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LoopMode { off, one, all }

class PlaylistQueue {
  final List<String> filePaths;
  final List<String> titles;
  final int currentIndex;
  final bool shuffled;
  final List<int> shuffleOrder;

  const PlaylistQueue({
    this.filePaths = const [],
    this.titles = const [],
    this.currentIndex = 0,
    this.shuffled = false,
    this.shuffleOrder = const [],
  });

  String get currentFile => currentIndex >= 0 && currentIndex < filePaths.length ? filePaths[currentIndex] : '';
  String get currentTitle => currentIndex >= 0 && currentIndex < titles.length ? titles[currentIndex] : '';
  int get length => filePaths.length;
  bool get hasMultiple => filePaths.length > 1;
  bool get hasNext => currentIndex < filePaths.length - 1 || shuffled;
  bool get hasPrev => currentIndex > 0;
}

final playlistQueueProvider = NotifierProvider<PlaylistQueueNotifier, PlaylistQueue>(
  PlaylistQueueNotifier.new,
);

class PlaylistQueueNotifier extends Notifier<PlaylistQueue> {
  @override
  PlaylistQueue build() => const PlaylistQueue();

  void load(List<String> filePaths, {List<String>? titles, int startIndex = 0}) {
    state = PlaylistQueue(
      filePaths: filePaths,
      titles: titles ?? filePaths.map((f) => f.split('/').last.split('.').first).toList(),
      currentIndex: startIndex.clamp(0, filePaths.length - 1),
    );
  }

  void clear() {
    state = const PlaylistQueue();
  }

  void goTo(int index) {
    if (index < 0 || index >= state.filePaths.length) return;
    state = PlaylistQueue(
      filePaths: state.filePaths,
      titles: state.titles,
      currentIndex: index,
      shuffled: state.shuffled,
      shuffleOrder: state.shuffleOrder,
    );
  }

  String? next(LoopMode repeat, bool autoplayNext) {
    if (!state.hasMultiple && !autoplayNext) return null;

    int nextIndex = state.currentIndex + 1;

    if (nextIndex >= state.filePaths.length) {
      switch (repeat) {
        case LoopMode.off:
          return null;
        case LoopMode.one:
          nextIndex = state.currentIndex;
        case LoopMode.all:
          nextIndex = 0;
      }
    }

    if (state.shuffled) {
      final order = state.shuffleOrder;
      if (order.isEmpty) return null;
      final currentPos = order.indexOf(state.currentIndex);
      final nextPos = currentPos + 1;
      if (nextPos >= order.length) {
        if (repeat == LoopMode.all) {
          final newShuffle = _generateShuffle(state.filePaths.length, order.last);
          state = PlaylistQueue(
            filePaths: state.filePaths,
            titles: state.titles,
            currentIndex: order.last,
            shuffled: true,
            shuffleOrder: newShuffle,
          );
          return state.currentFile;
        }
        return null;
      }
      final shuffledIndex = order[nextPos];
      state = PlaylistQueue(
        filePaths: state.filePaths,
        titles: state.titles,
        currentIndex: shuffledIndex,
        shuffled: true,
        shuffleOrder: order,
      );
    } else {
      state = PlaylistQueue(
        filePaths: state.filePaths,
        titles: state.titles,
        currentIndex: nextIndex,
      );
    }
    return state.currentFile;
  }

  String? previous() {
    if (state.currentIndex <= 0) return null;

    if (state.shuffled) {
      final order = state.shuffleOrder;
      final currentPos = order.indexOf(state.currentIndex);
      if (currentPos <= 0) return null;
      state = PlaylistQueue(
        filePaths: state.filePaths,
        titles: state.titles,
        currentIndex: order[currentPos - 1],
        shuffled: true,
        shuffleOrder: order,
      );
    } else {
      state = PlaylistQueue(
        filePaths: state.filePaths,
        titles: state.titles,
        currentIndex: state.currentIndex - 1,
      );
    }
    return state.currentFile;
  }

  void toggleShuffle() {
    final newShuffled = !state.shuffled;
    state = PlaylistQueue(
      filePaths: state.filePaths,
      titles: state.titles,
      currentIndex: state.currentIndex,
      shuffled: newShuffled,
      shuffleOrder: newShuffled ? _generateShuffle(state.filePaths.length, state.currentIndex) : [],
    );
  }

  List<int> _generateShuffle(int length, int excludeIndex) {
    final indices = List.generate(length, (i) => i)..remove(excludeIndex);
    indices.shuffle(Random());
    return [excludeIndex, ...indices];
  }
}
