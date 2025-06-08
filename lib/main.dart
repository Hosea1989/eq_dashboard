import 'package:flutter/cupertino.dart';
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
    
    return CupertinoApp(
      title: 'Equilibrium Dashboard',
      theme: CupertinoThemeData(
        primaryColor: themeData.primaryColor,
        primaryContrastingColor: CupertinoColors.white,
        scaffoldBackgroundColor: themeData.backgroundColor,
        barBackgroundColor: themeData.primaryColor,
        textTheme: CupertinoTextThemeData(
          primaryColor: themeData.textPrimary,
          textStyle: TextStyle(
            color: themeData.textPrimary,
            fontSize: 16,
          ),
          navTitleTextStyle: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          navLargeTitleTextStyle: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        brightness: Brightness.light,
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
