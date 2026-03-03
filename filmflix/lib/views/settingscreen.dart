import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Color movieBlue = const Color.fromRGBO(43, 77, 91, 1);
  final Color goldAccent = const Color(0xFFD4AF37);
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1C1E);
    final cardColor = isDark ? const Color(0xFF1C282E) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F171B) : const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: const Text('Instellingen', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: movieBlue,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- NIEUW: VIERKANT ACCOUNT BLOK MET STATS ---
          _buildSectionLabel('Mijn Dashboard'),
          _buildAccountCard(cardColor, textColor),

          const SizedBox(height: 24),

          // --- APP INSTELLINGEN ---
          _buildSectionLabel('Voorkeuren'),
          _buildProfessionalCard(
            cardColor,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  secondary: Icon(Icons.notifications_none, color: movieBlue),
                  title: const Text('Meldingen'),
                  value: _notificationsEnabled,
                  activeColor: goldAccent,
                  onChanged: (val) => setState(() => _notificationsEnabled = val),
                ),
                _buildDivider(isDark),
                _buildSimpleTile(Icons.language, 'Taal', 'Nederlands', textColor),
                _buildDivider(isDark),
                _buildSimpleTile(Icons.privacy_tip_outlined, 'Privacy & Beveiliging', '', textColor),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- SUPPORT ---
          _buildSectionLabel('Support'),
          _buildProfessionalCard(
            cardColor,
            child: _buildSimpleTile(Icons.help_outline, 'Klantenservice', '', textColor),
          ),

          const SizedBox(height: 40),

          // --- LOGOUT ---
          TextButton(
            onPressed: () {},
            child: const Text('UITLOGGEN', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
        ],
      ),
    );
  }

  // --- HET NIEUWE VIERKANTE ACCOUNT BLOK ---
  Widget _buildAccountCard(Color cardColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // Minder rond, meer 'vierkant-achtig'
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: movieBlue,
                        borderRadius: BorderRadius.circular(8), // Vierkante avatar met zachte hoeken
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 35),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gebruikersnaam', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                        Text('Premium Member', style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 14)),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.edit_square, color: movieBlue, size: 20),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1),
                ),
                // DE STATS RIJ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('124', 'Films', textColor),
                    _buildStatItem('45', 'Watchlist', textColor),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color textColor) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: movieBlue)),
        Text(label, style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6))),
      ],
    );
  }

  // --- HELPERS ---
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(label.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
    );
  }

  Widget _buildProfessionalCard(Color color, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }

  Widget _buildSimpleTile(IconData icon, String title, String trailing, Color textColor) {
    return ListTile(
      leading: Icon(icon, color: movieBlue),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing.isNotEmpty) Text(trailing, style: TextStyle(color: textColor.withOpacity(0.4))),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(height: 1, indent: 55, color: isDark ? Colors.white10 : Colors.black12);
  }
}