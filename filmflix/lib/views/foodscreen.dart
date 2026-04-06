import 'package:cinetrackr/l10n/app_localizations.dart'; // Importeert localisatie voor meerdere talen
import 'package:flutter/material.dart'; // Importeert Flutter Material Design
import 'package:flutter/services.dart'; // Importeert input formatters en services
import 'package:url_launcher/url_launcher.dart'; // Importeert URL launcher voor externe links
import 'package:cinetrackr/widgets/app_top_bar.dart'; // Importeert custom top bar widget
import 'package:cinetrackr/widgets/app_background.dart'; // Importeert custom background widget

class FoodScreen extends StatefulWidget {
  // Definieert stateful widget voor voedsel scherm
  const FoodScreen({super.key}); // Constructor met key parameter

  @override
  State<FoodScreen> createState() => _FoodScreenState(); // Maakt state instance aan
}

class _FoodScreenState extends State<FoodScreen> {
  // Bevat mutable state van FoodScreen
  final TextEditingController _foodController =
      TextEditingController(); // Controller voor voedsel input
  final TextEditingController _zipCodeController =
      TextEditingController(); // Controller voor postcode input

  final Color movieBlue = const Color.fromRGBO(
    43,
    77,
    91,
    1,
  ); // Definiëert primaire blauwe kleur
  final Color movieBlueLight = const Color.fromRGBO(
    43,
    77,
    91,
    0.1,
  ); // Definiëert lichte blauwe variant
  final Color dieetwensen = const Color.fromARGB(
    255,
    255,
    255,
    255,
  ); // Definiëert witte kleur (ongebruikt)
  String? _selectedFilter; // Slaat geselecteerde dieetfilter op

  final List<Map<String, String>> _filterOptions = [
    // Array met beschikbare dieetfilters
    {'slug': 'vegetarian'},
    {'slug': 'vegan'},
    {'slug': 'gluten-free-options'},
    {'slug': 'halal'},
  ];

  List<Map<String, String?>> _quickChoices = [
    // Array met snelkeuze voedselitems met emoji's
    {'key': 'pizza', 'name': null, 'emoji': '🍕'},
    {'key': 'sushi', 'name': null, 'emoji': '🍣'},
    {'key': 'burger', 'name': null, 'emoji': '🍔'},
    {'key': 'kapsalon', 'name': null, 'emoji': '🍟'},
  ];

  Color _getAdaptiveTextColor(BuildContext context) {
    // Bepaalt tekstkleur op basis van dark/light mode
    return MediaQuery.of(context).platformBrightness ==
            Brightness
                .dark // Controleert of donker thema actief is
        ? Colors.white
        : Colors.black87;
  }

  void _editFavorite(int index) {
    // Opent dialoog voor bewerken van favoriete voedselitem
    final isDark =
        MediaQuery.of(context).platformBrightness ==
        Brightness.dark; // Controleert dark mode
    final loc = AppLocalizations.of(context)!; // Haalt localisatie op
    final localizedDefault = // Bepaalt gelokaliseerde naam voor het item
        _quickChoices[index]['name'] ??
        (_quickChoices[index]['key'] == 'pizza'
            ? loc.food_quick_pizza
            : _quickChoices[index]['key'] == 'sushi'
            ? loc.food_quick_sushi
            : _quickChoices[index]['key'] == 'burger'
            ? loc.food_quick_burger
            : loc.food_quick_kapsalon);
    final nameEditController = TextEditingController(
      text: localizedDefault,
    ); // Controller voor naam input
    final emojiEditController = TextEditingController(
      // Controller voor emoji input
      text: _quickChoices[index]['emoji'],
    );

    showDialog(
      // Toont dialoog voor bewerken
      context: context,
      builder: (context) => AlertDialog(
        // Bouwt AlertDialog widget
        backgroundColor:
            isDark // Zet achtergrondkleur op basis van thema
            ? const Color.fromRGBO(28, 40, 46, 1)
            : Colors.white,
        title: Text(
          // Dialoog titel
          loc.food_edit_favorite,
          style: TextStyle(color: _getAdaptiveTextColor(context)),
        ),
        content: Column(
          // Inhoud met twee tekstinputs
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              // Invoerveld voor naam
              controller: nameEditController,
              style: TextStyle(color: _getAdaptiveTextColor(context)),
              decoration: InputDecoration(
                // Stijl voor naamveld
                labelText: loc.food_name_label,
                labelStyle: TextStyle(
                  color: _getAdaptiveTextColor(context).withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 15), // Spacer tussen velden
            TextField(
              // Invoerveld voor emoji
              controller: emojiEditController,
              style: const TextStyle(fontSize: 30),
              decoration: InputDecoration(
                // Stijl voor emojiveld
                labelText: loc.food_only_emoji,
                labelStyle: TextStyle(
                  color: _getAdaptiveTextColor(context).withOpacity(0.6),
                ),
                counterText: "", // Verbergt karakterteller
              ),
              textAlign: TextAlign.center,
              maxLength: 1, // Limiteert op 1 karakter
              inputFormatters: [
                // Alleen emoji's toestaan
                FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z0-9\s]')),
              ],
            ),
          ],
        ),
        actions: [
          // Dialoog knoppen
          TextButton(
            // Annuleer knop
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel, style: TextStyle(color: movieBlue)),
          ),
          ElevatedButton(
            // Opslaan knop
            style: ElevatedButton.styleFrom(backgroundColor: movieBlue),
            onPressed: () {
              // Slaat wijzigingen op
              if (emojiEditController.text.isNotEmpty) {
                // Controleert of emoji niet leeg is
                setState(() {
                  // Update state
                  _quickChoices[index] = {
                    // Werkt favoriete item bij
                    'key': _quickChoices[index]['key']!,
                    'name': nameEditController.text.trim(),
                    'emoji': emojiEditController.text.trim(),
                  };
                });
                Navigator.pop(context); // Sluit dialoog
              }
            },
            child: Text(loc.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _orderFood([String? manualFood]) async {
    // Bestelfunctie met optionele voedselwaarde
    final String food =
        manualFood ??
        _foodController.text.trim(); // Haalt voedsel op uit parameter of input
    final String zipDigits = _zipCodeController.text.replaceAll(
      // Haalt alleen cijfers uit postcode
      RegExp(r'[^0-9]'),
      '',
    );

    if (zipDigits.length < 4) {
      // Controleert of postcode voldoende lang is
      ScaffoldMessenger.of(context).showSnackBar(
        // Toont foutbericht
        SnackBar(
          content: Text(AppLocalizations.of(context)!.food_zip_required),
        ),
      );
      return; // Beëindigt functie
    }

    if (food.isEmpty) {
      // Controleert of voedsel niet leeg is
      ScaffoldMessenger.of(context).showSnackBar(
        // Toont foutbericht
        SnackBar(
          content: Text(AppLocalizations.of(context)!.food_what_do_you_want),
        ),
      );
      return; // Beëindigt functie
    }

    String urlString = // Bouwt URL voor thuisbezorgd.nl
        'https://www.thuisbezorgd.nl/bestellen/eten/$zipDigits?q=$food';
    if (_selectedFilter != null) {
      // Voegt filter toe als geselecteerd
      urlString += '&filter=$_selectedFilter';
    }

    final Uri url = Uri.parse(urlString); // Parsed URL string
    try {
      // Probeert URL te openen in in-app WebView (voorkomt openen native app)
      await launchUrl(url, mode: LaunchMode.inAppWebView);
    } catch (e) {
      // Vangt fouten op
      debugPrint('Fout bij openen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bouwt UI
    final isDark =
        MediaQuery.of(context).platformBrightness ==
        Brightness.dark; // Controleert dark mode
    final textColor = _getAdaptiveTextColor(context); // Bepaalt tekstkleur
    final scaffoldBg =
        isDark // Bepaalt achtergrondkleur scaffold
        ? const Color.fromRGBO(28, 40, 46, 1)
        : Colors.grey[50];

    return AppBackground(
      // Wrapper met achtergrond
      child: Scaffold(
        // Hoofd layout
        extendBodyBehindAppBar: true, // Laat body achter AppBar uitsteken
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          // Custom top bar
          preferredSize: const Size.fromHeight(56),
          child: AppTopBar(
            title: AppLocalizations.of(context)!.navFood,
            backgroundColor: Colors.transparent,
            textColor: textColor,
          ),
        ),
        body: SafeArea(
          // Veilig gebied zonder notch/appbar
          child: SingleChildScrollView(
            // Scrollbaar scherm
            padding: const EdgeInsets.all(20.0),
            child: Column(
              // Hoofd kolom
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  // Locatietitel
                  AppLocalizations.of(context)!.food_location,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10), // Spacer
                TextField(
                  // Postcode invoerveld
                  controller: _zipCodeController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    // Stijl postcode veld
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
                      // Verbergt toetsenbord
                      icon: const Icon(Icons.keyboard_hide),
                      onPressed: () => FocusScope.of(context).unfocus(),
                      color: movieBlue.withOpacity(0.6),
                    ),
                    enabledBorder: OutlineInputBorder(
                      // Rand normaal staat
                      borderSide: BorderSide(
                        color: isDark ? Colors.white12 : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      // Rand gefocust staat
                      borderSide: BorderSide(color: movieBlue, width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    // Alleen nummers toestaan
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
                const SizedBox(height: 25), // Spacer
                Row(
                  // Rij met dieet titel en info knop
                  children: [
                    Text(
                      // Dieet titel
                      AppLocalizations.of(context)!.food_diet,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 4), // Kleine spacer
                    GestureDetector(
                      // Info knop
                      onTap: () {
                        // Toont informatie snackbar
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
                        // Info icoon
                        Icons.info_outline,
                        size: 18,
                        color: textColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Spacer
                Wrap(
                  // Rij die aflopt naar volgende regel
                  spacing: 10,
                  children: _filterOptions.map((filter) {
                    // Map filter opties naar widgets
                    final bool isSelected =
                        _selectedFilter ==
                        filter['slug']; // Controleert selectie
                    final textColorLocal = // Bepaalt lokale tekstkleur
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87;
                    final loc = AppLocalizations.of(
                      context,
                    )!; // Haalt localisatie
                    String labelText; // Declareer label
                    switch (filter['slug']) {
                      // Switch op filter type
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
                      // Chip widget voor filter
                      label: Text(labelText),
                      labelStyle: TextStyle(
                        // Stijl label
                        color: isSelected ? Colors.white : textColorLocal,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      selected: isSelected,
                      backgroundColor: // Achtergrond kleur
                          MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? Colors.white.withOpacity(0.05)
                          : movieBlue.withOpacity(0.08),
                      selectedColor: movieBlue,
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        // Vorm rand
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : movieBlue.withOpacity(0.2),
                        ),
                      ),
                      onSelected: (bool selected) {
                        // Afhandeling selectie
                        setState(() {
                          _selectedFilter = selected ? filter['slug'] : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                Padding(
                  // Padding rond divider
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Divider(
                    // Scheidingslijn
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
                Text(
                  // Instructie voor bewerken
                  AppLocalizations.of(context)!.food_hold_to_edit,
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15), // Spacer
                Row(
                  // Rij met snelkeuzes
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_quickChoices.length, (index) {
                    // Genereert snelkeuze items
                    final loc = AppLocalizations.of(
                      context,
                    )!; // Haalt localisatie
                    final item = _quickChoices[index]; // Haalt item op
                    String displayName = // Bepaalt weergegeven naam
                        item['name'] ??
                        (item['key'] == 'pizza'
                            ? loc.food_quick_pizza
                            : item['key'] == 'sushi'
                            ? loc.food_quick_sushi
                            : item['key'] == 'burger'
                            ? loc.food_quick_burger
                            : loc.food_quick_kapsalon);

                    return GestureDetector(
                      // Responsief item
                      onTap: () => _orderFood(displayName), // Bestellen bij tap
                      onLongPress: () =>
                          _editFavorite(index), // Bewerk bij long press
                      child: Column(
                        // Kolom met emoji en naam
                        children: [
                          CircleAvatar(
                            // Cirkel met emoji
                            radius: 30,
                            backgroundColor: movieBlue.withOpacity(
                              isDark ? 0.2 : 0.1,
                            ),
                            child: Text(
                              // Emoji tekst
                              item['emoji']!,
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                          const SizedBox(height: 8), // Spacer
                          Text(
                            // Item naam
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
                const SizedBox(height: 35), // Grote spacer
                TextField(
                  // Zoek invoerveld
                  controller: _foodController,
                  style: TextStyle(color: textColor),
                  onSubmitted: (_) => _orderFood(),
                  decoration: InputDecoration(
                    // Stijl zoek veld
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white,
                    labelText: AppLocalizations.of(context)!.food_search_hint,
                    labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
                    enabledBorder: OutlineInputBorder(
                      // Rand normaal staat
                      borderSide: BorderSide(
                        color: isDark ? Colors.white12 : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      // Rand gefocust staat
                      borderSide: BorderSide(color: movieBlue, width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search, color: movieBlue),
                      onPressed: () => _orderFood(),
                      tooltip: AppLocalizations.of(context)!.food_search_button,
                    ), // Zoek icoon (klikbaar)
                  ),
                ),
                const SizedBox(height: 25), // Spacer
                ElevatedButton(
                  // Bestellen knop
                  style: ElevatedButton.styleFrom(
                    // Stijl knop
                    backgroundColor: movieBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: isDark ? 4 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () => _orderFood(), // Bestellen bij druk
                  child: Text(
                    // Knop tekst
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
