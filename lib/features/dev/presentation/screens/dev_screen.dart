import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/color_palette.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/responsive_builder.dart';
import '../../../../core/network/api_client.dart';

class DevWorkspaceScreen extends StatefulWidget {
  const DevWorkspaceScreen({super.key});

  @override
  State<DevWorkspaceScreen> createState() => _DevWorkspaceScreenState();
}

class _DevWorkspaceScreenState extends State<DevWorkspaceScreen> {
  // JSON formatter state
  final _jsonController = TextEditingController(text: '{\n  "status": "active",\n  "apiReady": true,\n  "version": "1.0.0"\n}');
  String _jsonOutput = '';
  String _jsonError = '';

  // Base64 converter state
  final _b64InputController = TextEditingController(text: 'SAI_MANAGER');
  String _b64Output = 'U0FJX01BTkFHRVI=';
  bool _isEncodeMode = true;

  // Simulator Logs
  final List<String> _simulatedLogs = [
    '[01:30:12] [SYS] Cache database initialized (mockTasksJson, mockProjectsJson binding success).',
    '[01:30:13] [NET] HTTP Client bounds to mock repository endpoints.',
    '[01:30:22] [GET] /api/tasks - 200 OK (fetched 5 active records)',
    '[01:30:22] [GET] /api/projects - 200 OK (fetched 3 active records)',
    '[01:30:22] [GET] /api/finance/summary - 200 OK (ledger summary bound)',
    '[01:33:55] [PATCH] /api/tasks/task-1 - 204 No Content (toggled completion)',
    '[01:35:10] [GET] /api/tasks - 200 OK (fetched 5 active records)',
  ];

  void _formatJson() {
    setState(() {
      _jsonError = '';
      try {
        final parsed = jsonDecode(_jsonController.text);
        _jsonOutput = const JsonEncoder.withIndent('  ').convert(parsed);
      } catch (e) {
        _jsonOutput = '';
        _jsonError = 'Invalid JSON: ${e.toString()}';
      }
    });
  }

  void _minifyJson() {
    setState(() {
      _jsonError = '';
      try {
        final parsed = jsonDecode(_jsonController.text);
        _jsonOutput = jsonEncode(parsed);
      } catch (e) {
        _jsonOutput = '';
        _jsonError = 'Invalid JSON: ${e.toString()}';
      }
    });
  }

  void _convertBase64() {
    setState(() {
      try {
        if (_isEncodeMode) {
          final bytes = utf8.encode(_b64InputController.text);
          _b64Output = base64.encode(bytes);
        } else {
          final decodedBytes = base64.decode(_b64InputController.text);
          _b64Output = utf8.decode(decodedBytes);
        }
      } catch (e) {
        _b64Output = 'Conversion Error: ${e.toString()}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBuilder.isDesktop(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),
            const SizedBox(height: 24),

            // Top Row: API Configuration Status
            _buildApiConfigCard(context),
            const SizedBox(height: 24),

            // Responsive columns for developer utilities
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildJsonFormatterCard(context)),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: _buildToolsAndLogsColumn(context)),
                ],
              )
            else ...[
              _buildJsonFormatterCard(context),
              const SizedBox(height: 24),
              _buildToolsAndLogsColumn(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(LucideIcons.code, color: AppColors.primary, size: 28),
        const SizedBox(width: 12),
        Text(
          'Developer Workspace Console',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildApiConfigCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.activity, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                'API Environment Context',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _buildConfigItem('BASE ENDPOINT URL', ApiClient.baseUrl, AppColors.primary),
              _buildConfigItem(
                'AUTH METHOD STATE',
                ApiClient.isConfigured ? 'TOKEN BOUND' : 'OFFLINE STATIC MODE',
                ApiClient.isConfigured ? AppColors.secondary : AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.darkTextMuted, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.2), width: 0.5),
          ),
          child: Text(
            value,
            style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildJsonFormatterCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'JSON Formatter & Validator',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Icon(LucideIcons.braces, color: AppColors.primary, size: 18),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _jsonController,
            maxLines: 6,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            decoration: const InputDecoration(
              labelText: 'Paste JSON Raw String',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _formatJson,
                icon: const Icon(LucideIcons.check, size: 14),
                label: const Text('Prettify'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _minifyJson,
                icon: const Icon(LucideIcons.minimize, size: 14),
                label: const Text('Minify'),
              ),
            ],
          ),
          if (_jsonError.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(_jsonError, style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
          if (_jsonOutput.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'OUTPUT LOG',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(maxHeight: 180),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.3) : AppColors.lightBg.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _jsonOutput,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToolsAndLogsColumn(BuildContext context) {
    return Column(
      children: [
        _buildBase64Card(context),
        const SizedBox(height: 24),
        _buildSimulatedLogsCard(context),
      ],
    );
  }

  Widget _buildBase64Card(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Base64 Encoder / Decoder',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Icon(LucideIcons.binary, color: AppColors.secondary, size: 18),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Encode'),
                selected: _isEncodeMode,
                onSelected: (selected) {
                  if (selected) setState(() => _isEncodeMode = true);
                },
                selectedColor: AppColors.secondary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: _isEncodeMode ? AppColors.secondary : null,
                  fontWeight: _isEncodeMode ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Decode'),
                selected: !_isEncodeMode,
                onSelected: (selected) {
                  if (selected) setState(() => _isEncodeMode = false);
                },
                selectedColor: AppColors.secondary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: !_isEncodeMode ? AppColors.secondary : null,
                  fontWeight: !_isEncodeMode ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _b64InputController,
            onChanged: (_) => _convertBase64(),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            decoration: const InputDecoration(
              labelText: 'Converter Input String',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'RESULT',
            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.darkTextMuted),
          ),
          const SizedBox(height: 4),
          SelectableText(
            _b64Output,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatedLogsCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Console Log Stream',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Icon(LucideIcons.terminal, color: AppColors.accent, size: 18),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 160,
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: ListView.builder(
              itemCount: _simulatedLogs.length,
              itemBuilder: (context, index) {
                final log = _simulatedLogs[index];
                Color logColor = Colors.white70;
                if (log.contains('[GET]')) logColor = AppColors.secondary;
                if (log.contains('[PATCH]')) logColor = AppColors.accent;
                if (log.contains('[SYS]')) logColor = AppColors.primary;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    log,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: logColor),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
