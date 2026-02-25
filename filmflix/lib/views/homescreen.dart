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
                  child: GridView.count(
                    physics: const BouncingScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 28,
                    childAspectRatio: 0.82,
                    children: [
                      _buildItem(
                        "assets/images/afbeelding filmagenda.png",
                        "Filmagenda",
                        itemBackgroundColor,
                        textColor,
                        shadowColor,
                      ),
                      _buildItem(
                        "assets/images/afbeelding eten drinken.png",
                        "Eten & Dranken",
                        itemBackgroundColor,
                        textColor,
                        shadowColor,
                      ),
                      _buildItem(
                        "assets/images/afbeelding thuisbio.jpg",
                        "Thuisbioscoop",
                        itemBackgroundColor,
                        textColor,
                        shadowColor,
                      ),
                      _buildItem(
                        "assets/images/afbeelding bestelling.jpg",
                        "Bestellingen",
                        itemBackgroundColor,
                        textColor,
                        shadowColor,
                      ),
                      _buildItem(
                        "assets/images/afbeelding vragen.jpg",
                        "Klantenservice",
                        itemBackgroundColor,
                        textColor,
                        shadowColor,
                      ),
                      _buildItem(
                        "assets/images/afbeelding kaart.jpg",
                        "Bioscooppas",
                        itemBackgroundColor,
                        textColor,
                        shadowColor,
                      ),
                    ],
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
  ) {
    return Column(
      children: [
        Container(
          height: 135,
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
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
