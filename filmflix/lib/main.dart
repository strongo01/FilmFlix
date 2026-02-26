import 'package:cinetrackr/firebase_options.dart';
import 'package:cinetrackr/views/movie_detail_screen.dart';
import 'package:cinetrackr/views/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'views/homescreen.dart';
import 'views/loginscreen.dart';
import 'views/foodscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CineTrackrApp());
}

class CineTrackrApp extends StatelessWidget {
  const CineTrackrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineTrackr',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37), // goud accent
          secondary: Color(0xFFB22222), // diep rood
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFD4AF37), // goud accent
          secondary: Color(0xFFB22222), // diep rood
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      routes: { // We definiëren de routes van de app, waarbij we elke route koppelen aan een specifieke widget die moet worden weergegeven wanneer die route wordt genavigeerd. In dit geval hebben we routes voor de login pagina, de home pagina, en de zoekpagina. Door deze routes te definiëren, kunnen we gemakkelijk navigeren tussen verschillende schermen in de app door gebruik te maken van Navigator.pushNamed(context, '/routeName').
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/search': (context) => const SearchScreen(),
        // eventueel andere routes
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          //if (snapshot.hasData) {
          //return const HomeScreen();
          //}
          return const HomeScreen();
          //return const LoginScreen();
          //return const MovieDetailScreen(imdbId: "tt1632701");
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
// Vergeet niet je foodscreen te importeren!
import 'food_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Food App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      // Hier zet je FoodScreen als het eerste scherm
      home: const FoodScreen(), 
    );
  }
}