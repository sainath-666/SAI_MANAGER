import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NavigationItem {
  final String label;
  final IconData icon;
  final String path;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.path,
  });
}

const List<NavigationItem> navigationItems = [
  NavigationItem(label: 'Dashboard', icon: LucideIcons.layoutDashboard, path: '/'),
  NavigationItem(label: 'Office Work', icon: LucideIcons.briefcase, path: '/office'),
  NavigationItem(label: 'Freelance', icon: LucideIcons.laptop, path: '/freelance'),
  NavigationItem(label: 'Completed', icon: LucideIcons.checkSquare, path: '/completed'),
  NavigationItem(label: 'Tasks', icon: LucideIcons.listTodo, path: '/tasks'),
  NavigationItem(label: 'Projects', icon: LucideIcons.folderOpen, path: '/projects'),
  NavigationItem(label: 'Calendar', icon: LucideIcons.calendar, path: '/calendar'),
  NavigationItem(label: 'Notes', icon: LucideIcons.fileText, path: '/notes'),
  NavigationItem(label: 'Finance', icon: LucideIcons.dollarSign, path: '/finance'),
  NavigationItem(label: 'Developer', icon: LucideIcons.code, path: '/dev'),
  NavigationItem(label: 'Goals & Habits', icon: LucideIcons.award, path: '/goals'),
  NavigationItem(label: 'Learning', icon: LucideIcons.graduationCap, path: '/learning'),
  NavigationItem(label: 'Settings', icon: LucideIcons.settings, path: '/settings'),
];
