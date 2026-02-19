//BURAK
import 'package:flutter/material.dart';

void main() {
  runApp(const FilmFlixApp());
}

class FilmFlixApp extends StatelessWidget {
  const FilmFlixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FilmFlix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37), // goud accent
          secondary: Color(0xFFB22222), // diep rood
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;
  late Animation<double> _curtainOpen;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..forward();

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );

    _scaleIn = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic)),
    );

    _curtainOpen = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeInOutCubic)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Subtiele filmzaal-achtergrond gradient + lichte textuur
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F000A),
                  Color(0xFF14000F),
                  Color(0xFF0A0A0A),
                ],
              ),
            ),
          ),

          // Zachte rode gloed van onderen (rode vloer / gordijnen sfeer)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Opacity(
              opacity: 0.18,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.bottomCenter,
                    radius: 1.1,
                    colors: [Color(0xFFB22222), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo / Titel met gordijn-animatie
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeIn.value,
                      child: Transform.scale(
                        scale: _scaleIn.value,
                        child: Column(
                          children: [
                            // Subtiel gordijn-effect links/rechts
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Linker gordijn
                                Transform.translate(
                                  offset: Offset(-300 * (1 - _curtainOpen.value), 0),
                                  child: const _CurtainSide(isLeft: true),
                                ),
                                // Rechter gordijn
                                Transform.translate(
                                  offset: Offset(300 * (1 - _curtainOpen.value), 0),
                                  child: const _CurtainSide(isLeft: false),
                                ),
                                // Logo / titel
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    'FILMFLIX',
                                    style: TextStyle(
                                      fontSize: 72,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 6,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Color(0xFFD4AF37),
                                          blurRadius: 20,
                                          offset: Offset(0, 0),
                                        ),
                                        Shadow(
                                          color: Color(0x80B22222),
                                          blurRadius: 40,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Jouw persoonlijke bioscoop',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white.withOpacity(0.75),
                                letterSpacing: 2.5,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 3),

                // Hoofd acties – strak, premium look
                _ActionButton(
                  label: 'Nu Afspelen',
                  icon: Icons.play_circle_fill_rounded,
                  color: const Color(0xFFD4AF37),
                  isPrimary: true,
                  onPressed: () => print('Start afspelen'),
                ),
                const SizedBox(height: 20),
                _ActionButton(
                  label: 'Bladeren',
                  icon: Icons.grid_view_rounded,
                  color: Colors.white,
                  onPressed: () => print('Naar catalogus'),
                ),
                const SizedBox(height: 20),
                _ActionButton(
                  label: 'Mijn Lijst',
                  icon: Icons.bookmark_rounded,
                  color: Colors.white70,
                  onPressed: () => print('Mijn lijst openen'),
                ),

                const Spacer(flex: 4),

                // Footer met professionele touch
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'FilmFlix © 2026',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '•',
                        style: TextStyle(color: Colors.white.withOpacity(0.3)),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => print('Voorwaarden'),
                        child: Text(
                          'Voorwaarden',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Gordijn zij-elementen (simpel maar elegant)
class _CurtainSide extends StatelessWidget {
  final bool isLeft;

  const _CurtainSide({required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          colors: const [
            Color(0xFFB22222),
            Color(0xFF8B0000),
            Color(0xFF5A0000),
          ],
        ),
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(60) : Radius.zero,
          right: isLeft ? Radius.zero : const Radius.circular(60),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
    );
  }
}

// Premium actie knop
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.isPrimary = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 28, color: isPrimary ? Colors.black : color),
          label: Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: isPrimary ? Colors.black : Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            backgroundColor: isPrimary ? color : Colors.transparent,
            foregroundColor: isPrimary ? Colors.black : color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isPrimary
                  ? BorderSide.none
                  : BorderSide(color: color.withOpacity(0.5), width: 1.5),
            ),
            elevation: isPrimary ? 12 : 0,
            shadowColor: isPrimary ? color.withOpacity(0.4) : Colors.transparent,
          ),
        ),
      ),
    );
  }
}