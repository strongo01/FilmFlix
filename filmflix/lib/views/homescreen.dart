import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                /// Header
                const Center(
                  child: Text(
                    "Welkom bij uw Bioscoopomgeving",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
                      _buildItem("assets/images/afbeelding filmagenda.png", "Filmagenda"),
                      _buildItem("assets/images/afbeelding eten drinken.png", "Eten & Dranken"),
                      _buildItem("assets/images/afbeelding thuisbio.jpg", "Thuisbioscoop"),
                      _buildItem("assets/images/afbeelding bestelling.jpg", "Bestellingen"),
                      _buildItem("assets/images/afbeelding vragen.jpg", "Klantenservice"),
                      _buildItem("assets/images/afbeelding kaart.jpg", "Bioscooppas"),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(String imagePath, String title) {
    return Column(
      children: [
        Container(
          height: 135,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
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
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        )
      ],
    );
  }
}
