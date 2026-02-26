import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  // De geselecteerde dieetwens (maximaal één)
  String? _selectedFilter;

  final List<Map<String, String>> _filterOptions = [
    {'label': 'Vegetarisch', 'slug': 'vegetarian'},
    {'label': 'Vegan', 'slug': 'vegan'},
    {'label': 'Glutenvrij', 'slug': 'gluten-free-options'},
    {'label': 'Halal', 'slug': 'halal'},
  ];

  // Je favoriete lijstje (aanpasbaar via Long Press)
  List<Map<String, String>> _quickChoices = [
    {'name': 'Pizza', 'emoji': '🍕'},
    {'name': 'Sushi', 'emoji': '🍣'},
    {'name': 'Burger', 'emoji': '🍔'},
    {'name': 'Kapsalon', 'emoji': '🍟'},
  ];

  // Dialoog om favoriet aan te passen
  void _editFavorite(int index) {
    final nameEditController = TextEditingController(text: _quickChoices[index]['name']);
    final emojiEditController = TextEditingController(text: _quickChoices[index]['emoji']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pas favoriet aan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameEditController,
              decoration: const InputDecoration(
                labelText: 'Naam (tekst & emoji toegestaan)',
                hintText: 'Bijv. Taco 🌮',
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emojiEditController,
              decoration: const InputDecoration(
                labelText: 'Alleen Emoji',
                hintText: 'Kies 1 emoji',
                counterText: "",
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 30),
              maxLength: 1,
              inputFormatters: [
                // BLOKKEERT: letters (a-z, A-Z), cijfers (0-9) en spaties (\s)
                FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z0-9\s]')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuleren'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emojiEditController.text.isNotEmpty) {
                setState(() {
                  _quickChoices[index] = {
                    'name': nameEditController.text.trim(),
                    'emoji': emojiEditController.text.trim(),
                  };
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voer een geldige emoji in!')),
                );
              }
            },
            child: const Text('Opslaan'),
          ),
        ],
      ),
    );
  }

  Future<void> _orderFood([String? manualFood]) async {
    final String food = manualFood ?? _foodController.text.trim();
    final String zipDigits = _zipCodeController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (zipDigits.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vul eerst 4 cijfers van je postcode in!')),
      );
      return;
    }

    if (food.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wat wil je eten?')),
      );
      return;
    }

    // URL bouwen
    String urlString = 'https://www.thuisbezorgd.nl/bestellen/eten/$zipDigits?q=$food';
    if (_selectedFilter != null) {
      urlString += '&filter=$_selectedFilter';
    }

    final Uri url = Uri.parse(urlString);
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
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Locatie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _zipCodeController,
              decoration: InputDecoration(
                labelText: 'Postcode (4 cijfers)',
                prefixIcon: const Icon(Icons.location_on, color: Colors.orange),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
            ),
            const SizedBox(height: 25),
            const Text('Dieetwens (max. 1)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _filterOptions.map((filter) {
                final bool isSelected = _selectedFilter == filter['slug'];
                return FilterChip(
                  label: Text(filter['label']!),
                  selected: isSelected,
                  selectedColor: Colors.orangeAccent.withOpacity(0.3),
                  checkmarkColor: Colors.orange,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedFilter = selected ? filter['slug'] : null;
                    });
                  },
                );
              }).toList(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(),
            ),
            const Text(
              'Houd een icoon ingedrukt om aan te passen',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_quickChoices.length, (index) {
                return GestureDetector(
                  onTap: () => _orderFood(_quickChoices[index]['name']),
                  onLongPress: () => _editFavorite(index),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        child: Text(_quickChoices[index]['emoji']!, style: const TextStyle(fontSize: 25)),
                      ),
                      const SizedBox(height: 5),
                      Text(_quickChoices[index]['name']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _foodController,
              decoration: InputDecoration(
                labelText: 'Zelf iets zoeken...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                suffixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () => _orderFood(),
              child: const Text('ZOEK OP THUISBEZORGD', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}