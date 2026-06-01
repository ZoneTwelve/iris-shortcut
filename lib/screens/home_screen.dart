// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/platforms_data.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Map<String, String> _configs = {};
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _selectedFilter = 0; // 0=All, 1=Ready, 2=Not set

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _loadConfigs();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, String> configs = {};
    for (final p in allPlatforms) {
      final val = prefs.getString(p.configKey) ?? '';
      configs[p.configKey] = val;
    }
    setState(() => _configs = configs);
  }

  List<ShortcutPlatform> get _filteredPlatforms {
    switch (_selectedFilter) {
      case 1:
        return allPlatforms.where((p) => (_configs[p.configKey] ?? '').isNotEmpty).toList();
      case 2:
        return allPlatforms.where((p) => (_configs[p.configKey] ?? '').isEmpty).toList();
      default:
        return allPlatforms;
    }
  }

  int get _configuredCount =>
      allPlatforms.where((p) => (_configs[p.configKey] ?? '').isNotEmpty).length;

  Future<void> _launchPlatform(ShortcutPlatform platform) async {
    final configVal = _configs[platform.configKey] ?? '';
    if (configVal.isEmpty) {
      _showConfigNeeded(platform);
      return;
    }

    HapticFeedback.mediumImpact();
    final deepLink = platform.buildDeepLink(configVal);
    final webLink = platform.buildWebLink(configVal);

    // Detect if running on iPad.
    // On iPad, custom URL schemes are unreliable because many messaging apps
    // run in iPhone compatibility mode. Universal Links (https://) work much
    // better on iPad as they trigger the app's AASA-based routing.
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    if (isTablet) {
      // iPad: prefer universal/web link first, then fall back to deep link
      if (webLink != null) {
        final uri = Uri.parse(webLink);
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) return;
      }
      if (deepLink != null) {
        final uri = Uri.parse(deepLink);
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) return;
      }
    } else {
      // iPhone: prefer deep link (custom scheme) first, then fall back to web
      if (deepLink != null) {
        final uri = Uri.parse(deepLink);
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) return;
      }
      if (webLink != null) {
        final uri = Uri.parse(webLink);
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) return;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open ${platform.name}'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  void _showConfigNeeded(ShortcutPlatform platform) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13131A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(platform.iconEmoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              '${platform.name} not configured',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set up your Iris ${platform.name} contact to use this shortcut.',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: platform.accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(
                        initialPlatformId: platform.id,
                        onSaved: _loadConfigs,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Configure ${platform.name}',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPlatforms;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            _buildFilterBar(),
            _buildGrid(filtered),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: _buildSettingsFAB(),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0F3A), Color(0xFF0A0A0F)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (ctx, child) => Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C6AF7), Color(0xFFB388FF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C6AF7).withOpacity(
                            0.3 + _pulseController.value * 0.4,
                          ),
                          blurRadius: 16 + _pulseController.value * 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('✦', style: TextStyle(fontSize: 24, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Iris Shortcut',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Quick access everywhere',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.white38,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13131A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          _buildStat('$_configuredCount', 'Connected', const Color(0xFF7C6AF7)),
          _divider(),
          _buildStat('${allPlatforms.length - _configuredCount}', 'Pending', Colors.white30),
          _divider(),
          _buildStat('${allPlatforms.length}', 'Total', Colors.white54),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white30),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        color: Colors.white.withOpacity(0.08),
      );

  Widget _buildFilterBar() {
    final filters = ['All', 'Ready', 'Not set'];
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        child: Row(
          children: List.generate(
            filters.length,
            (i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedFilter == i
                        ? const Color(0xFF7C6AF7)
                        : const Color(0xFF13131A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedFilter == i
                          ? const Color(0xFF7C6AF7)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Text(
                    filters[i],
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _selectedFilter == i ? Colors.white : Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<ShortcutPlatform> platforms) {
    if (platforms.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              const Text('🔍', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'No platforms match this filter',
                style: GoogleFonts.spaceGrotesk(color: Colors.white38),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) {
            final platform = platforms[i];
            final isConfigured = (_configs[platform.configKey] ?? '').isNotEmpty;
            return _PlatformCard(
              platform: platform,
              isConfigured: isConfigured,
              onTap: () => _launchPlatform(platform),
              onLongPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(
                      initialPlatformId: platform.id,
                      onSaved: _loadConfigs,
                    ),
                  ),
                );
              },
              index: i,
            );
          },
          childCount: platforms.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingsFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SettingsScreen(onSaved: _loadConfigs),
          ),
        ).then((_) => _loadConfigs());
      },
      backgroundColor: const Color(0xFF7C6AF7),
      icon: const Icon(Icons.settings_rounded, color: Colors.white),
      label: Text(
        'Configure',
        style: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _PlatformCard extends StatefulWidget {
  final ShortcutPlatform platform;
  final bool isConfigured;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final int index;

  const _PlatformCard({
    required this.platform,
    required this.isConfigured,
    required this.onTap,
    required this.onLongPress,
    required this.index,
  });

  @override
  State<_PlatformCard> createState() => _PlatformCardState();
}

class _PlatformCardState extends State<_PlatformCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _scaleController;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final platform = widget.platform;
    final color = platform.accentColor;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (ctx, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _scaleController.reverse(),
        onTapUp: (_) {
          _scaleController.forward();
          widget.onTap();
        },
        onTapCancel: () => _scaleController.forward(),
        onLongPress: widget.onLongPress,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF13131A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isConfigured
                  ? color.withOpacity(0.4)
                  : Colors.white.withOpacity(0.06),
              width: widget.isConfigured ? 1.5 : 1,
            ),
            boxShadow: widget.isConfigured
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 0,
                    )
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Glow background
              if (widget.isConfigured)
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.08),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          platform.iconEmoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.isConfigured
                                ? const Color(0xFF4CAF50)
                                : Colors.white12,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          platform.name,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.isConfigured ? 'Ready · Tap to open' : 'Tap to configure',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            color: widget.isConfigured
                                ? color.withOpacity(0.8)
                                : Colors.white30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
