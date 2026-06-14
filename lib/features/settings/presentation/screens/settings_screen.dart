import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/color_palette.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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
                const Icon(
                  LucideIcons.settings,
                  color: AppColors.primary,
                  size: 28,
                ),
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
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: SwitchListTile(
                title: const Text('Dark Theme Mode'),
                subtitle: const Text(
                  'Toggle between dark-slate and light-slate interfaces.',
                ),
                secondary: Icon(
                  themeMode == ThemeMode.dark
                      ? LucideIcons.moon
                      : LucideIcons.sun,
                  color: AppColors.primary,
                ),
                value: themeMode == ThemeMode.dark,
                onChanged: (val) {
                  ref.read(themeModeProvider.notifier).state = val
                      ? ThemeMode.dark
                      : ThemeMode.light;
                },
                activeThumbColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'System Diagnostics',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  _buildSettingRow(
                    context,
                    icon: LucideIcons.database,
                    title: 'In-Memory Cache Status',
                    trailing: Text(
                      ApiClient.isConfigured ? 'Running (Live API)' : 'Running (100% Mock)',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  _buildSettingRow(
                    context,
                    icon: LucideIcons.gitBranch,
                    title: 'Current Build Version',
                    trailing: const Text(
                      '1.0.0-phase2+dynamic',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  _buildSettingRow(
                    context,
                    icon: LucideIcons.server,
                    title: 'API Server Endpoint',
                    trailing: Text(
                      ApiClient.isConfigured ? ApiClient.baseUrl : 'None (Backend-Ready)',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'API Authentication',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const _ApiLoginCard(),
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
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        trailing,
      ],
    );
  }
}

class _ApiLoginCard extends ConsumerStatefulWidget {
  const _ApiLoginCard();

  @override
  ConsumerState<_ApiLoginCard> createState() => _ApiLoginCardState();
}

class _ApiLoginCardState extends ConsumerState<_ApiLoginCard> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final loggedInEmail = profile?['email'] as String? ?? 'Authenticated';

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Account Session',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Icon(
                authState.token != null ? LucideIcons.unlock : LucideIcons.lock,
                color: authState.token != null ? AppColors.secondary : AppColors.warning,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (authState.token != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.checkCircle2, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Signed in as $loggedInEmail',
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(LucideIcons.logOut, size: 16),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ] else ...[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Backend Email Address',
                hintText: 'e.g. demo@sai-manager.com',
                prefixIcon: Icon(LucideIcons.mail, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(LucideIcons.key, size: 18),
              ),
            ),
            if (authState.error != null) ...[
              const SizedBox(height: 12),
              Text(
                authState.error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        final success = await ref
                            .read(authProvider.notifier)
                            .login(_emailController.text, _passwordController.text);
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Logged in successfully!')),
                          );
                        }
                      },
                icon: authState.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(LucideIcons.logIn, size: 16),
                label: Text(authState.isLoading ? 'Authenticating...' : 'Establish Live Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
