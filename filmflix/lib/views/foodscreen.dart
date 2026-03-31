import 'package:cinetrackr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cinetrackr/widgets/app_top_bar.dart';
import 'package:cinetrackr/widgets/app_background.dart';

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

  // store slugs/keys here; labels will be retrieved from localization at build time
  final List<Map<String, String>> _filterOptions = [
    {'slug': 'vegetarian'},
    {'slug': 'vegan'},
    {'slug': 'gluten-free-options'},
    {'slug': 'halal'},
  ];

  // quick choices store an optional custom name and an emoji. If name is null, use localized default.
  List<Map<String, String?>> _quickChoices = [
    {'key': 'pizza', 'name': null, 'emoji': '🍕'},
    {'key': 'sushi', 'name': null, 'emoji': '🍣'},
    {'key': 'burger', 'name': null, 'emoji': '🍔'},
    {'key': 'kapsalon', 'name': null, 'emoji': '🍟'},
  ];

  // Hulpfunctie voor adaptieve kleuren
  Color _getAdaptiveTextColor(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  void _editFavorite(int index) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    final localizedDefault =
        _quickChoices[index]['name'] ??
        (_quickChoices[index]['key'] == 'pizza'
            ? loc.food_quick_pizza
            : _quickChoices[index]['key'] == 'sushi'
            ? loc.food_quick_sushi
            : _quickChoices[index]['key'] == 'burger'
            ? loc.food_quick_burger
            : loc.food_quick_kapsalon);
    final nameEditController = TextEditingController(text: localizedDefault);
    final emojiEditController = TextEditingController(
      text: _quickChoices[index]['emoji'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? const Color.fromRGBO(28, 40, 46, 1)
            : Colors.white,
        title: Text(
          loc.food_edit_favorite,
          style: TextStyle(color: _getAdaptiveTextColor(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameEditController,
              style: TextStyle(color: _getAdaptiveTextColor(context)),
              decoration: InputDecoration(
                labelText: loc.food_name_label,
                labelStyle: TextStyle(
                  color: _getAdaptiveTextColor(context).withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emojiEditController,
              style: const TextStyle(fontSize: 30),
              decoration: InputDecoration(
                labelText: loc.food_only_emoji,
                labelStyle: TextStyle(
                  color: _getAdaptiveTextColor(context).withOpacity(0.6),
                ),
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
            child: Text(loc.cancel, style: TextStyle(color: movieBlue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: movieBlue),
            onPressed: () {
              if (emojiEditController.text.isNotEmpty) {
                setState(() {
                  _quickChoices[index] = {
                    'key': _quickChoices[index]['key']!,
                    'name': nameEditController.text.trim(),
                    'emoji': emojiEditController.text.trim(),
                  };
                });
                Navigator.pop(context);
              }
            },
            child: Text(loc.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _orderFood([String? manualFood]) async {
    final String food = manualFood ?? _foodController.text.trim();
    final String zipDigits = _zipCodeController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (zipDigits.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.food_zip_required),
        ),
      );
      return;
    }

    if (food.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.food_what_do_you_want),
        ),
      );
      return;
    }

    String urlString =
        'https://www.thuisbezorgd.nl/bestellen/eten/$zipDigits?q=$food';
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
    final scaffoldBg = isDark
        ? const Color.fromRGBO(28, 40, 46, 1)
        : Colors.grey[50];

    return AppBackground(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: AppTopBar(
            title: AppLocalizations.of(context)!.navFood,
            backgroundColor: Colors.transparent,
            textColor: textColor,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.of(context)!.food_location,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _zipCodeController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white,
                    labelText: AppLocalizations.of(
                      context,
                    )!.food_postcode_label,
                    labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.location_on, color: movieBlue),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.keyboard_hide),
                      onPressed: () => FocusScope.of(context).unfocus(),
                      color: movieBlue.withOpacity(0.6),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.white12 : Colors.grey[300]!,
                      ),
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
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.food_diet,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.food_diet_info,
                            ),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.info_outline,
                        size: 18,
                        color: textColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: _filterOptions.map((filter) {
                    final bool isSelected = _selectedFilter == filter['slug'];
                    final textColorLocal =
                        MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
                        ? Colors.white
                        : Colors.black87;
                    final loc = AppLocalizations.of(context)!;
                    String labelText;
                    switch (filter['slug']) {
                      case 'vegetarian':
                        labelText = loc.filter_vegetarian;
                        break;
                      case 'vegan':
                        labelText = loc.filter_vegan;
                        break;
                      case 'gluten-free-options':
                        labelText = loc.filter_gluten_free;
                        break;
                      default:
                        labelText = loc.filter_halal;
                    }

                    return FilterChip(
                      label: Text(labelText),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : textColorLocal, // Adjusted for adaptive text color
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      selected: isSelected,
                      backgroundColor:
                          MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? Colors.white.withOpacity(0.05)
                          : movieBlue.withOpacity(0.08),
                      selectedColor: movieBlue,
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : movieBlue.withOpacity(0.2),
                        ),
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
                  child: Divider(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.food_hold_to_edit,
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_quickChoices.length, (index) {
                    final loc = AppLocalizations.of(context)!;
                    final item = _quickChoices[index];
                    String displayName =
                        item['name'] ??
                        (item['key'] == 'pizza'
                            ? loc.food_quick_pizza
                            : item['key'] == 'sushi'
                            ? loc.food_quick_sushi
                            : item['key'] == 'burger'
                            ? loc.food_quick_burger
                            : loc.food_quick_kapsalon);

                    return GestureDetector(
                      onTap: () => _orderFood(displayName),
                      onLongPress: () => _editFavorite(index),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: movieBlue.withOpacity(
                              isDark ? 0.2 : 0.1,
                            ),
                            child: Text(
                              item['emoji']!,
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
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
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white,
                    labelText: AppLocalizations.of(context)!.food_search_hint,
                    labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark ? Colors.white12 : Colors.grey[300]!,
                      ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () => _orderFood(),
                  child: Text(
                    AppLocalizations.of(context)!.food_search_button,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
