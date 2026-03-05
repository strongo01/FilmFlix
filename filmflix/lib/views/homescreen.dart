import 'package:cinetrackr/views/adminscreen.dart';
import 'package:cinetrackr/views/customer_service.dart';
import 'package:cinetrackr/views/filmsnowscreen.dart';
import 'package:cinetrackr/views/foodscreen.dart';
import 'package:cinetrackr/views/kaart.dart';
import 'package:cinetrackr/views/search_screen.dart';
import 'package:cinetrackr/views/settingscreen.dart';
import 'package:cinetrackr/views/watchlistscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureDisplayName());
  }

  Future<void> _ensureDisplayName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return; // not logged in

      final uid = user.uid;
      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final doc = await docRef.get();
      final data = doc.data();
      final displayNameFromDoc = data != null ? (data['displayName'] as String?) : null;

      // ONLY check the Firestore user document — ignore Firebase Auth displayName.
      if (displayNameFromDoc == null || displayNameFromDoc.trim().isEmpty) {
        // require user to enter a display name stored in the users/{uid} doc
        await _promptForDisplayName(uid);
      }
    } catch (e) {
      debugPrint('Error ensuring displayName: $e');
    }
  }

  Future<void> _promptForDisplayName(String uid) async {
    final formKey = GlobalKey<FormState>();
    final ctrl = TextEditingController();

    // showDialog with barrierDismissible false and prevent back button
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
              title: const Text('Voer je naam in.'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('We gebruiken je naam om de app persoonlijker te maken, bijvoorbeeld voor begroetingen.'),
                  const SizedBox(height: 12),
                  Form(
                    key: formKey,
                    child: TextFormField(
                      controller: ctrl,
                      autofocus: true,
                      decoration: const InputDecoration(labelText: 'Je naam'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Vul je naam in';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final name = ctrl.text.trim();
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await user.updateDisplayName(name);
                        await user.reload();
                      }
                      final usersRef = FirebaseFirestore.instance.collection('users').doc(uid);
                      await usersRef.set({
                        'displayName': name,
                        'email': user?.email,
                        'updatedAt': FieldValue.serverTimestamp(),
                      }, SetOptions(merge: true));
                    } catch (e) {
                      debugPrint('Failed saving displayName from dialog: $e');
                    }
                    if (mounted) Navigator.of(ctx).pop();
                  },
                  child: const Text('Opslaan en doorgaan'),
                ),
              ],
            ),
        );
      },
    );
  }

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

    // Ensure 'isSmallPhone', 'itemBackgroundColor', and 'shadowColor' are defined in the correct scope
    final isSmallPhone = MediaQuery.of(context).size.width < 360;
    final itemBackgroundColor = Colors.white;
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.25)
        : Colors.grey.withOpacity(0.4);

    return Scaffold(
      body: Stack(
        children: [
          // Achtergrond en scrollbare inhoud
          Container(
            decoration: BoxDecoration(gradient: backgroundGradient),
            child: SafeArea(
              child: SingleChildScrollView(
                // ← scroll alleen de inhoud
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gecentreerde tekst bovenaan (nu met ruimte voor statusbar + knop)
                    //SizedBox(
                      //height: MediaQuery.of(context).padding.top + 16,
                    //), // ruimte voor statusbar + marge
                    Row(
                      children: [
                        const SizedBox(width: 44), // Ruimte voor de knop aan de linkerkant
                        Expanded(
                          child: Center(
                            child: Text(
                              "Welkom bij CineTrackr",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            icon: Icon(
                              Icons.settings,
                              color: textColor,
                              size: 28,
                            ),
                            tooltip: 'Instellingen',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final screenWidth = constraints.maxWidth;
                          final crossAxisCount = screenWidth < 600 ? 2 : 3;

                          return GridView.count(
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
                                  MaterialPageRoute(
                                    builder: (_) => const FilmNowScreen(),
                                  ),
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
                                  MaterialPageRoute(
                                    builder: (_) => const FoodScreen(),
                                  ),
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
                                  MaterialPageRoute(
                                    builder: (_) => const SearchScreen(),
                                  ),
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
                                  MaterialPageRoute(
                                    builder: (_) => const WatchlistScreen(),
                                  ),
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
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const CustomerServiceScreen(),
                                  ),
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
                                  MaterialPageRoute(
                                    builder: (_) => const CinemasMapView(),
                                  ),
                                ),
                              ),
                              FutureBuilder<bool>(
                                future: () async {
                                  try {
                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user == null) return false;
                                    final doc = await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user.uid)
                                        .get();
                                    final data = doc.data();
                                    if (data == null) return false;
                                    final role = data['role'];
                                    if (role is String)
                                      return role.toLowerCase() == 'admin';
                                    if (role is List) {
                                      return role.any(
                                        (e) =>
                                            (e?.toString().toLowerCase() ??
                                                '') ==
                                            'admin',
                                      );
                                    }
                                    return false;
                                  } catch (_) {
                                    return false;
                                  }
                                }(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData &&
                                      snapshot.data == true) {
                                    return _buildItem(
                                      "assets/icons/appicon.png",
                                      "Admin",
                                      itemBackgroundColor,
                                      textColor,
                                      shadowColor,
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const AdminScreen(),
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
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
