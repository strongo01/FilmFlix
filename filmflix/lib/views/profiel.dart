import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ProfileScreen()));

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF121B22);
    const cardColor = Color(0xFF1D272F);
    const accentColor = Color(0xFFEBB143);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header met Avatar en Level Progress
          SliverAppBar(
            expandedHeight: 280,
            backgroundColor: backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [cardColor, backgroundColor],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: accentColor.withOpacity(0.3),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=kevin'),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: accentColor, shape: BoxShape.circle),
                          child: const Icon(Icons.star, size: 20, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Kevin le Goat',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Film Fanaat • Level 4',
                      style: TextStyle(color: accentColor, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistieken in één oogopslag
                  Row(
                    children: [
                      _buildQuickStat('24', 'Films', accentColor),
                      _buildQuickStat('12', 'Watchlist', Colors.blueAccent),
                      _buildQuickStat('5', 'Reviews', Colors.greenAccent),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // BADGES SECTIE (Vervangt Favorieten tekst)
                  const Text(
                    'JOUW BADGES',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildBadge('Horror King', Icons.auto_awesome, Colors.purpleAccent),
                        _buildBadge('Binge Watcher', Icons.bolt, Colors.orangeAccent),
                        _buildBadge('Early Bird', Icons.wb_sunny, Colors.yellowAccent),
                        _buildBadge('Critic', Icons.rate_review, Colors.cyanAccent),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'ACCOUNT',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuTile(Icons.person_outline, 'Profiel bewerken', cardColor),
                  _buildMenuTile(Icons.settings_outlined, 'Instellingen', cardColor),
                  _buildMenuTile(Icons.logout, 'Uitloggen', cardColor, isDestructive: true),
                  
                  const SizedBox(height: 30),
                  const Center(
                    child: Text('CineTrackr v1.0.4', style: TextStyle(color: Colors.white10, fontSize: 12)),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Kleine stat-indicator bovenaan
  Widget _buildQuickStat(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(height: 3, width: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  // Badge Widget
  Widget _buildBadge(String label, IconData icon, Color color) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D272F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // Menu Items
  Widget _buildMenuTile(IconData icon, String title, Color color, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white70),
        title: Text(title, style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white, fontSize: 15)),
        trailing: Icon(Icons.chevron_right, color: isDestructive ? Colors.redAccent.withOpacity(0.3) : Colors.white10),
        onTap: () {},
      ),
    );
  }
}