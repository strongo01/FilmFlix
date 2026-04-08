import 'package:cinetrackr/l10n/app_localizations.dart'; // Importeert localisatie voor meerdere talen
import 'package:flutter/material.dart'; // Importeert Flutter Material Design
import 'package:flutter/services.dart'; // Importeert input formatters en services
import 'package:url_launcher/url_launcher.dart'; // Importeert URL launcher voor externe links
import 'package:cinetrackr/widgets/app_top_bar.dart'; // Importeert custom top bar widget
import 'package:cinetrackr/widgets/app_background.dart'; // Importeert custom background widget
import 'package:cinetrackr/main.dart'; // Importeert MainNavigation
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:cinetrackr/services/tutorial_service.dart';

class FoodScreen extends StatefulWidget {
  static final GlobalKey<_FoodScreenState> foodScreenKey =
      GlobalKey<_FoodScreenState>();
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

  final GlobalKey _zipCodeKey = GlobalKey();
  final GlobalKey _dietKey = GlobalKey();
  final GlobalKey _quickChoicesKey = GlobalKey();
  final GlobalKey _searchFoodKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    startFoodScreenTutorial();
  }

  @override
  void didUpdateWidget(FoodScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    startFoodScreenTutorial();
  }

  void startFoodScreenTutorial({bool force = false}) async {
    debugPrint("startFoodScreenTutorial called with force=$force");
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('tutorial_done_food_screen') ?? false;

    if (done && !force) return;

    _tryStart(prefs, force, 0);
  }

  void _tryStart(SharedPreferences prefs, bool force, int attempts) {
    debugPrint("Food _tryStart: attempts=$attempts, force=$force");
    if (!mounted) {
      debugPrint("Food _tryStart: not mounted, aborting.");
      return;
    }
    if (attempts > 10) {
      debugPrint("Food _tryStart: max attempts reached, aborting.");
      return;
    }

    final isCurrentScreen =
        (MainNavigation.mainKey.currentState as dynamic)?.currentScreenId == 3;
    debugPrint("Food _tryStart: isCurrentScreen=$isCurrentScreen");
    if (!isCurrentScreen && !force) {
      // If we switched away or not yet switched, stop retrying unless force
      debugPrint(
        "Food _tryStart: Not current screen and not forced, aborting.",
      );
      return;
    }

    // Check if the essential targets have a context and render box.
    final zipCtx = _zipCodeKey.currentContext;
    final dietCtx = _dietKey.currentContext;
    final quickCtx = _quickChoicesKey.currentContext;
    final searchCtx = _searchFoodKey.currentContext;

    bool zipReady = zipCtx != null && zipCtx.findRenderObject() != null;
    bool dietReady = dietCtx != null && dietCtx.findRenderObject() != null;
    bool quickReady = quickCtx != null && quickCtx.findRenderObject() != null;
    bool searchReady =
        searchCtx != null && searchCtx.findRenderObject() != null;

    debugPrint(
      "Food _tryStart: zipReady=$zipReady, dietReady=$dietReady, quickReady=$quickReady, searchReady=$searchReady",
    );

    if (!zipReady || !dietReady || !quickReady || !searchReady) {
      debugPrint("Food _tryStart: waiting for UI elements, retrying...");
      Future.delayed(
        const Duration(milliseconds: 200),
        () => _tryStart(prefs, force, attempts + 1),
      );
      return;
    }

    final loc = AppLocalizations.of(context);
    if (loc != null) {
      debugPrint("Food _tryStart: Elements ready, triggering tutorial.");
      _showFoodTutorialTargets(loc, prefs, force);
    }
  }

  void _showFoodTutorialTargets(
    AppLocalizations loc,
    SharedPreferences prefs,
    bool force,
  ) {
    List<TargetFocus> targets = [
      TutorialService.createTarget(
        identify: "food-zip",
        key: _zipCodeKey,
        text: loc.tutorialFoodZip,
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
      TutorialService.createTarget(
        identify: "food-diet",
        key: _dietKey,
        text: loc.tutorialFoodDiet,
        align: ContentAlign.bottom,
      ),
      TutorialService.createTarget(
        identify: "food-quick",
        key: _quickChoicesKey,
        text: loc.tutorialFoodQuick,
        align: ContentAlign.top,
      ),
      TutorialService.createTarget(
        identify: "food-search",
        key: _searchFoodKey,
        text: loc.tutorialFoodSearch,
        align: ContentAlign.top,
        shape: ShapeLightFocus.RRect,
      ),
    ];

    TutorialService.checkAndShowTutorial(
      context,
      tutorialKey: force ? 'force_food_screen_tut' : 'food_screen',
      targets: targets,
      onFinish: () async {
        await prefs.setBool('tutorial_done_food_screen', true);
      },
      onSkip: () async {
        await prefs.setBool('tutorial_done_food_screen', true);
      },
    );
  }

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

      if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
        // Fall back naar externe browser als webview niet ondersteund
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
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
                  key: _zipCodeKey, // Key add to zipcode
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
                  key: _dietKey,
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

                    return Theme(
                      data: Theme.of(context).copyWith(
                        // Disable the default colored splash/highlight on release
                        // and use no splash to avoid the brief red flash.
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: FilterChip(
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
                                ? movieBlue.withOpacity(0.0)
                                : movieBlue.withOpacity(0.2),
                          ),
                        ),
                        onSelected: (bool selected) {
                          // Afhandeling selectie
                          setState(() {
                            _selectedFilter = selected ? filter['slug'] : null;
                          });
                        },
                      ),
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
                  key: _quickChoicesKey,
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
                  key: _searchFoodKey,
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
