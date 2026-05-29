import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../video_quality_provider.dart';
import '../../settings/settings_provider.dart';

class VideoQualitySheet extends ConsumerWidget {
  const VideoQualitySheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ts = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Video Quality & Filters', style: ts.titleMedium),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              _SectionHeader(title: 'Profile'),
              _ProfileTile(),
              const Divider(height: 24),

              _SectionHeader(title: 'Decoder'),
              _HwdecTile(),
              _GpuApiTile(),
              _HrSeekTile(),
              const Divider(height: 24),

              _SectionHeader(title: 'Filters'),
              _FilterPresetTile(),
              const Divider(height: 24),

              _SectionHeader(title: 'Transform'),
              _MirrorTile(),
              _FlipTile(),
              const Divider(height: 24),

              _SectionHeader(title: 'Color'),
              _ColorSlider(
                label: 'Brightness',
                provider: videoBrightnessProvider,
                min: -100, max: 100,
              ),
              _ColorSlider(
                label: 'Contrast',
                provider: videoContrastProvider,
                min: -100, max: 100,
              ),
              _ColorSlider(
                label: 'Saturation',
                provider: videoSaturationProvider,
                min: -100, max: 100,
              ),
              _ColorSlider(
                label: 'Gamma',
                provider: videoGammaProvider,
                min: -100, max: 100,
              ),
              const Divider(height: 24),

              _SectionHeader(title: 'Shaders'),
              _ShaderPresetTile(),
              const Divider(height: 24),

              _SectionHeader(title: 'Screenshot'),
              _ScreenshotSubsTile(),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
    );
  }
}

// ── Profile ─────────────────────────────────────────────────────────
class _ProfileTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(mpvProfileProvider.notifier);
    final activeName = ref.watch(mpvProfileProvider);
    final profiles = notifier.allProfiles;

    Future<void> saveAs() async {
      final ctl = TextEditingController();
      final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Save as profile'),
          content: TextField(
            controller: ctl,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Profile name'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(ctl.text.trim()), child: const Text('Save')),
          ],
        ),
      );
      if (name != null && name.isNotEmpty) {
        await ref.read(mpvProfileProvider.notifier).saveCurrentAs(name);
      }
    }

    return ListTile(
      title: const Text('MPV profile'),
      subtitle: Text(activeName, style: Theme.of(context).textTheme.bodySmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (profiles.any((p) => !p.isBuiltIn && p.name == activeName))
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => ref.read(mpvProfileProvider.notifier).deleteCustom(activeName),
              tooltip: 'Delete profile',
            ),
          DropdownButton<String>(
            value: activeName,
            items: profiles
                .map((p) => DropdownMenuItem(
                      value: p.name,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(p.name),
                          if (p.isBuiltIn)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(Icons.lock_outline, size: 14,
                                  color: Theme.of(context).colorScheme.outline),
                            ),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) ref.read(mpvProfileProvider.notifier).select(v);
            },
          ),
          IconButton(
            icon: Icon(Icons.save_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
            onPressed: saveAs,
            tooltip: 'Save current settings as new profile',
          ),
        ],
      ),
    );
  }
}

// ── Hwdec ──────────────────────────────────────────────────────────
class _HwdecTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(hwdecProvider);
    return ListTile(
      title: const Text('Hardware decoder'),
      subtitle: const Text('hwdec profile'),
      trailing: DropdownButton<String>(
        value: current,
        items: const [
          DropdownMenuItem(value: 'auto', child: Text('Auto')),
          DropdownMenuItem(value: 'auto-safe', child: Text('Auto (safe)')),
          DropdownMenuItem(value: 'no', child: Text('Software')),
          DropdownMenuItem(value: 'mediacodec', child: Text('MediaCodec')),
          DropdownMenuItem(value: 'cuda', child: Text('CUDA')),
          DropdownMenuItem(value: 'd3d11va', child: Text('D3D11VA')),
          DropdownMenuItem(value: 'vaapi', child: Text('VAAPI')),
        ],
        onChanged: (v) => ref.read(hwdecProvider.notifier).update(v ?? 'auto'),
      ),
    );
  }
}

// ── GPU API ────────────────────────────────────────────────────────
class _GpuApiTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(gpuApiProvider);
    return ListTile(
      title: const Text('GPU backend'),
      trailing: DropdownButton<String>(
        value: current,
        items: const [
          DropdownMenuItem(value: 'auto', child: Text('Auto')),
          DropdownMenuItem(value: 'vulkan', child: Text('Vulkan')),
          DropdownMenuItem(value: 'opengl', child: Text('OpenGL')),
        ],
        onChanged: (v) => ref.read(gpuApiProvider.notifier).update(v ?? 'auto'),
      ),
    );
  }
}

// ── HR Seek ────────────────────────────────────────────────────────
class _HrSeekTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = ref.watch(hrSeekProvider);
    return SwitchListTile(
      title: const Text('Precise seeking'),
      subtitle: const Text('hr-seek (frame-accurate jumps)'),
      value: v,
      onChanged: (_) => ref.read(hrSeekProvider.notifier).toggle(),
    );
  }
}

// ── Filter preset ──────────────────────────────────────────────────
class _FilterPresetTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(vfPresetProvider);
    return ListTile(
      title: const Text('Filter preset'),
      subtitle: const Text('vf chain applied at runtime'),
      trailing: DropdownButton<String>(
        value: current,
        items: const [
          DropdownMenuItem(value: 'none', child: Text('None')),
          DropdownMenuItem(value: 'deband', child: Text('Deband')),
          DropdownMenuItem(value: 'sharpen', child: Text('Sharpen')),
          DropdownMenuItem(value: 'denoise', child: Text('Denoise')),
          DropdownMenuItem(value: 'deband+sharpen', child: Text('Deband + Sharpen')),
          DropdownMenuItem(value: 'deband+denoise', child: Text('Deband + Denoise')),
        ],
        onChanged: (v) => ref.read(vfPresetProvider.notifier).update(v ?? 'none'),
      ),
    );
  }
}

// ── Mirror / Flip ──────────────────────────────────────────────────
class _MirrorTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = ref.watch(mirrorProvider);
    return SwitchListTile(
      title: const Text('Mirror (hflip)'),
      value: v,
      onChanged: (_) => ref.read(mirrorProvider.notifier).toggle(),
    );
  }
}

class _FlipTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = ref.watch(flipProvider);
    return SwitchListTile(
      title: const Text('Flip (vflip)'),
      value: v,
      onChanged: (_) => ref.read(flipProvider.notifier).toggle(),
    );
  }
}

// ── Color slider ───────────────────────────────────────────────────
class _ColorSlider extends ConsumerWidget {
  final String label;
  final NotifierProvider<dynamic, int> provider;
  final int min;
  final int max;

  const _ColorSlider({
    required this.label,
    required this.provider,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final val = ref.watch(provider);
    return ListTile(
      title: Text(label),
      trailing: SizedBox(
        width: 200,
        child: Row(
          children: [
            Text('$val', style: Theme.of(context).textTheme.bodySmall),
            Expanded(
              child: Slider(
                value: val.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: max - min,
                label: '$val',
                onChanged: (v) => ref.read(provider.notifier).update(v.round()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shader presets ─────────────────────────────────────────────────
class _ShaderPresetTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(shaderPresetProvider);
    return ListTile(
      title: const Text('Shader preset'),
      subtitle: const Text('glsl-shaders (Anime4K, etc)'),
      trailing: DropdownButton<String>(
        value: current,
        items: const [
          DropdownMenuItem(value: 'none', child: Text('None')),
          DropdownMenuItem(value: 'Anime4K_Restore_CNN_L.glsl', child: Text('Anime4K Restore')),
          DropdownMenuItem(value: 'Anime4K_Upscale_CNN_L.glsl', child: Text('Anime4K Upscale')),
        ],
        onChanged: (v) => ref.read(shaderPresetProvider.notifier).update(v ?? 'none'),
      ),
    );
  }
}

// ── Screenshot subtitles ───────────────────────────────────────────
class _ScreenshotSubsTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = ref.watch(screenshotSubsProvider);
    return SwitchListTile(
      title: const Text('Subtitles in screenshot'),
      subtitle: const Text('subs-with-subs'),
      value: v,
      onChanged: (_) => ref.read(screenshotSubsProvider.notifier).toggle(),
    );
  }
}
