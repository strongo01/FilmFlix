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
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

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

    final itemBackgroundColor = isDarkMode
        ? Colors.white
        : Colors.white; // Keep white for items, or adjust if needed
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.25)
        : Colors.grey.withOpacity(0.4);



    return Scaffold(
        appBar: AppBar(
        title: Text(
                            "Welkom bij uw Bioscoopomgeving",
                            textAlign: TextAlign.center,
                            style: TextStyle(

                              fontWeight: FontWeight.w700,
                              color: textColor,
                              letterSpacing: 0.5,
                            ),
                          ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isSmallPhone = screenWidth < 360;
          final crossAxisCount = screenWidth < 600 ? 2 : 3;

          return Container(
            decoration: BoxDecoration(gradient: backgroundGradient),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),



                        /// Grid
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
                              () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const FilmNowScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildItem(
                              "assets/images/AfbeeldingEtenDrinken.png",
                              "Eten & Drinken",
                              itemBackgroundColor,
                              textColor,
                              shadowColor,
                              () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const FoodScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildItem(
                              "assets/images/AfbeeldingThuisbio.png",
                              "Thuisbioscoop",
                              itemBackgroundColor,
                              textColor,
                              shadowColor,
                              () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const SearchScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildItem(
                              "assets/images/AfbeeldingWatchlist.png",
                              "Watchlist",
                              itemBackgroundColor,
                              textColor,
                              shadowColor,
                              () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const WatchlistScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildItem(
                              "assets/images/AfbeeldingVragen.png",
                              "Klantenservice",
                              itemBackgroundColor,
                              textColor,
                              shadowColor,
                              () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CustomerServiceScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildItem(
                              "assets/images/AfbeeldingKaart.png",
                              "Bioscoopkaart",
                              itemBackgroundColor,
                              textColor,
                              shadowColor,
                              () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const CinemasMapView(),
                                  ),
                                );
                              },
                            ),
                            // only show Admin item for users with role 'admin'
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
                                  if (role is List) return role.map((e) => e.toString().toLowerCase()).contains('admin');
                                  return false;
                                } catch (e) {
                                  return false;
                                }
                              }(),
                              builder: (ctx, snap) {
                                final isAdmin = snap.data == true;
                                if (!isAdmin) return const SizedBox.shrink();
                                return _buildItem(
                                  "assets/icons/appicon.png",
                                  "Admin",
                                  itemBackgroundColor,
                                  textColor,
                                  shadowColor,
                                  () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const AdminScreen(),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
          /// IMAGE neemt ALLE resterende ruimte
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

          /// TEXT krijgt minimale ruimte
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
