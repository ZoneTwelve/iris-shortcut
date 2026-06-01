# ✦ Iris Shortcut

A Flutter app that gives you **one-tap access to Iris** across all your messaging platforms.

---

## 📱 Features

- **12 platforms supported**: Telegram, Instagram, WhatsApp, WeChat, LINE, Discord, Slack, Messenger, Signal, X/Twitter DM, Viber, Skype
- **Smart deep links**: Opens the native app directly if installed, falls back to web
- **Status indicators**: Green dot shows which platforms are configured and ready
- **Filter view**: Show All / Ready / Not set
- **Settings page**: Step-by-step setup guide per platform, save/clear per entry
- **Progress tracker**: See how many platforms you've connected
- **Long-press shortcut**: Long-press any home card to jump straight to that platform's settings

---

## 🚀 Getting Started

### 1. Install dependencies
```bash
cd iris_shortcut
flutter pub get
```

### 2. Run the app
```bash
flutter run
```

### 3. Configure platforms
Open the **Configure** button (bottom right), expand any platform, follow the steps, and save.

---

## 🔗 Platform Deep Links

| Platform   | Deep Link Scheme         | Fallback                         |
|------------|--------------------------|----------------------------------|
| Telegram   | `tg://resolve?domain=`   | `https://t.me/{username}`        |
| Instagram  | `instagram://user?username=` | `https://instagram.com/{user}` |
| WhatsApp   | `whatsapp://send?phone=` | `https://wa.me/{phone}`          |
| WeChat     | `weixin://dl/chat?`      | `https://weixin.qq.com/r/{id}`   |
| LINE       | `line://ti/p/`           | `https://line.me/ti/p/{id}`      |
| Discord    | `discord://discord.gg/`  | `https://discord.gg/{code}`      |
| Slack      | `slack://channel?team=`  | `https://{workspace}.slack.com`  |
| Messenger  | `fb-messenger://user-thread/` | `https://m.me/{username}`   |
| Signal     | `sgnl://signal.me/#p/`   | `https://signal.me/#p/{user}`    |
| X/Twitter  | `twitter://messages/compose?recipient_id=` | `https://x.com/messages/compose?recipient_id=` |
| Viber      | `viber://chat?number=`   | same                             |
| Skype      | `skype:{id}?chat`        | `https://web.skype.com/chat?id=` |

---

## 📦 Dependencies

```yaml
url_launcher: ^6.2.5         # Launch deep links & web URLs
shared_preferences: ^2.2.2   # Persist platform configs
google_fonts: ^6.1.0         # Space Grotesk typography
gap: ^3.0.1                  # Spacing utility
animated_text_kit: ^4.2.2    # Text animations
```

---

## 📂 Project Structure

```
lib/
├── main.dart                   # App entry point & theme
├── models/
│   └── platforms_data.dart     # All platform definitions & deep link templates
└── screens/
    ├── home_screen.dart        # Shortcut grid with filter & stats
    └── settings_screen.dart    # Configure each platform with guided steps
```

---

## ➕ Adding a New Platform

In `lib/models/platforms_data.dart`, add a new `ShortcutPlatform` entry to the `allPlatforms` list:

```dart
ShortcutPlatform(
  id: 'myapp',
  name: 'My App',
  description: 'Open Iris on My App',
  iconEmoji: '🟣',
  accentColor: const Color(0xFF9C27B0),
  deepLinkTemplate: 'myapp://chat/{value}',
  webFallbackTemplate: 'https://myapp.com/u/{value}',
  configKey: 'myapp_username',
  configLabel: 'My App Username',
  configHint: 'e.g. iris_user',
  setupSteps: [
    'Find Iris on My App',
    'Copy the username',
    'Paste above and save',
  ],
),
```

No other code changes needed — the home screen and settings screen pick it up automatically.

---

## 📋 Android Setup

The `AndroidManifest.xml` includes `<queries>` entries for all 12 app packages and URI schemes. This is required on Android 11+ for `canLaunchUrl()` to work correctly.

## 🍎 iOS Setup

In `ios/Runner/Info.plist`, add:
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>tg</string>
  <string>instagram</string>
  <string>whatsapp</string>
  <string>weixin</string>
  <string>line</string>
  <string>discord</string>
  <string>slack</string>
  <string>fb-messenger</string>
  <string>sgnl</string>
  <string>twitter</string>
  <string>viber</string>
  <string>skype</string>
</array>
```
