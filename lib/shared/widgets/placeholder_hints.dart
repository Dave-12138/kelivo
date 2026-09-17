import 'package:flutter/material.dart';

import '../../icons/lucide_adapter.dart';
import '../../theme/app_font_weights.dart';

class PlaceholderHints extends StatelessWidget {
  const PlaceholderHints({
    required this.items,
    required this.onTapVar,
    this.cacheWarningVars = const <String>{},
    this.cacheWarningTooltip,
    super.key,
  });

  final List<(String, String)> items; // (label, variable)
  final ValueChanged<String> onTapVar;
  final Set<String> cacheWarningVars;
  final String? cacheWarningTooltip;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        for (final it in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${it.$1}: ',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.75),
                ),
              ),
              InkWell(
                onTap: () => onTapVar(it.$2),
                child: Text(
                  it.$2,
                  style: TextStyle(
                    color: cs.primary,
                    decoration: TextDecoration.underline,
                    fontSize: 12,
                    fontWeight: AppFontWeights.semibold,
                  ),
                ),
              ),
              if (cacheWarningVars.contains(it.$2)) ...[
                const SizedBox(width: 4),
                Tooltip(
                  message: cacheWarningTooltip ?? '',
                  child: Icon(Lucide.TriangleAlert, size: 14, color: cs.error),
                ),
              ],
            ],
          ),
      ],
    );
  }
}
