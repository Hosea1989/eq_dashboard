import 'package:flutter/material.dart';
import 'screens/screens.dart';
import 'utils/theme_manager.dart';

void main() {
  runApp(const BudgetApp());
}

class BudgetApp extends StatefulWidget {
  const BudgetApp({super.key});

  @override
  State<BudgetApp> createState() => _BudgetAppState();
}

class _BudgetAppState extends State<BudgetApp> {
  @override
  Widget build(BuildContext context) {
    final themeData = AppThemeManager.themeData;
    
    return MaterialApp(
      title: 'Neurodivergent-Friendly Budget Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeData.primaryColor,
          brightness: Brightness.light,
          primary: themeData.primaryColor,
          secondary: themeData.secondaryColor,
          surface: themeData.surfaceColor,
          background: themeData.backgroundColor,
          error: themeData.errorColor,
        ),
        useMaterial3: true,
        
        // Accessibility improvements
        visualDensity: VisualDensity.adaptivePlatformDensity,
        
        // Card theme
        cardTheme: CardThemeData(
          color: themeData.cardColor,
          elevation: themeData.elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(themeData.borderRadius),
            side: BorderSide(color: themeData.borderColor, width: 1),
          ),
        ),
        
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: themeData.surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(themeData.borderRadius),
            borderSide: BorderSide(color: themeData.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(themeData.borderRadius),
            borderSide: BorderSide(color: themeData.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(themeData.borderRadius),
            borderSide: BorderSide(color: themeData.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(themeData.borderRadius),
            borderSide: BorderSide(color: themeData.errorColor),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        
        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeData.primaryColor,
            foregroundColor: Colors.white,
            elevation: themeData.elevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(themeData.borderRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Text theme with better readability
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            color: themeData.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
          headlineMedium: TextStyle(
            color: themeData.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
          headlineSmall: TextStyle(
            color: themeData.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          bodyLarge: TextStyle(
            color: themeData.textPrimary,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: themeData.textPrimary,
            fontSize: 14,
          ),
          bodySmall: TextStyle(
            color: themeData.textSecondary,
            fontSize: 12,
          ),
        ),
        
        // App bar theme
        appBarTheme: AppBarTheme(
          backgroundColor: themeData.primaryColor,
          foregroundColor: Colors.white,
          elevation: themeData.elevation,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // Floating action button theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: themeData.primaryColor,
          foregroundColor: Colors.white,
          elevation: themeData.elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(themeData.borderRadius),
          ),
        ),
        
        // Snackbar theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: themeData.primaryColor,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(themeData.borderRadius),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
      
      // Accessibility settings
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // Ensure text scaling doesn't break layout
            textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.4),
          ),
          child: child!,
        );
      },
    );
  }
}
