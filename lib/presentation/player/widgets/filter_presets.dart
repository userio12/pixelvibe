import 'package:flutter/material.dart';

enum FilterPreset {
  none,
  vivid,
  warmTone,
  coolTone,
  softPastel,
  cinematic,
  dramatic,
  nightMode,
  nostalgic,
  ghibli,
  neonPop,
  deepBlack;

  String get label {
    switch (this) {
      case FilterPreset.none: return 'None';
      case FilterPreset.vivid: return 'Vivid';
      case FilterPreset.warmTone: return 'Warm Tone';
      case FilterPreset.coolTone: return 'Cool Tone';
      case FilterPreset.softPastel: return 'Soft Pastel';
      case FilterPreset.cinematic: return 'Cinematic';
      case FilterPreset.dramatic: return 'Dramatic';
      case FilterPreset.nightMode: return 'Night Mode';
      case FilterPreset.nostalgic: return 'Nostalgic';
      case FilterPreset.ghibli: return 'Ghibli Style';
      case FilterPreset.neonPop: return 'Neon Pop';
      case FilterPreset.deepBlack: return 'Deep Black';
    }
  }

  IconData get icon {
    switch (this) {
      case FilterPreset.none: return Icons.filter_none;
      case FilterPreset.vivid: return Icons.filter_vintage;
      case FilterPreset.warmTone: return Icons.wb_sunny;
      case FilterPreset.coolTone: return Icons.ac_unit;
      case FilterPreset.softPastel: return Icons.blur_on;
      case FilterPreset.cinematic: return Icons.movie_creation;
      case FilterPreset.dramatic: return Icons.flash_on;
      case FilterPreset.nightMode: return Icons.nightlight_round;
      case FilterPreset.nostalgic: return Icons.photo_filter;
      case FilterPreset.ghibli: return Icons.landscape;
      case FilterPreset.neonPop: return Icons.flashlight_on;
      case FilterPreset.deepBlack: return Icons.contrast;
    }
  }
}

final filterPresets = FilterPreset.values;
