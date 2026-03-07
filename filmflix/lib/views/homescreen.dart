import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importeer je andere schermen hier
import 'package:cinetrackr/views/adminscreen.dart';
import 'package:cinetrackr/views/kaart.dart';
import 'package:cinetrackr/views/settingscreen.dart';
import 'package:cinetrackr/views/movie_detail_screen.dart';

// De data-klasse voor de films
class FilmNowItem {
  final String tmdbId;
  final String title;
  final String? poster;
  final String? backdrop;
  String? imdbId;

  FilmNowItem({
    required this.tmdbId,
    required this.title,
    this.poster,
    this.backdrop,
    this.imdbId,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Film API Logica ---
  final String baseApi = 'https://film-flix-olive.vercel.app/api/movies';
  List<FilmNowItem> films = [];
  bool loadingFilms = true;
  int currentIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureDisplayName());
    _loadNowPlaying();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- API Functies (gekopieerd uit FilmNowScreen) ---
  Future<void> _loadNowPlaying() async {
    try {
      final uri = Uri.parse(baseApi).replace(queryParameters: {
        'type': 'actualfilms',
        'page': '1',
        'language': 'nl-NL',
        'region': 'NL',
      });
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final jsonData = jsonDecode(resp.body);
        final results = (jsonData['results'] as List<dynamic>?) ?? [];
        final temp = <FilmNowItem>[];

        for (final r in results) {
          final map = r as Map<String, dynamic>;
          temp.add(FilmNowItem(
            tmdbId: map['id'].toString(),
            title: map['title'] ?? map['original_title'],
            poster: map['poster_path'] != null ? 'https://image.tmdb.org/t/p/w500${map['poster_path']}' : null,
            backdrop: map['backdrop_path'] != null ? 'https://image.tmdb.org/t/p/original${map['backdrop_path']}' : null,
          ));
        }
        
        // Haal IMDB IDs op voor navigatie
        setState(() {
          films = temp;
          loadingFilms = false;
        });
        
        for (var item in films) {
          _fetchImdbIdFor(item);
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => loadingFilms = false);
    }
  }

  Future<void> _fetchImdbIdFor(FilmNowItem item) async {
    try {
      final uri = Uri.parse(baseApi).replace(queryParameters: {
        'type': 'tmdbmovieinfo',
        'movie_id': item.tmdbId,
      });
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        item.imdbId = data['imdb_id'];
      }
    } catch (_) {}
  }

  String proxiedUrl(String url) => '$baseApi?type=image-proxy&imageUrl=${Uri.encodeComponent(url)}';

  // --- Bestaande Logica voor DisplayName & Admin ---
  Future<void> _ensureDisplayName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.data()?['displayName'] == null) await _promptForDisplayName(user.uid);
  }

  Future<void> _promptForDisplayName(String uid) async { /* Je bestaande prompt code */ }

  Future<bool> _checkIfAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.data()?['role']?.toString().toLowerCase() == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(colors: [Color(0xFF0F2027), Color(0xFF203A43)])
              : const LinearGradient(colors: [Color(0xFFE0E0E0), Color(0xFFFFFFFF)]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- BOVENBALK ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.map_outlined, color: textColor),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CinemasMapView())),
                    ),
                    const Expanded(
                      child: Text("CineTrackr", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    FutureBuilder<bool>(
                      future: _checkIfAdmin(),
                      builder: (context, snap) => snap.data == true 
                        ? IconButton(icon: const Icon(Icons.admin_panel_settings, color: Colors.amber), onPressed: () {}) 
                        : const SizedBox(width: 48),
                    ),
                    IconButton(
                      icon: Icon(Icons.settings, color: textColor),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text("Nu in de bioscoop", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w300)),
              const SizedBox(height: 10),

              // --- DE SWIPER (FILM CARROUSEL) ---
              Expanded(
                child: loadingFilms
                    ? const Center(child: CircularProgressIndicator())
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: films.length,
                        onPageChanged: (i) => setState(() => currentIndex = i),
                        itemBuilder: (context, index) {
                          final film = films[index];
                          final isSelected = index == currentIndex;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            margin: EdgeInsets.symmetric(
                              horizontal: 10, 
                              vertical: isSelected ? 20 : 50,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: GestureDetector(
                                onTap: () {
                                  if (film.imdbId != null) {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(imdbId: film.imdbId!)));
                                  }
                                },
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      proxiedUrl(film.poster ?? ""),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(color: Colors.grey),
                                    ),
                                    // Titel overlay
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                                          ),
                                        ),
                                        child: Text(
                                          film.title,
                                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // --- DOT INDICATOR ---
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    (films.length > 8 ? 8 : films.length), // Maximaal 8 stipjes voor overzicht
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == currentIndex ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == currentIndex ? Colors.blue : Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}