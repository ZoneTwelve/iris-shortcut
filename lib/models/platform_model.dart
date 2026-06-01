// lib/models/platform_model.dart

enum PlatformStatus { configured, notConfigured, comingSoon }

class ShortcutPlatform {
  final String id;
  final String name;
  final String description;
  final String iconEmoji;
  final Color accentColor;
  final PlatformStatus status;
  final String? deepLinkTemplate; // e.g. "tg://resolve?domain={username}"
  final String? webFallbackTemplate; // e.g. "https://t.me/{username}"
  final String configKey; // key stored in SharedPreferences
  final String configLabel; // e.g. "Telegram Username"
  final String configHint; // e.g. "@iris_ai"
  final List<String> setupSteps;

  const ShortcutPlatform({
    required this.id,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.accentColor,
    required this.status,
    this.deepLinkTemplate,
    this.webFallbackTemplate,
    required this.configKey,
    required this.configLabel,
    required this.configHint,
    required this.setupSteps,
  });

  String? buildDeepLink(String configValue) {
    if (deepLinkTemplate == null) return null;
    return deepLinkTemplate!.replaceAll('{value}', configValue);
  }

  String? buildWebLink(String configValue) {
    if (webFallbackTemplate == null) return null;
    return webFallbackTemplate!.replaceAll('{value}', configValue);
  }
}

// Flutter Color is in dart:ui, so we re-export as int for the model layer
// and resolve in the UI layer. Use a simple int wrapper.
class Color {
  final int value;
  const Color(this.value);
}
