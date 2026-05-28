import 'package:flutter/material.dart';

enum PlayerButton {
  backArrow(Icons.arrow_back_ios, 'Back'),
  videoTitle(null, 'Title'),
  speed(Icons.speed, 'Speed'),
  skipBack(Icons.replay_10, 'Skip -10s'),
  skipForward(Icons.forward_10, 'Skip +10s'),
  playPause(null, 'Play/Pause'),
  abLoop(Icons.loop, 'A-B Loop'),
  frameNav(Icons.video_stable, 'Frame Step'),
  audioTrack(Icons.audiotrack, 'Audio'),
  subtitles(Icons.subtitles, 'Subtitles'),
  chapters(Icons.chat_bubble_outline, 'Chapters'),
  repeat(Icons.repeat, 'Repeat'),
  shuffle(Icons.shuffle, 'Shuffle'),
  playlist(Icons.playlist_play, 'Playlist'),
  info(Icons.info_outline, 'Info'),
  screenshot(Icons.screenshot, 'Screenshot'),
  aspectRatio(Icons.aspect_ratio, 'Aspect Ratio'),
  zoom(Icons.zoom_in, 'Zoom'),
  more(Icons.more_vert, 'More'),
  lock(Icons.lock, 'Lock'),
  pip(Icons.picture_in_picture_alt, 'PiP'),
  sleepTimer(Icons.timer_outlined, 'Sleep'),
  volume(Icons.volume_up, 'Volume'),
  addToPlaylist(Icons.playlist_add, 'Add to Playlist'),

  // Actions (not buttons)
  loadSubtitle(Icons.subtitles_outlined, 'Load Subtitle'),
  decoder(Icons.settings, 'Decoder'),
  filters(Icons.filter, 'Filters');

  final IconData? icon;
  final String label;
  const PlayerButton(this.icon, this.label);

  String get tooltip => label;
}
