import 'package:cinetrackr/views/adminscreen.dart';
import 'package:cinetrackr/views/customer_service.dart';
import 'package:cinetrackr/views/filmsnowscreen.dart';
import 'package:cinetrackr/views/foodscreen.dart';
import 'package:cinetrackr/views/kaart.dart';
import 'package:cinetrackr/views/search_screen.dart';
import 'package:cinetrackr/views/watchlistscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    final backgroundGradient = isDarkMode
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0E0E0), Color(0xFFF5F5F5), Color(0xFFFFFFFF)],
          );

    final textColor = isDarkMode ? Colors.white : Colors.black;

    final itemBackgroundColor = Colors.white;
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.25)
        : Colors.grey.withOpacity(0.4);

    return Scaffold(
      extendBodyBehindAppBar: true, // ← Dit zorgt ervoor dat de body achter de AppBar doorloopt

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0, // voorkomt schaduw bij scrollen
        title: Text(
          "Welkom bij uw Bioscoopomgeving",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        foregroundColor: textColor,
      ),

      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final isSmallPhone = screenWidth < 360;
              final crossAxisCount = screenWidth < 600 ? 2 : 3;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ruimte maken zodat de content onder de AppBar begint
                      SizedBox(height: kToolbarHeight + 24),

                      // Je grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 28,
                        childAspectRatio: isSmallPhone ? 0.85 : 0.9,
                        children: [
                          _buildItem(
                            "assets/images/AfbeeldingFilmagenda.png",
                            "Filmagenda",
                            itemBackgroundColor,
                            textColor,
                            shadowColor,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FilmNowScreen()),
                            ),
                          ),
                          _buildItem(
                            "assets/images/AfbeeldingEtenDrinken.png",
                            "Eten & Drinken",
                            itemBackgroundColor,
                            textColor,
                            shadowColor,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FoodScreen()),
                            ),
                          ),
                          _buildItem(
                            "assets/images/AfbeeldingThuisbio.png",
                            "Thuisbioscoop",
                            itemBackgroundColor,
                            textColor,
                            shadowColor,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SearchScreen()),
                            ),
                          ),
                          _buildItem(
                            "assets/images/AfbeeldingWatchlist.png",
                            "Watchlist",
                            itemBackgroundColor,
                            textColor,
                            shadowColor,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const WatchlistScreen()),
                            ),
                          ),
                          _buildItem(
                            "assets/images/AfbeeldingVragen.png",
                            "Klantenservice",
                            itemBackgroundColor,
                            textColor,
                            shadowColor,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CustomerServiceScreen()),
                            ),
                          ),
                          _buildItem(
                            "assets/images/AfbeeldingKaart.png",
                            "Bioscoopkaart",
                            itemBackgroundColor,
                            textColor,
                            shadowColor,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CinemasMapView()),
                            ),
                          ),

                          // Admin knop alleen voor admins
                          FutureBuilder<bool>(
                            future: () async {
                              try {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) return false;
                                final doc = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .get();
                                final data = doc.data();
                                if (data == null) return false;
                                final role = data['role'];
                                if (role is String) return role.toLowerCase() == 'admin';
                                if (role is List) {
                                  return role.any((e) => (e?.toString().toLowerCase() ?? '') == 'admin');
                                }
                                return false;
                              } catch (_) {
                                return false;
                              }
                            }(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data == true) {
                                return _buildItem(
                                  "assets/icons/appicon.png",
                                  "Admin",
                                  itemBackgroundColor,
                                  textColor,
                                  shadowColor,
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AdminScreen()),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 40), // onderkant ruimte
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    String imagePath,
    String title,
    Color itemBgColor,
    Color textColor,
    Color shadowColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: itemBgColor,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}