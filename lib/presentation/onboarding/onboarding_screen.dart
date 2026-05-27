import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../bootstrap.dart';
import '../../data/repositories/media_repository.dart';
import '../../domain/services/media_scanner.dart';
import '../../services/logger.dart';
import '../../services/scan_service.dart';
import '../../utils/permissions/permission_handler.dart';
import '../settings/settings_provider.dart';
import '../../core/router/routes.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  var _currentPage = 0;
  var _permissionGranted = false;
  var _storagePath = '';
  var _scanning = false;

  static const _pages = ['Welcome', 'Permission', 'Finish Setup'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    final granted = await requestStoragePermission();
    if (mounted) setState(() => _permissionGranted = granted);
  }

  Future<void> _pickStorage() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null && mounted) setState(() => _storagePath = result);
  }

  Future<void> _completeOnboarding() async {
    final prefs = preferencesService;
    await prefs.setOnboardingComplete();

    setState(() => _scanning = true);

    final granted = await requestStoragePermission();
    if (granted) {
      try {
        final dao = database.videoMetadataDao;
        final scanner = MediaScanner();
        final scanService = ScanService();
        final repo = MediaRepository(dao, scanner, scanService);
        await repo.scanDevice(force: true);
        Logger.info('Initial scan completed');
      } catch (e) {
        Logger.error('Initial scan failed', e);
      }
    }

    if (mounted) context.go(Routes.browse);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildWelcomePage(theme, colorScheme),
                  _buildPermissionPage(theme, colorScheme),
                  _buildFinishPage(theme, colorScheme),
                ],
              ),
            ),
            _buildBottomBar(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              Icons.video_library_rounded,
              size: 64,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Welcome to pixelvibe',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your video player. Browse, stream, and organize your media library with hardware-accelerated playback.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionPage(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _permissionGranted
                  ? colorScheme.primaryContainer
                  : colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              _permissionGranted
                  ? Icons.folder_rounded
                  : Icons.folder_open_rounded,
              size: 64,
              color: _permissionGranted
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Access Your Videos',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'pixelvibe needs access to your video files to build your media library. Your videos stay on your device.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _requestPermission,
            icon: Icon(_permissionGranted ? Icons.check : Icons.shield_rounded),
            label: Text(_permissionGranted ? 'Access Granted' : 'Grant Access'),
          ),
          if (_permissionGranted)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Video access granted!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFinishPage(ThemeData theme, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              Icons.palette_rounded,
              size: 64,
              color: colorScheme.onTertiaryContainer,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Almost Done',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Storage location
          _buildSection(
            theme,
            Icons.storage_rounded,
            'Storage Location',
            _storagePath.isEmpty
                ? 'Default video directories'
                : _storagePath,
            'Change',
            _pickStorage,
          ),
          const SizedBox(height: 16),

          // Theme selector
          _buildThemeSection(theme, colorScheme),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme,
    IconData icon,
    String title,
    String value,
    String actionLabel,
    VoidCallback onAction,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: theme.textTheme.titleSmall),
        subtitle: Text(value, style: theme.textTheme.bodySmall),
        trailing: TextButton(onPressed: onAction, child: Text(actionLabel)),
      ),
    );
  }

  Widget _buildThemeSection(ThemeData theme, ColorScheme colorScheme) {
    final currentTheme = ref.watch(themeModeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.palette_rounded),
              title: Text('Theme', style: theme.textTheme.titleSmall),
              subtitle: Text(_themeLabel(currentTheme), style: theme.textTheme.bodySmall),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Row(
              children: ThemeMode.values.map((mode) {
                final selected = currentTheme == mode;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: mode == ThemeMode.values.first ? 0 : 4,
                      right: mode == ThemeMode.values.last ? 0 : 4,
                    ),
                    child: FilterChip(
                      label: Text(_themeLabel(mode)),
                      selected: selected,
                      onSelected: (_) {
                        ref.read(themeModeProvider.notifier).update(mode);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  Widget _buildBottomBar(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              if (_currentPage > 0)
                TextButton(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: const Text('Back'),
                ),
              if (_currentPage > 0) const Spacer(),
              _currentPage < _pages.length - 1
                  ? FilledButton(
                      onPressed: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text('Continue'),
                    )
                  : FilledButton.icon(
                      onPressed: _scanning ? null : _completeOnboarding,
                      icon: _scanning
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.arrow_forward_rounded),
                      label: Text(_scanning ? 'Scanning...' : 'Start Browsing'),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
