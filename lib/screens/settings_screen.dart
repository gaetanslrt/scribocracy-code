import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribocracy_new/theme.dart';
import 'package:scribocracy_new/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Récupération du mode sombre
    final isDark = ref.watch(darkModeProvider);

    // 2. Définition des couleurs via AppTheme
    final Color bgColor = isDark
        ? AppTheme.darkBackground
        : AppTheme.lightBackground;
    final Color surfaceColor = isDark
        ? AppTheme.darkSurface
        : AppTheme.lightSurface;
    final Color textColor = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.lightTextPrimary;
    final Color secondaryTextColor = isDark
        ? AppTheme.darkTextSecondary
        : AppTheme.lightTextSecondary;
    final Color borderColor = isDark
        ? AppTheme.darkBorder
        : AppTheme.lightBorder;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Paramètres",
          style: TextStyle(
            color: textColor,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // --- SECTION 1 : RECHERCHE ---
          _SectionTitle(
            title: "MOTEUR DE RECHERCHE",
            color: AppTheme.asterBlue,
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Column(
              children: [
                _SearchEngineTile(
                  title: "Google",
                  value: "google",
                  icon: Icons.search,
                  isDark: isDark,
                  textColor: textColor,
                  divider: true,
                  borderColor: borderColor,
                ),
                _SearchEngineTile(
                  title: "Bing",
                  value: "bing",
                  icon: Icons.public,
                  isDark: isDark,
                  textColor: textColor,
                  divider: true,
                  borderColor: borderColor,
                ),
                _SearchEngineTile(
                  title: "DuckDuckGo",
                  value: "ddg",
                  icon: Icons.shield_outlined,
                  isDark: isDark,
                  textColor: textColor,
                  divider: false,
                  borderColor: borderColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // --- SECTION 2 : APPARENCE ---
          _SectionTitle(title: "APPARENCE", color: AppTheme.habanero),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              title: Text(
                "Mode Sombre",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                "Reposez vos yeux la nuit",
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
              ),
              activeColor: AppTheme.habanero,
              activeTrackColor: AppTheme.habanero.withOpacity(0.3),
              inactiveThumbColor: secondaryTextColor,
              inactiveTrackColor: isDark ? Colors.black26 : Colors.black12,
              value: isDark,
              onChanged: (val) {
                ref.read(darkModeProvider.notifier).state = val;
              },
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDark ? Icons.dark_mode : Icons.dark_mode_outlined,
                  color: textColor,
                  size: 20,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // --- SECTION 3 : À PROPOS ---
          _SectionTitle(title: "À PROPOS", color: AppTheme.greyText),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Column(
              children: [
                Text(
                  "Scribocracy Browser",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Version 1.0.0 (Zen Edition)",
                  style: TextStyle(fontSize: 12, color: secondaryTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS AUXILIAIRES ---

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}

class _SearchEngineTile extends ConsumerWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isDark;
  final Color textColor;
  final bool divider;
  final Color borderColor;

  const _SearchEngineTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.isDark,
    required this.textColor,
    required this.divider,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentEngine = ref.watch(searchEngineProvider);
    final isSelected = currentEngine == value;

    return Column(
      children: [
        ListTile(
          onTap: () {
            ref.read(searchEngineProvider.notifier).state = value;
          },
          leading: Icon(
            icon,
            color: isSelected ? AppTheme.asterBlue : AppTheme.greyText,
            size: 22,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
          trailing: isSelected
              ? const Icon(
                  Icons.check_circle,
                  color: AppTheme.asterBlue,
                  size: 20,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        if (divider) Divider(height: 1, color: borderColor),
      ],
    );
  }
}
