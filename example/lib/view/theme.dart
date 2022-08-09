import 'package:example/view/color.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme() => ThemeData(
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      canvasColor: backgroundColor,
      splashColor: accentColor,
      highlightColor: accentColor.withOpacity(0.7),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(accentColor.withOpacity(0.1)),
          minimumSize: MaterialStateProperty.all(Size(82, 52)),
          foregroundColor: MaterialStateProperty.all(Colors.black),
          textStyle: MaterialStateProperty.all(
            TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(accentColor.withOpacity(0.1)),
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
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
