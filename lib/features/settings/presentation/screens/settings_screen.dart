import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/color_palette.dart';
import '../../../../core/widgets/glass_card.dart';

// Simple theme mode provider for demo
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.settings, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Customize application preferences, manage mock data sessions, and toggle themes.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: SwitchListTile(
                title: const Text('Dark Theme Mode'),
                subtitle: const Text('Toggle between dark-slate and light-slate interfaces.'),
                secondary: Icon(
                  themeMode == ThemeMode.dark ? LucideIcons.moon : LucideIcons.sun,
                  color: AppColors.primary,
                ),
                value: themeMode == ThemeMode.dark,
                onChanged: (val) {
                  ref.read(themeModeProvider.notifier).state =
                      val ? ThemeMode.dark : ThemeMode.light;
                },
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'System Diagnostics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  _buildSettingRow(
                    context,
                    icon: LucideIcons.database,
                    title: 'In-Memory Cache Status',
                    trailing: const Text(
                      'Running (100% Mock)',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(height: 24),
                  _buildSettingRow(
                    context,
                    icon: LucideIcons.gitBranch,
                    title: 'Current Build Version',
                    trailing: const Text(
                      '1.0.0-phase1+demo',
                      style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(height: 24),
                  _buildSettingRow(
                    context,
                    icon: LucideIcons.server,
                    title: 'API Server Endpoint',
                    trailing: const Text(
                      'None (Backend-Ready)',
                      style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.darkTextSecondary, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        trailing,
      ],
    );
  }
}
