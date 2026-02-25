import 'package:cinetrackr/views/foodscreen.dart';
import 'package:cinetrackr/views/search_screen.dart';
import 'package:flutter/material.dart';

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
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                /// Header
                Center(
                  child: Text(
                    "Welkom bij uw Bioscoopomgeving",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                /// Grid
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth;

                      // Cap content width so items don't spread too far on web/large screens
                      final contentWidth = maxWidth.clamp(0.0, 700.0);

                      // Responsive column count — default 2 per row on phones and larger,
                      // but 1 per row only for very narrow screens
                      final crossAxisCount = maxWidth < 350 ? 1 : 2;

                      // Spacing tuned by content width so items feel larger but not distant
                      final crossAxisSpacing = contentWidth < 420 ? 16.0 : 24.0;
                      final mainAxisSpacing = contentWidth < 420 ? 20.0 : 28.0;

                      // Compute sizes using contentWidth (the visible grid width)
                      final itemWidth =
                          (contentWidth -
                              (crossAxisCount - 1) * crossAxisSpacing) /
                          crossAxisCount;
                      final itemHeight = itemWidth * 0.9 + 48;
                      final childAspectRatio = itemWidth / itemHeight;

                      // Derived values passed to each item
                      final imageHeight = itemHeight * 0.6;
                      final titleFontSize = (itemWidth * 0.06).clamp(
                        12.0,
                        20.0,
                      );

                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentWidth),
                          child: GridView.count(
                            physics: const BouncingScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: crossAxisSpacing,
                            mainAxisSpacing: mainAxisSpacing,
                            childAspectRatio: childAspectRatio,
                            children: [
                              _buildItem(
                                "assets/images/afbeelding filmagenda.png",
                                "Filmagenda",
                                itemBackgroundColor,
                                textColor,
                                shadowColor,
                                imageHeight,
                                titleFontSize,
                                () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const FilmagendaScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildItem(
                                "assets/images/afbeelding eten drinken.png",
                                "Eten & Dranken",
                                itemBackgroundColor,
                                textColor,
                                shadowColor,
                                imageHeight,
                                titleFontSize,
                                () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const FoodScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildItem(
                                "assets/images/afbeelding thuisbio.jpg",
                                "Thuisbioscoop",
                                itemBackgroundColor,
                                textColor,
                                shadowColor,
                                imageHeight,
                                titleFontSize,
                                () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HomeCinemaScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildItem(
                                "assets/images/afbeelding bestelling.jpg",
                                "Bestellingen",
                                itemBackgroundColor,
                                textColor,
                                shadowColor,
                                imageHeight,
                                titleFontSize,
                                () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const OrdersScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildItem(
                                "assets/images/afbeelding vragen.jpg",
                                "Klantenservice",
                                itemBackgroundColor,
                                textColor,
                                shadowColor,
                                imageHeight,
                                titleFontSize,
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
                                "assets/images/afbeelding kaart.jpg",
                                "Bioscooppas",
                                itemBackgroundColor,
                                textColor,
                                shadowColor,
                                imageHeight,
                                titleFontSize,
                                () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SearchScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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
    double imageHeight,
    double titleFontSize,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: imageHeight,
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
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: imageHeight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleFontSize,
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

class FilmagendaScreen extends StatelessWidget {
  const FilmagendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filmagenda')),
      body: const Center(child: Text('Filmagenda Content Here')),
    );
  }
}

class HomeCinemaScreen extends StatelessWidget {
  const HomeCinemaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thuisbioscoop')),
      body: const Center(child: Text('Thuisbioscoop Content Here')),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bestellingen')),
      body: const Center(child: Text('Bestellingen Content Here')),
    );
  }
}

class CustomerServiceScreen extends StatelessWidget {
  const CustomerServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Klantenservice')),
      body: const Center(child: Text('Klantenservice Content Here')),
    );
  }
}
