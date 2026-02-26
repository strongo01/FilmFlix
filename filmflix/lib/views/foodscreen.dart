import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Nodig voor FilteringTextInputFormatter
import 'package:url_launcher/url_launcher.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  final List<Map<String, String>> _quickChoices = [
    {'name': 'Pizza', 'emoji': '🍕'},
    {'name': 'Sushi', 'emoji': '🍣'},
    {'name': 'Burger', 'emoji': '🍔'},
    {'name': 'Kapsalon', 'emoji': '🍟'},
  ];

  Future<void> _orderFood([String? manualFood]) async {
    final String food = manualFood ?? _foodController.text.trim();
    
    // We pakken de postcode en verwijderen voor de zekerheid alles wat geen cijfer is
    final String zipDigits = _zipCodeController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (zipDigits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vul de 4 getallen van je postcode in!')),
      );
      return;
    }

    if (food.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wat wil je eten?')),
      );
      return;
    }

    _foodController.text = food;

    // De URL gebruikt nu alleen de cijfers (bijv. 3543)
    final Uri url = Uri.parse('https://www.thuisbezorgd.nl/bestellen/eten/$zipDigits?q=$food');

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Waar woon je?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // --- Postcodeveld met Blokkade ---
            TextField(
              controller: _zipCodeController,
              decoration: InputDecoration(
                labelText: 'Postcode (alleen cijfers)',
                hintText: 'Bijv. 3543',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              // Hier blokkeren we letters en tekens:
              keyboardType: TextInputType.number, 
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Alleen 0-9 toegestaan
                LengthLimitingTextInputFormatter(4),    // Maximaal 4 cijfers
              ],
            ),
            
            const SizedBox(height: 30),
            const Divider(),
            // ... rest van je UI (Quick Choices en Zoekveld) ...
            const SizedBox(height: 15),
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
            const SizedBox(height: 30),
            TextField(
              controller: _foodController,
              decoration: InputDecoration(
                labelText: 'Wat wil je eten?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _orderFood(),
              child: const Text('ZOEK OP THUISBEZORGD'),
            ),
          ],
        ),
      ),
    );
  }
}