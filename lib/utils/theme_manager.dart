import 'package:flutter/material.dart';

enum AppThemeType {
  lowStim,
  highContrast,
  softColors,
  standard
}

class AppThemeManager {
  static AppThemeType _currentTheme = AppThemeType.standard;
  
  static AppThemeType get currentTheme => _currentTheme;
  
  static void setTheme(AppThemeType theme) {
    _currentTheme = theme;
  }
  
  static AppThemeData get themeData {
    switch (_currentTheme) {
      case AppThemeType.lowStim:
        return _lowStimTheme;
      case AppThemeType.highContrast:
        return _highContrastTheme;
      case AppThemeType.softColors:
        return _softColorsTheme;
      case AppThemeType.standard:
        return _standardTheme;
    }
  }
  
  static String getThemeName(AppThemeType theme) {
    switch (theme) {
      case AppThemeType.lowStim:
        return 'Low Stim';
      case AppThemeType.highContrast:
        return 'High Contrast';
      case AppThemeType.softColors:
        return 'Soft Colors';
      case AppThemeType.standard:
        return 'Standard';
    }
  }
  
  static String getThemeDescription(AppThemeType theme) {
    switch (theme) {
      case AppThemeType.lowStim:
        return 'Minimal colors, reduced visual noise';
      case AppThemeType.highContrast:
        return 'Bold colors for better visibility';
      case AppThemeType.softColors:
        return 'Gentle, calming color palette';
      case AppThemeType.standard:
        return 'Default colorful theme';
    }
  }
}

class AppThemeData {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color successColor;
  final Color warningColor;
  final Color errorColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color cardColor;
  final Color borderColor;
  final double borderRadius;
  final double elevation;
  final bool useGradients;
  final bool useAnimations;
  
  const AppThemeData({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.successColor,
    required this.warningColor,
    required this.errorColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.cardColor,
    required this.borderColor,
    this.borderRadius = 12.0,
    this.elevation = 2.0,
    this.useGradients = true,
    this.useAnimations = true,
  });
}

// Low Stim Theme - Minimal, calm colors
const AppThemeData _lowStimTheme = AppThemeData(
  primaryColor: Color(0xFF6B7280), // Neutral gray
  secondaryColor: Color(0xFF9CA3AF),
  backgroundColor: Color(0xFFF9FAFB),
  surfaceColor: Color(0xFFFFFFFF),
  successColor: Color(0xFF10B981),
  warningColor: Color(0xFFF59E0B),
  errorColor: Color(0xFFEF4444),
  textPrimary: Color(0xFF111827),
  textSecondary: Color(0xFF6B7280),
  cardColor: Color(0xFFFFFFFF),
  borderColor: Color(0xFFE5E7EB),
  borderRadius: 8.0,
  elevation: 1.0,
  useGradients: false,
  useAnimations: false,
);

// High Contrast Theme - Bold, clear colors
const AppThemeData _highContrastTheme = AppThemeData(
  primaryColor: Color(0xFF000000),
  secondaryColor: Color(0xFF1F2937),
  backgroundColor: Color(0xFFFFFFFF),
  surfaceColor: Color(0xFFF3F4F6),
  successColor: Color(0xFF059669),
  warningColor: Color(0xFFD97706),
  errorColor: Color(0xFFDC2626),
  textPrimary: Color(0xFF000000),
  textSecondary: Color(0xFF374151),
  cardColor: Color(0xFFFFFFFF),
  borderColor: Color(0xFF000000),
  borderRadius: 4.0,
  elevation: 4.0,
  useGradients: false,
  useAnimations: true,
);

// Soft Colors Theme - Gentle, pastel colors
const AppThemeData _softColorsTheme = AppThemeData(
  primaryColor: Color(0xFF8B5CF6), // Soft purple
  secondaryColor: Color(0xFFA78BFA),
  backgroundColor: Color(0xFFFAF5FF),
  surfaceColor: Color(0xFFFFFFFF),
  successColor: Color(0xFF34D399),
  warningColor: Color(0xFFFBBF24),
  errorColor: Color(0xFFF87171),
  textPrimary: Color(0xFF1F2937),
  textSecondary: Color(0xFF6B7280),
  cardColor: Color(0xFFFFFFFF),
  borderColor: Color(0xFFE5E7EB),
  borderRadius: 16.0,
  elevation: 2.0,
  useGradients: true,
  useAnimations: true,
);

// Standard Theme - Original colorful theme
const AppThemeData _standardTheme = AppThemeData(
  primaryColor: Color(0xFF2E7D32),
  secondaryColor: Color(0xFF388E3C),
  backgroundColor: Color(0xFFF1F8E9),
  surfaceColor: Color(0xFFFFFFFF),
  successColor: Color(0xFF4CAF50),
  warningColor: Color(0xFFFF9800),
  errorColor: Color(0xFFF44336),
  textPrimary: Color(0xFF212121),
  textSecondary: Color(0xFF757575),
  cardColor: Color(0xFFFFFFFF),
  borderColor: Color(0xFFE0E0E0),
  borderRadius: 12.0,
  elevation: 2.0,
  useGradients: true,
  useAnimations: true,
);

// Category colors for different themes
class CategoryColors {
  static Map<String, Color> getColors(AppThemeType theme) {
    switch (theme) {
      case AppThemeType.lowStim:
        return {
          'Food': const Color(0xFF9CA3AF),
          'Transport': const Color(0xFF6B7280),
          'Bills': const Color(0xFF4B5563),
          'Entertainment': const Color(0xFF374151),
          'Shopping': const Color(0xFF9CA3AF),
          'Health': const Color(0xFF6B7280),
          'Other': const Color(0xFF4B5563),
        };
      case AppThemeType.highContrast:
        return {
          'Food': const Color(0xFF000000),
          'Transport': const Color(0xFF1F2937),
          'Bills': const Color(0xFF374151),
          'Entertainment': const Color(0xFF4B5563),
          'Shopping': const Color(0xFF6B7280),
          'Health': const Color(0xFF9CA3AF),
          'Other': const Color(0xFF000000),
        };
      case AppThemeType.softColors:
        return {
          'Food': const Color(0xFFFBBF24),
          'Transport': const Color(0xFF34D399),
          'Bills': const Color(0xFF60A5FA),
          'Entertainment': const Color(0xFFF87171),
          'Shopping': const Color(0xFFA78BFA),
          'Health': const Color(0xFF4ADE80),
          'Other': const Color(0xFF94A3B8),
        };
      case AppThemeType.standard:
        return {
          'Food': const Color(0xFF4CAF50),
          'Transport': const Color(0xFF2196F3),
          'Bills': const Color(0xFFFF9800),
          'Entertainment': const Color(0xFFE91E63),
          'Shopping': const Color(0xFF9C27B0),
          'Health': const Color(0xFF00BCD4),
          'Other': const Color(0xFF607D8B),
        };
    }
  }
} 