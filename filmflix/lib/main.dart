import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cinetrackr/firebase_options.dart';
import 'package:cinetrackr/views/customer_service.dart';
import 'package:cinetrackr/views/filmsnowscreen.dart';
import 'package:cinetrackr/views/foodscreen.dart';
import 'package:cinetrackr/views/movie_detail_screen.dart';
import 'package:cinetrackr/views/search_screen.dart';
import 'package:cinetrackr/views/homescreen.dart';
import 'package:cinetrackr/views/loginscreen.dart';
import 'package:cinetrackr/views/kaart.dart'; 
import 'package:cinetrackr/views/settingscreen.dart'; 

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
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFFB22222),
        ),
      ),
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF5F7F8),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFFB22222),
        ),
      ),
      themeMode: ThemeMode.system,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          
          if (snapshot.hasData) {
             // Hier kun je nog steeds forceren voor testen als je wilt:
             // return const MovieDetailScreen(imdbId: "tt1632701"); 
             return const MainNavigation(); 
          }
          return const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainNavigation(),
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Alle schermen die je in de balk wilt kunnen aanklikken
  final List<Widget> _screens = [
    const HomeScreen(),          // Index 0
    const FilmNowScreen(),       // Index 1 (Nieuw in balk)
    const SearchScreen(),        // Index 2
    const FoodScreen(),          // Index 3 (Nieuw in balk)
    const SettingsScreen(),      // Index 4
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed, // Noodzakelijk bij 5 knoppen
        backgroundColor: isDark ? const Color(0xFF1C282E) : Colors.white,
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_outlined),
            activeIcon: Icon(Icons.movie_filter_rounded),
            label: 'Films',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Zoeken',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood_outlined),
            activeIcon: Icon(Icons.fastfood_rounded),
            label: 'Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profiel',
          ),
        ],
      ),
    );
  }
}