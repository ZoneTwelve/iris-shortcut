// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/platforms_data.dart';

class SettingsScreen extends StatefulWidget {
  final String? initialPlatformId;
  final VoidCallback? onSaved;

  const SettingsScreen({
    super.key,
    this.initialPlatformId,
    this.onSaved,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _saving = {};
  String? _expandedId;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    for (final p in allPlatforms) {
      _controllers[p.configKey] = TextEditingController();
    }
    _loadConfigs();
    _fadeController.forward();

    if (widget.initialPlatformId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _expandedId = widget.initialPlatformId);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    for (final p in allPlatforms) {
      _controllers[p.configKey]?.text = prefs.getString(p.configKey) ?? '';
    }
    setState(() {});
  }

  Future<void> _savePlatform(ShortcutPlatform platform) async {
    setState(() => _saving[platform.id] = true);
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    final val = _controllers[platform.configKey]?.text.trim() ?? '';
    await prefs.setString(platform.configKey, val);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() => _saving[platform.id] = false);
      widget.onSaved?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
              const SizedBox(width: 8),
              Text(
                '${platform.name} saved!',
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E1E2E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearPlatform(ShortcutPlatform platform) async {
    _controllers[platform.configKey]?.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(platform.configKey);
    if (mounted) {
      setState(() {});
      widget.onSaved?.call();
    }
  }

  int get _configuredCount {
    int count = 0;
    for (final p in allPlatforms) {
      if ((_controllers[p.configKey]?.text ?? '').isNotEmpty) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildProgressBanner(),
            _buildPlatformList(),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: const Color(0xFF0A0A0F),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(60, 0, 16, 16),
        title: Text(
          'Configure Iris',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A0F3A), Color(0xFF0A0A0F)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBanner() {
    final total = allPlatforms.length;
    final done = _configuredCount;
    final pct = done / total;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1040), Color(0xFF13131A)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF7C6AF7).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$done of $total configured',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${(pct * 100).round()}%',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF7C6AF7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF7C6AF7)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Long-press any card on home screen to edit · Tap below to expand',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  color: Colors.white30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) {
          final platform = allPlatforms[i];
          final isConfigured =
              (_controllers[platform.configKey]?.text ?? '').isNotEmpty;
          final isExpanded = _expandedId == platform.id;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: _PlatformTile(
              platform: platform,
              controller: _controllers[platform.configKey]!,
              isConfigured: isConfigured,
              isExpanded: isExpanded,
              isSaving: _saving[platform.id] ?? false,
              onToggle: () {
                setState(() {
                  _expandedId = isExpanded ? null : platform.id;
                });
              },
              onSave: () => _savePlatform(platform),
              onClear: isConfigured ? () => _clearPlatform(platform) : null,
              onChanged: () => setState(() {}),
            ),
          );
        },
        childCount: allPlatforms.length,
      ),
    );
  }
}

class _PlatformTile extends StatelessWidget {
  final ShortcutPlatform platform;
  final TextEditingController controller;
  final bool isConfigured;
  final bool isExpanded;
  final bool isSaving;
  final VoidCallback onToggle;
  final VoidCallback onSave;
  final VoidCallback? onClear;
  final VoidCallback onChanged;

  const _PlatformTile({
    required this.platform,
    required this.controller,
    required this.isConfigured,
    required this.isExpanded,
    required this.isSaving,
    required this.onToggle,
    required this.onSave,
    this.onClear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = platform.accentColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: const Color(0xFF13131A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpanded
              ? color.withOpacity(0.5)
              : isConfigured
                  ? color.withOpacity(0.25)
                  : Colors.white.withOpacity(0.06),
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: color.withOpacity(0.12),
                  blurRadius: 24,
                  spreadRadius: 0,
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        platform.iconEmoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
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
                        Text(
                          isConfigured
                              ? '✓ ${controller.text}'
                              : platform.configLabel,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: isConfigured
                                ? color.withOpacity(0.8)
                                : Colors.white30,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isConfigured
                              ? const Color(0xFF4CAF50)
                              : Colors.white12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white38,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expandable body
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _buildExpandedBody(color),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedBody(Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.white.withOpacity(0.07)),
          const SizedBox(height: 8),
          // Setup steps
          ...platform.setupSteps.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.value,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: Colors.white54,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 14),
          // Input field
          TextField(
            controller: controller,
            onChanged: (_) => onChanged(),
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: platform.configHint,
              hintStyle: GoogleFonts.spaceGrotesk(
                color: Colors.white24,
                fontSize: 13,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color.withOpacity(0.6)),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded,
                          size: 16, color: Colors.white30),
                      onPressed: () {
                        controller.clear();
                        onChanged();
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          // Save / Clear buttons
          Row(
            children: [
              if (onClear != null) ...[
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: onClear,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white38,
                      side: const BorderSide(color: Colors.white12),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Clear',
                      style: GoogleFonts.spaceGrotesk(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: isSaving ? null : onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Save',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
