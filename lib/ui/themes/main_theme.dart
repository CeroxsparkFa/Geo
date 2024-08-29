
import 'package:flutter/material.dart';

class MainTheme {
  static const primaryColor = Color.fromARGB(255, 188, 32, 46);
  static const secondaryColor = Color.fromARGB(255, 30, 55, 71);
  static const tertiaryColor = Color.fromARGB(255, 30, 110, 142);
  static const surfaceColor = Color.fromARGB(255, 226, 231, 233);

  static ThemeData getTheme() {
    return ThemeData(
      splashColor: tertiaryColor.withOpacity(0.1),
      highlightColor: tertiaryColor.withOpacity(0.1),
      dividerTheme: DividerThemeData(
        color: secondaryColor.withOpacity(0.1)
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: tertiaryColor
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tertiaryColor,
          overlayColor: tertiaryColor
        )
      ),
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        primary: primaryColor,
        tertiary: tertiaryColor,
        surface: surfaceColor,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: surfaceColor
      ),
      appBarTheme: const AppBarTheme(
        foregroundColor: surfaceColor,
        iconTheme: IconThemeData(
          color: surfaceColor
        ),
        backgroundColor: primaryColor,
      ),
      navigationBarTheme: NavigationBarThemeData(
        iconTheme: WidgetStateProperty.all(const IconThemeData(color: secondaryColor)),
        indicatorColor: tertiaryColor.withOpacity(0.2),
        backgroundColor: surfaceColor,
        labelTextStyle: WidgetStateProperty.all(const TextStyle(color: secondaryColor))
      ),
      scaffoldBackgroundColor: surfaceColor,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(
            surfaceColor
          ),
          backgroundColor: WidgetStateProperty.all(
            tertiaryColor
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: secondaryColor.withOpacity(0.5)
        ),
        counterStyle: const TextStyle(color: primaryColor),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: secondaryColor)
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: tertiaryColor,
            width: 2.0
            )
        ),
        labelStyle: const TextStyle(
          color: secondaryColor
        ),
        floatingLabelStyle: const TextStyle(
          color: tertiaryColor
        ),
        iconColor: secondaryColor,
        suffixIconColor: secondaryColor
      )
    );
  }
}