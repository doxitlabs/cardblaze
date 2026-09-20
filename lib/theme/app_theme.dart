import 'package:flutter/material.dart';

// ── Dark tokens ──────────────────────────────────────────────────────────────

class DarkColors {
  static const Color pageBg        = Color(0xFF0D0D0D);
  static const Color surface       = Color(0xFF1A1F2E);
  static const Color surface2      = Color(0xFF222838);
  static const Color border        = Color(0xFF2A3245);
  static const Color accent        = Color(0xFF4A9EFF);
  static const Color accentBg      = Color(0xFF1E2D4A);
  static const Color accentIcon    = Color(0xFF3A7FD4);
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A9BB8);
  static const Color textMuted     = Color(0xFF5A6A80);
  static const Color badgeRed      = Color(0xFFC62828);
  static const Color badgeOrange   = Color(0xFFE65100);
  static const Color badgeGreen    = Color(0xFF2E7D32);
  static const Color badgeBlue     = Color(0xFF1565C0);
  static const Color purple        = Color(0xFF6B4FA0);
  static const Color purpleBg      = Color(0xFF1E1630);
  static const Color warningBg     = Color(0xFF2A1F00);
}

// ── Light tokens ─────────────────────────────────────────────────────────────

class LightColors {
  static const Color pageBg        = Color(0xFFF5F7FA);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color surface2      = Color(0xFFF0F3F8);
  static const Color border        = Color(0xFFE0E6F0);
  static const Color accent        = Color(0xFF1E6DD4);
  static const Color accentBg      = Color(0xFFEBF3FF);
  static const Color accentIcon    = Color(0xFF3A7FD4);
  static const Color textPrimary   = Color(0xFF0D1117);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textMuted     = Color(0xFF8A9BB8);
  static const Color badgeRed      = Color(0xFFD32F2F);
  static const Color badgeOrange   = Color(0xFFE64A19);
  static const Color badgeGreen    = Color(0xFF388E3C);
  static const Color badgeBlue     = Color(0xFF1976D2);
  static const Color purple        = Color(0xFF7B4FA0);
  static const Color purpleBg      = Color(0xFFF3EEFF);
  static const Color warningBg     = Color(0xFFFFF3E0);
}

// ── Convenience alias resolved at runtime ────────────────────────────────────

abstract class AppColors {
  static Color of(BuildContext context, {
    required Color dark,
    required Color light,
  }) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  static Color pageBg(BuildContext context)        => of(context, dark: DarkColors.pageBg,        light: LightColors.pageBg);
  static Color surface(BuildContext context)       => of(context, dark: DarkColors.surface,       light: LightColors.surface);
  static Color surface2(BuildContext context)      => of(context, dark: DarkColors.surface2,      light: LightColors.surface2);
  static Color border(BuildContext context)        => of(context, dark: DarkColors.border,        light: LightColors.border);
  static Color accent(BuildContext context)        => of(context, dark: DarkColors.accent,        light: LightColors.accent);
  static Color accentBg(BuildContext context)      => of(context, dark: DarkColors.accentBg,      light: LightColors.accentBg);
  static Color accentIcon(BuildContext context)    => of(context, dark: DarkColors.accentIcon,    light: LightColors.accentIcon);
  static Color textPrimary(BuildContext context)   => of(context, dark: DarkColors.textPrimary,   light: LightColors.textPrimary);
  static Color textSecondary(BuildContext context) => of(context, dark: DarkColors.textSecondary, light: LightColors.textSecondary);
  static Color textMuted(BuildContext context)     => of(context, dark: DarkColors.textMuted,     light: LightColors.textMuted);
  static Color badgeRed(BuildContext context)      => of(context, dark: DarkColors.badgeRed,      light: LightColors.badgeRed);
  static Color badgeOrange(BuildContext context)   => of(context, dark: DarkColors.badgeOrange,   light: LightColors.badgeOrange);
  static Color badgeGreen(BuildContext context)    => of(context, dark: DarkColors.badgeGreen,    light: LightColors.badgeGreen);
  static Color badgeBlue(BuildContext context)     => of(context, dark: DarkColors.badgeBlue,     light: LightColors.badgeBlue);
  static Color purple(BuildContext context)        => of(context, dark: DarkColors.purple,        light: LightColors.purple);
  static Color purpleBg(BuildContext context)      => of(context, dark: DarkColors.purpleBg,      light: LightColors.purpleBg);
  static Color warningBg(BuildContext context)     => of(context, dark: DarkColors.warningBg,     light: LightColors.warningBg);
}

// ── Theme builder ─────────────────────────────────────────────────────────────

class AppTheme {
  static ThemeData get darkTheme  => _build(Brightness.dark);
  static ThemeData get lightTheme => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final _ColorRef c = isDark ? _DarkRef() : _LightRef();

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: Colors.white,
      primaryContainer: c.accentBg,
      onPrimaryContainer: c.accent,
      secondary: c.purple,
      onSecondary: Colors.white,
      secondaryContainer: c.purpleBg,
      onSecondaryContainer: c.purple,
      error: c.badgeRed,
      onError: Colors.white,
      surface: c.surface,
      onSurface: c.textPrimary,
      surfaceContainerHighest: c.surface2,
      outline: c.border,
      outlineVariant: c.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.pageBg,
      cardColor: c.surface,
      dividerColor: c.border,

      // ── AppBar ──────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: c.pageBg,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: c.textPrimary),
        titleTextStyle: TextStyle(
          color: c.textPrimary,
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),

      // ── Bottom nav ──────────────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surface2,
        selectedItemColor: c.accent,
        unselectedItemColor: c.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface2,
        indicatorColor: c.accentBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: c.accent);
          }
          return IconThemeData(color: c.textMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: c.accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            );
          }
          return TextStyle(
            color: c.textMuted,
            fontSize: 12,
            fontFamily: 'Roboto',
          );
        }),
      ),

      // ── Text ────────────────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: c.textPrimary, fontFamily: 'Roboto',
          fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: c.textPrimary, fontFamily: 'Roboto',
          fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          color: c.textPrimary, fontFamily: 'Roboto',
          fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: c.textPrimary, fontFamily: 'Roboto',
          fontSize: 16, fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: c.textSecondary, fontFamily: 'Roboto',
          fontSize: 14, fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: c.textPrimary, fontFamily: 'Roboto', fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: c.textSecondary, fontFamily: 'Roboto', fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: c.textMuted, fontFamily: 'Roboto', fontSize: 12,
        ),
        labelLarge: TextStyle(
          color: c.textPrimary, fontFamily: 'Roboto',
          fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          color: c.textSecondary, fontFamily: 'Roboto',
          fontSize: 12, fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: c.textMuted, fontFamily: 'Roboto',
          fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.3,
        ),
      ),

      // ── Card ────────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: c.border),
        ),
      ),

      // ── Input ───────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.badgeRed),
        ),
        hintStyle: TextStyle(color: c.textMuted, fontSize: 14),
        labelStyle: TextStyle(color: c.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // ── Elevated button ─────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: c.surface2,
          disabledForegroundColor: c.textMuted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // ── Outlined button ─────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.accent,
          side: BorderSide(color: c.border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Text button ──────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── FAB ─────────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── Chip ────────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: c.surface2,
        selectedColor: c.accentBg,
        labelStyle: TextStyle(
          color: c.textSecondary,
          fontSize: 13,
          fontFamily: 'Roboto',
        ),
        side: BorderSide(color: c.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),

      // ── Dialog ──────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: c.border),
        ),
        titleTextStyle: TextStyle(
          color: c.textPrimary,
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(
          color: c.textSecondary,
          fontFamily: 'Roboto',
          fontSize: 14,
        ),
      ),

      // ── SnackBar ─────────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surface2,
        contentTextStyle: TextStyle(
          color: c.textPrimary,
          fontFamily: 'Roboto',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // ── ListTile ─────────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: c.accentIcon,
        textColor: c.textPrimary,
        subtitleTextStyle: TextStyle(
          color: c.textSecondary,
          fontSize: 13,
          fontFamily: 'Roboto',
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // ── Switch / Checkbox / Radio ────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return c.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.accent;
          return c.surface2;
        }),
        trackOutlineColor: WidgetStateProperty.all(c.border),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.accent;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: c.border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // ── Divider ───────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: c.border,
        thickness: 1,
        space: 1,
      ),

      // ── Progress indicator ────────────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.accent,
        linearTrackColor: c.surface2,
        circularTrackColor: c.surface2,
      ),

      // ── Tab bar ───────────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: c.accent,
        unselectedLabelColor: c.textMuted,
        indicatorColor: c.accent,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
        ),
        dividerColor: Colors.transparent,
      ),

      // ── Popup menu ────────────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: c.border),
        ),
        textStyle: TextStyle(
          color: c.textPrimary,
          fontFamily: 'Roboto',
          fontSize: 14,
        ),
      ),
    );
  }
}

// ── Internal color reference ─────────────────────────────────────────────────

abstract class _ColorRef {
  Color get pageBg;
  Color get surface;
  Color get surface2;
  Color get border;
  Color get accent;
  Color get accentBg;
  Color get accentIcon;
  Color get textPrimary;
  Color get textSecondary;
  Color get textMuted;
  Color get badgeRed;
  Color get badgeOrange;
  Color get badgeGreen;
  Color get badgeBlue;
  Color get purple;
  Color get purpleBg;
  Color get warningBg;
}

class _DarkRef implements _ColorRef {
  @override Color get pageBg        => DarkColors.pageBg;
  @override Color get surface       => DarkColors.surface;
  @override Color get surface2      => DarkColors.surface2;
  @override Color get border        => DarkColors.border;
  @override Color get accent        => DarkColors.accent;
  @override Color get accentBg      => DarkColors.accentBg;
  @override Color get accentIcon    => DarkColors.accentIcon;
  @override Color get textPrimary   => DarkColors.textPrimary;
  @override Color get textSecondary => DarkColors.textSecondary;
  @override Color get textMuted     => DarkColors.textMuted;
  @override Color get badgeRed      => DarkColors.badgeRed;
  @override Color get badgeOrange   => DarkColors.badgeOrange;
  @override Color get badgeGreen    => DarkColors.badgeGreen;
  @override Color get badgeBlue     => DarkColors.badgeBlue;
  @override Color get purple        => DarkColors.purple;
  @override Color get purpleBg      => DarkColors.purpleBg;
  @override Color get warningBg     => DarkColors.warningBg;
}

class _LightRef implements _ColorRef {
  @override Color get pageBg        => LightColors.pageBg;
  @override Color get surface       => LightColors.surface;
  @override Color get surface2      => LightColors.surface2;
  @override Color get border        => LightColors.border;
  @override Color get accent        => LightColors.accent;
  @override Color get accentBg      => LightColors.accentBg;
  @override Color get accentIcon    => LightColors.accentIcon;
  @override Color get textPrimary   => LightColors.textPrimary;
  @override Color get textSecondary => LightColors.textSecondary;
  @override Color get textMuted     => LightColors.textMuted;
  @override Color get badgeRed      => LightColors.badgeRed;
  @override Color get badgeOrange   => LightColors.badgeOrange;
  @override Color get badgeGreen    => LightColors.badgeGreen;
  @override Color get badgeBlue     => LightColors.badgeBlue;
  @override Color get purple        => LightColors.purple;
  @override Color get purpleBg      => LightColors.purpleBg;
  @override Color get warningBg     => LightColors.warningBg;
}
