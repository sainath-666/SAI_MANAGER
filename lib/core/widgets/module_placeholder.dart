import 'package:flutter/material.dart';
import '../theme/color_palette.dart';
import 'glass_card.dart';

class ModulePlaceholder extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final List<Widget>? actions;
  final Widget? content;

  const ModulePlaceholder({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    this.actions,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (actions != null) Row(children: actions!),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          if (content != null) content!,
          if (content == null)
            GlassCard(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(icon, size: 64, color: AppColors.secondary.withOpacity(0.4)),
                  const SizedBox(height: 20),
                  Text(
                    '$title Module Active',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This workspace is currently running in Phase 1 (Local Static Mode). All presentation controllers, state providers, and abstract repository patterns are bound. Swap in a REST API or Supabase client configuration in Phase 2 & 3.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildBadge(context, 'MOCK ACTIVE', AppColors.primary),
                      _buildBadge(context, 'API READY', AppColors.secondary),
                      _buildBadge(context, 'SUPABASE COMPATIBLE', AppColors.accent),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
