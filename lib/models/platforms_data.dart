// lib/models/platforms_data.dart

import 'package:flutter/material.dart';

enum PlatformStatus { configured, notConfigured, comingSoon }

class ShortcutPlatform {
  final String id;
  final String name;
  final String description;
  final String iconEmoji;
  final Color accentColor;
  final PlatformStatus status;
  final String? deepLinkTemplate;
  final String? webFallbackTemplate;
  final String configKey;
  final String configLabel;
  final String configHint;
  final List<String> setupSteps;
  final bool isComingSoon;

  const ShortcutPlatform({
    required this.id,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.accentColor,
    this.status = PlatformStatus.notConfigured,
    this.deepLinkTemplate,
    this.webFallbackTemplate,
    required this.configKey,
    required this.configLabel,
    required this.configHint,
    required this.setupSteps,
    this.isComingSoon = false,
  });

  String? buildDeepLink(String configValue) {
    if (deepLinkTemplate == null || configValue.isEmpty) return null;
    return deepLinkTemplate!.replaceAll('{value}', configValue);
  }

  String? buildWebLink(String configValue) {
    if (webFallbackTemplate == null || configValue.isEmpty) return null;
    return webFallbackTemplate!.replaceAll('{value}', configValue);
  }
}

final List<ShortcutPlatform> allPlatforms = [
  ShortcutPlatform(
    id: 'telegram',
    name: 'Telegram',
    description: 'Open Iris chat on Telegram',
    iconEmoji: '✈️',
    accentColor: const Color(0xFF29B6F6),
    deepLinkTemplate: 'tg://resolve?domain={value}',
    webFallbackTemplate: 'https://t.me/{value}',
    configKey: 'telegram_username',
    configLabel: 'Telegram Username',
    configHint: 'e.g. iris_ai (without @)',
    setupSteps: [
      'Search for Iris on Telegram',
      'Copy the username from their profile',
      'Paste it in the field above',
      'Tap the Telegram card to open the chat instantly',
    ],
  ),
  ShortcutPlatform(
    id: 'instagram',
    name: 'Instagram',
    description: 'Open Iris DM on Instagram',
    iconEmoji: '📸',
    accentColor: const Color(0xFFE91E8C),
    deepLinkTemplate: 'instagram://user?username={value}',
    webFallbackTemplate: 'https://www.instagram.com/{value}',
    configKey: 'instagram_username',
    configLabel: 'Instagram Username',
    configHint: 'e.g. iris.official (without @)',
    setupSteps: [
      'Find Iris on Instagram',
      'Copy the username from their profile',
      'Paste it above',
      'Tap to open their profile and start a DM',
    ],
  ),
  ShortcutPlatform(
    id: 'whatsapp',
    name: 'WhatsApp',
    description: 'Open Iris on WhatsApp',
    iconEmoji: '💬',
    accentColor: const Color(0xFF25D366),
    deepLinkTemplate: 'whatsapp://send?phone={value}',
    webFallbackTemplate: 'https://wa.me/{value}',
    configKey: 'whatsapp_phone',
    configLabel: 'WhatsApp Phone Number',
    configHint: 'e.g. 15551234567 (with country code, no +)',
    setupSteps: [
      'Get the WhatsApp number for Iris',
      'Enter it with country code (no + or spaces)',
      'Tap to open WhatsApp chat directly',
    ],
  ),
  ShortcutPlatform(
    id: 'wechat',
    name: 'WeChat',
    description: 'Open Iris on WeChat',
    iconEmoji: '🟢',
    accentColor: const Color(0xFF07C160),
    // WeChat does not support reliable deep links to specific chats.
    // weixin:// scheme can open the app but not navigate to a contact.
    // Best effort: open WeChat app, user navigates manually.
    deepLinkTemplate: 'weixin://',
    webFallbackTemplate: null,
    configKey: 'wechat_id',
    configLabel: 'WeChat ID',
    configHint: 'e.g. iris_wechat',
    setupSteps: [
      'Find Iris WeChat ID',
      'Paste the WeChat ID above',
      'Note: WeChat does not support direct deep links to chats — the app will open but you may need to search for the contact manually',
    ],
  ),
  ShortcutPlatform(
    id: 'line',
    name: 'LINE',
    description: 'Open Iris on LINE',
    iconEmoji: '🟩',
    accentColor: const Color(0xFF06C755),
    deepLinkTemplate: 'line://ti/p/{value}',
    // Universal link format with proper encoding for @ prefix IDs
    webFallbackTemplate: 'https://line.me/R/ti/p/{value}',
    configKey: 'line_id',
    configLabel: 'LINE ID',
    configHint: 'e.g. %40iris_line (use %40 for @)',
    setupSteps: [
      'Find the Iris LINE ID or @ID',
      'Enter it above (replace @ with %40 for proper URL encoding)',
      'Tap to open the LINE profile and start a chat',
    ],
  ),
  ShortcutPlatform(
    id: 'discord',
    name: 'Discord',
    description: 'Open Iris on Discord',
    iconEmoji: '🎮',
    accentColor: const Color(0xFF5865F2),
    deepLinkTemplate: 'discord://discord.gg/{value}',
    webFallbackTemplate: 'https://discord.gg/{value}',
    configKey: 'discord_invite',
    configLabel: 'Discord Invite Code',
    configHint: 'e.g. abc123xyz (the code part only)',
    setupSteps: [
      'Get the invite link from Iris Discord',
      'Copy only the code at the end (after discord.gg/)',
      'Paste above to jump directly into the server',
    ],
  ),
  ShortcutPlatform(
    id: 'slack',
    name: 'Slack',
    description: 'Open Iris on Slack',
    iconEmoji: '⚡',
    accentColor: const Color(0xFF4A154B),
    deepLinkTemplate: 'slack://channel?team={value}',
    webFallbackTemplate: 'https://{value}.slack.com',
    configKey: 'slack_workspace',
    configLabel: 'Slack Workspace',
    configHint: 'e.g. iris-team (workspace subdomain)',
    setupSteps: [
      'Get your Iris Slack workspace URL',
      'Enter the subdomain only (before .slack.com)',
      'Tap to open the workspace',
    ],
  ),
  ShortcutPlatform(
    id: 'messenger',
    name: 'Messenger',
    description: 'Open Iris on Facebook Messenger',
    iconEmoji: '💙',
    accentColor: const Color(0xFF0084FF),
    deepLinkTemplate: 'fb-messenger://user-thread/{value}',
    webFallbackTemplate: 'https://m.me/{value}',
    configKey: 'messenger_username',
    configLabel: 'Messenger Username / Page ID',
    configHint: 'e.g. iris.official',
    setupSteps: [
      'Find Iris Facebook page username',
      'Paste it above',
      'Tap to open Messenger directly',
    ],
  ),
  ShortcutPlatform(
    id: 'signal',
    name: 'Signal',
    description: 'Open Iris on Signal',
    iconEmoji: '🔒',
    accentColor: const Color(0xFF3A76F0),
    deepLinkTemplate: 'sgnl://signal.me/#p/{value}',
    webFallbackTemplate: 'https://signal.me/#p/{value}',
    configKey: 'signal_link',
    configLabel: 'Signal Link Username',
    configHint: 'e.g. iris (the part after signal.me/#p/)',
    setupSteps: [
      'Ask Iris to share their Signal link',
      'Copy the part after signal.me/#p/',
      'Paste above and tap to open Signal',
    ],
  ),
  ShortcutPlatform(
    id: 'twitter',
    name: 'X (Twitter) DM',
    description: 'Open Iris DM on X',
    iconEmoji: '𝕏',
    accentColor: const Color(0xFF000000),
    deepLinkTemplate: 'twitter://messages/compose?recipient_id={value}',
    webFallbackTemplate: 'https://x.com/messages/compose?recipient_id={value}',
    configKey: 'twitter_id',
    configLabel: 'X / Twitter User ID',
    configHint: 'e.g. 123456789 (numeric user ID)',
    setupSteps: [
      'Find Iris X/Twitter numeric user ID',
      'You can use a tool like tweeterid.com to find it',
      'Paste the numeric ID above',
      'Tap to open a DM directly',
    ],
  ),
  ShortcutPlatform(
    id: 'viber',
    name: 'Viber',
    description: 'Open Iris on Viber',
    iconEmoji: '📳',
    accentColor: const Color(0xFF7360F2),
    deepLinkTemplate: 'viber://chat?number={value}',
    webFallbackTemplate: 'viber://chat?number={value}',
    configKey: 'viber_phone',
    configLabel: 'Viber Phone Number',
    configHint: 'e.g. 15551234567 (with country code)',
    setupSteps: [
      'Get Iris Viber phone number',
      'Enter with country code, no + or spaces',
      'Tap to open Viber chat',
    ],
    isComingSoon: false,
  ),
  ShortcutPlatform(
    id: 'skype',
    name: 'Skype',
    description: 'Open Iris on Skype',
    iconEmoji: '🔵',
    accentColor: const Color(0xFF00AFF0),
    deepLinkTemplate: 'skype:{value}?chat',
    webFallbackTemplate: 'https://web.skype.com/chat?id={value}',
    configKey: 'skype_id',
    configLabel: 'Skype Name / ID',
    configHint: 'e.g. iris.chat',
    setupSteps: [
      'Find Iris Skype name',
      'Paste it above',
      'Tap to launch Skype chat',
    ],
  ),
];
