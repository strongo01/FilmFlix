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

  // Kleurenpalet
  final Color movieBlue = const Color.fromRGBO(43, 77, 91, 1);
  final Color movieBlueLight = const Color.fromRGBO(43, 77, 91, 0.1);
  final Color dieetwensen = const Color.fromARGB(255, 255, 255, 255);
  String? _selectedFilter;

  final List<Map<String, String>> _filterOptions = [
    {'label': 'Vegetarisch', 'slug': 'vegetarian'},
    {'label': 'Vegan', 'slug': 'vegan'},
    {'label': 'Glutenvrij', 'slug': 'gluten-free-options'},
    {'label': 'Halal', 'slug': 'halal'},
  ];

  List<Map<String, String>> _quickChoices = [
    {'name': 'Pizza', 'emoji': '🍕'},
    {'name': 'Sushi', 'emoji': '🍣'},
    {'name': 'Burger', 'emoji': '🍔'},
    {'name': 'Kapsalon', 'emoji': '🍟'},
  ];

  // Hulpfunctie voor adaptieve kleuren
  Color _getAdaptiveTextColor(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  void _editFavorite(int index) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final nameEditController = TextEditingController(text: _quickChoices[index]['name']);
    final emojiEditController = TextEditingController(text: _quickChoices[index]['emoji']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color.fromRGBO(28, 40, 46, 1) : Colors.white,
        title: Text('Pas favoriet aan', style: TextStyle(color: _getAdaptiveTextColor(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameEditController,
              style: TextStyle(color: _getAdaptiveTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Naam',
                labelStyle: TextStyle(color: _getAdaptiveTextColor(context).withOpacity(0.6)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emojiEditController,
              style: const TextStyle(fontSize: 30),
              decoration: InputDecoration(
                labelText: 'Alleen Emoji',
                labelStyle: TextStyle(color: _getAdaptiveTextColor(context).withOpacity(0.6)),
                counterText: "",
              ),
              textAlign: TextAlign.center,
              maxLength: 1,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z0-9\s]')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuleren', style: TextStyle(color: movieBlue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: movieBlue),
            onPressed: () {
              if (emojiEditController.text.isNotEmpty) {
                setState(() {
                  _quickChoices[index] = {
                    'name': nameEditController.text.trim(),
                    'emoji': emojiEditController.text.trim(),
                  };
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Opslaan', style: TextStyle(color: Colors.white)),
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
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final textColor = _getAdaptiveTextColor(context);
    final scaffoldBg = isDark ? const Color.fromRGBO(28, 40, 46, 1) : Colors.grey[50];

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text('Food & Movies', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: movieBlue,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Locatie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
            const SizedBox(height: 10),
            TextField(
              controller: _zipCodeController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                labelText: 'Postcode (4 cijfers)',
                labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
                prefixIcon: Icon(Icons.location_on, color: movieBlue),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: movieBlue, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
            ),
            const SizedBox(height: 25),
            Text('Dieetwens', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _filterOptions.map((filter) {
                final bool isSelected = _selectedFilter == filter['slug'];
                final textColor = MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87;

                return FilterChip(
                  label: Text(filter['label']!),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : textColor, // Adjusted for adaptive text color
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  selected: isSelected,
                  backgroundColor: MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.white.withOpacity(0.05)
                      : movieBlue.withOpacity(0.08),
                  selectedColor: movieBlue,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: isSelected ? Colors.transparent : movieBlue.withOpacity(0.2)),
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedFilter = selected ? filter['slug'] : null;
                    });
                  },
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: isDark ? Colors.white10 : Colors.black12),
            ),
            Text(
              'Houd een icoon ingedrukt om aan te passen',
              style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.5), fontStyle: FontStyle.italic),
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
                        backgroundColor: movieBlue.withOpacity(isDark ? 0.2 : 0.1),
                        child: Text(_quickChoices[index]['emoji']!, style: const TextStyle(fontSize: 25)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _quickChoices[index]['name']!, 
                        style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.8), fontWeight: FontWeight.w500)
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 35),
            TextField(
              controller: _foodController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                labelText: 'Zelf iets zoeken...',
                labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: movieBlue, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                suffixIcon: Icon(Icons.search, color: movieBlue),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: movieBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: isDark ? 4 : 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () => _orderFood(),
              child: const Text('ZOEK OP THUISBEZORGD', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            ),
          ],
        ),
      ),
    );
  }
}