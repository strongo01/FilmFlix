import 'dart:convert';

import 'package:filmflix/models/movie_models.dart';
import 'package:filmflix/services/movie_repository.dart';
import 'package:filmflix/views/movie_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  List<MovieSearchItem> results = [];
  bool loading = false;

Future<void> search() async {
  final query = controller.text.trim();
  
  // Als zoekveld leeg is, geen API call en scherm leeg
  if (query.isEmpty) {
    setState(() {
      results = [];
      loading = false;
    });
    return;
  }

  setState(() => loading = true);
  try {
    results = await MovieRepository.search(query);
  } catch (e) {
    debugPrint('Error searching movies: $e');
    results = [];
  } finally {
    setState(() => loading = false);
  }
}

  /// Haalt TMDb poster op via backend fallback
  Future<String?> _fetchTmdbPoster(String? tmdbIdRaw) async {
    if (tmdbIdRaw == null) return null;
    final parts = tmdbIdRaw.split('/');
    final movieId = parts.length > 1 ? parts.last : tmdbIdRaw;

    final uri = Uri.parse(
      'https://film-flix-olive.vercel.app/api/movies',
    ).replace(queryParameters: {'type': 'tmdb-images', 'movie_id': movieId});

    try {
      final resp = await http.get(uri);
      if (resp.statusCode != 200) return null;

      final jsonData = jsonDecode(resp.body) as Map<String, dynamic>?;
      if (jsonData == null) return null;

      final postersRaw = jsonData['posters'];
      final posters = (postersRaw is List)
          ? postersRaw.cast<Map<String, dynamic>>()
          : [];

      Map<String, dynamic>? chosen;
      for (final p in posters) {
        if ((p['iso_3166_1'] ?? '').toString().toUpperCase() == 'US') {
          chosen = p;
          break;
        }
      }
      chosen ??= posters.isNotEmpty ? posters.first : null;

      if (chosen == null) return null;

      final filePath = chosen['file_path']?.toString();
      if (filePath == null) return null;

      return 'https://image.tmdb.org/t/p/original$filePath';
    } catch (e) {
      debugPrint('Error fetching TMDb poster: $e');
      return null;
    }
  }

  Widget _posterWithFallback(MovieSearchItem movie) {
    if (movie.poster == null || movie.poster!.isEmpty) {
      // Geen originele poster, direct TMDb fallback
      return FutureBuilder<String?>(
        future: _fetchTmdbPoster(movie.tmdbId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Container(color: Colors.grey[300]);
          }
          final url = snap.data;
          if (url != null && url.isNotEmpty) {
            return Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
            );
          }
          return Container(color: Colors.grey[300]);
        },
      );
    }

    // Er is een originele poster
    return Image.network(
      movie.poster!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // fallback naar TMDb
        return FutureBuilder<String?>(
          future: _fetchTmdbPoster(movie.tmdbId),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting)
              return Container(color: Colors.grey[300]);
            final url = snap.data;
            if (url != null && url.isNotEmpty)
              return Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey[300]),
              );
            return Container(color: Colors.grey[300]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text("Search", style: TextStyle(color: Colors.black87)),
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: "Zoek film...",
                hintStyle: const TextStyle(color: Colors.black45),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.black54),
                  onPressed: search,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
              ),
            ),
          ),
          if (loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: results.length,
                itemBuilder: (_, index) {
                  final movie = results[index];

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(imdbId: movie.id),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _posterWithFallback(movie),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          movie.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
