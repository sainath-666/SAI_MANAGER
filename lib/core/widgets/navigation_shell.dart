import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/color_palette.dart';
import '../router/navigation_item.dart';
import 'responsive_builder.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

class NavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _MobileShell(navigationShell: navigationShell),
      tablet: _TabletShell(navigationShell: navigationShell),
      desktop: _DesktopShell(navigationShell: navigationShell),
    );
  }
}

String _getInitials(String? fullName, String? email) {
  final name = fullName?.trim();
  if (name != null && name.isNotEmpty) {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
  }
  final e = email?.trim();
  if (e != null && e.isNotEmpty) return e[0].toUpperCase();
  return 'U';
}

// ==========================================
// DESKTOP SHELL (Sidebar Panel)
// ==========================================
class _DesktopShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _DesktopShell({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = navigationShell.currentIndex;
    final profile = ref.watch(userProfileProvider).valueOrNull;

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkCard
                  : Colors.white,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                ),
              ),
            ),
            child: Column(
              children: [
                _buildHeader(context),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    itemCount: navigationItems.length,
                    itemBuilder: (context, index) {
                      final item = navigationItems[index];
                      final isSelected = index == activeIndex;
                      return _buildSidebarTile(context, item, index, isSelected);
                    },
                  ),
                ),
                const Divider(),
                _buildProfileFooter(context, profile),
              ],
            ),
          ),
          Expanded(
            child: Scaffold(body: navigationShell),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.terminal, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          const Text(
            'SAI_MANAGER',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarTile(
    BuildContext context,
    NavigationItem item,
    int index,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final activeColor = index % 3 == 0
        ? AppColors.primary
        : index % 3 == 1
            ? AppColors.secondary
            : AppColors.accent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => navigationShell.goBranch(index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: activeColor.withOpacity(0.2), width: 1)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: isSelected ? activeColor : AppColors.darkTextSecondary,
                size: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? (theme.brightness == Brightness.dark
                            ? Colors.white
                            : activeColor)
                        : theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileFooter(BuildContext context, Map<String, dynamic>? profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fullName = profile?['full_name'] as String?;
    final email = profile?['email'] as String?;
    final displayName = (fullName?.isNotEmpty == true) ? fullName! : (email ?? 'User');
    final initials = _getInitials(fullName, email);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.2),
            foregroundColor: AppColors.primary,
            child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Live API',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.primary : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// TABLET SHELL (Navigation Rail)
// ==========================================
class _TabletShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _TabletShell({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = navigationShell.currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final initials = _getInitials(
      profile?['full_name'] as String?,
      profile?['email'] as String?,
    );

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: activeIndex,
            onDestinationSelected: navigationShell.goBranch,
            labelType: NavigationRailLabelType.none,
            backgroundColor: isDark ? AppColors.darkCard : Colors.white,
            indicatorColor: AppColors.primary.withOpacity(0.2),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.secondary.withOpacity(0.2),
                    child: Text(initials,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            destinations: navigationItems.map((item) {
              return NavigationRailDestination(
                icon: Icon(item.icon, color: AppColors.darkTextSecondary),
                selectedIcon: Icon(item.icon, color: AppColors.primary),
                label: Text(item.label),
              );
            }).toList(),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

// ==========================================
// MOBILE SHELL (Bottom Bar + Drawer)
// ==========================================
class _MobileShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  static const List<int> _mobileTabIndices = [0, 4, 5, 8, 12];

  const _MobileShell({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = navigationShell.currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final displayName = (profile?['full_name'] as String?)?.isNotEmpty == true
        ? profile!['full_name'] as String
        : profile?['email'] as String? ?? 'User';

    int bottomBarSelectedIndex = _mobileTabIndices.indexOf(activeIndex);
    if (bottomBarSelectedIndex == -1) bottomBarSelectedIndex = 0;

    final activeItem = navigationItems[activeIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(activeItem.label),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? LucideIcons.moon : LucideIcons.sun,
              size: 20,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.terminal,
                        color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SAI_MANAGER',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        displayName,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: navigationItems.length,
                itemBuilder: (context, index) {
                  final item = navigationItems[index];
                  final isSelected = index == activeIndex;
                  return ListTile(
                    leading: Icon(
                      item.icon,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.darkTextSecondary,
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                    selected: isSelected,
                    onTap: () {
                      Navigator.pop(context);
                      navigationShell.goBranch(index);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomBarSelectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkTextSecondary,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 16,
        onTap: (index) {
          final targetIndex = _mobileTabIndices[index];
          navigationShell.goBranch(targetIndex);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.layoutDashboard, size: 20),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.listTodo, size: 20),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.folderOpen, size: 20),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.dollarSign, size: 20),
            label: 'Finance',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.settings, size: 20),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
