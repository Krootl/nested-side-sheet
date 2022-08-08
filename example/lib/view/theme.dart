import 'package:example/view/color.dart';
import 'package:flutter/material.dart';

ThemeData darkTheme() => ThemeData(
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      canvasColor: backgroundColor,
      splashColor: accentColor,
      highlightColor: accentColor.withOpacity(0.7),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(82, 52)),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          textStyle: MaterialStateProperty.all(
            TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(82, 52)),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          backgroundColor: MaterialStateProperty.all(accentColor),
          textStyle: MaterialStateProperty.all(
            TextStyle(fontWeight: FontWeight.w600),
          ),
          elevation: MaterialStateProperty.all(4),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
