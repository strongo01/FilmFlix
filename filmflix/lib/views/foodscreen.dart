import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  // Controller om de tekst uit het invoerveld te lezen
  final TextEditingController _foodController = TextEditingController();

  // Lijstje voor de snelle icoontjes boven de zoekbalk
  final List<Map<String, String>> _quickChoices = [
    {'name': 'Pizza', 'emoji': '🍕'},
    {'name': 'Sushi', 'emoji': '🍣'},
    {'name': 'Burger', 'emoji': '🍔'},
    {'name': 'Kapsalon', 'emoji': '🍟'},
  ];

  // De functie die Thuisbezorgd opent
  // We voegen 'String? manualFood' toe zodat we zowel de knop als de icoontjes kunnen gebruiken
  Future<void> _orderFood([String? manualFood]) async {
    // Pak of de tekst uit het tekstveld, of de tekst van het icoontje waar je op klikte
    final String food = manualFood ?? _foodController.text.trim();
    
    if (food.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vul eerst in wat je wilt eten!')),
      );
      return;
    }

    // Update het tekstveld visueel
    _foodController.text = food;

    final Uri url = Uri.parse('https://www.thuisbezorgd.nl/zoeken?q=$food');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Fout bij openen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food & Movies'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SingleChildScrollView( // Zorgt dat het op kleine schermen ook past
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.fastfood,
              size: 60,
              color: Colors.orange,
            ),
            const SizedBox(height: 10),
            const Text(
              'Honger voordat de film begint?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),

            // --- NIEUW: De Rij met Snelle Keuzes ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _quickChoices.map((item) {
                return GestureDetector(
                  onTap: () => _orderFood(item['name']),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        child: Text(item['emoji']!, style: const TextStyle(fontSize: 25)),
                      ),
                      const SizedBox(height: 5),
                      Text(item['name']!, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
            // ---------------------------------------

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
            
            // Invoerveld voor handmatig zoeken
            TextField(
              controller: _foodController,
              decoration: InputDecoration(
                labelText: 'Wat wil je eten?',
                hintText: 'Bijv. Chinees, Pasta...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // De Bestelknop (werkt nog steeds hetzelfde)
            ElevatedButton(
              onPressed: () => _orderFood(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'BESTELLEN BIJ THUISBEZORGD',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}