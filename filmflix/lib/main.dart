import 'package:flutter/material.dart';
import 'views/homescreen.dart';

void main() {
  runApp(const FilmFlixApp());
}

class FilmFlixApp extends StatelessWidget {
  const FilmFlixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FilmFlix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37), // goud accent
          secondary: Color(0xFFB22222), // diep rood
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
