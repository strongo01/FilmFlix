import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('nl'),
    Locale('tr')
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @myDashboard.
  ///
  /// In en, this message translates to:
  /// **'My Dashboard'**
  String get myDashboard;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Snackbar shown when notifications were enabled
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notifications_enabled;

  /// Message instructing user to open system settings for notifications
  ///
  /// In en, this message translates to:
  /// **'Check System Settings to allow notifications.'**
  String get notifications_check_system;

  /// Snackbar shown when FCM registration failed
  ///
  /// In en, this message translates to:
  /// **'Registering for notifications failed.'**
  String get notifications_registration_failed;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Name of the English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @dutch.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get dutch;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get nameLabel;

  /// No description provided for @nameValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get nameValidation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @mustBeLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to change your name'**
  String get mustBeLoggedIn;

  /// No description provided for @profile_default_name.
  ///
  /// In en, this message translates to:
  /// **'Kevin le Goat'**
  String get profile_default_name;

  /// Fallback example email shown in profile card
  ///
  /// In en, this message translates to:
  /// **'kevinlegoat@example.com'**
  String get profile_default_email;

  /// Label for number of films watched
  ///
  /// In en, this message translates to:
  /// **'Films watched'**
  String get filmsDone;

  /// No description provided for @watchlist_label.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get watchlist_label;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @customerService_title.
  ///
  /// In en, this message translates to:
  /// **'Customer Service'**
  String get customerService_title;

  /// Title of the About screen
  ///
  /// In en, this message translates to:
  /// **'About CineTrackr'**
  String get aboutTitle;

  /// Long about text shown in the About screen
  ///
  /// In en, this message translates to:
  /// **'CineTrackr\n\nWelcome to CineTrackr, your personal guide for movies and cinema visits.\n\nWith CineTrackr you can easily view movie schedules, keep your own watchlist and quickly access cinema locations and customer service.\n\nThanks for using CineTrackr — enjoy watching!'**
  String get aboutText;

  /// Label for the privacy policy link
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @loginIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginIn;

  /// No description provided for @nameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated'**
  String get nameUpdated;

  /// No description provided for @nameUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get nameUpdateFailed;

  /// No description provided for @admin_title.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin_title;

  /// No description provided for @tab_chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get tab_chats;

  /// No description provided for @tab_faqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get tab_faqs;

  /// No description provided for @not_logged_in_title.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get not_logged_in_title;

  /// No description provided for @not_logged_in_message.
  ///
  /// In en, this message translates to:
  /// **'Please sign in as admin and try again.'**
  String get not_logged_in_message;

  /// No description provided for @no_users_doc.
  ///
  /// In en, this message translates to:
  /// **'No users doc found.'**
  String get no_users_doc;

  /// No description provided for @users_doc_role.
  ///
  /// In en, this message translates to:
  /// **'users/{uid} role = {role}'**
  String users_doc_role(Object role, Object uid);

  /// No description provided for @users_doc_no_role.
  ///
  /// In en, this message translates to:
  /// **'users/{uid} exists but has no role field.'**
  String users_doc_no_role(Object uid);

  /// No description provided for @users_doc_read_error.
  ///
  /// In en, this message translates to:
  /// **'Error reading users doc: {error}'**
  String users_doc_read_error(Object error);

  /// No description provided for @send_failed.
  ///
  /// In en, this message translates to:
  /// **'Send failed'**
  String get send_failed;

  /// No description provided for @check_permissions_title.
  ///
  /// In en, this message translates to:
  /// **'Check permissions'**
  String get check_permissions_title;

  /// No description provided for @possible_causes.
  ///
  /// In en, this message translates to:
  /// **'Possible causes and fixes:'**
  String get possible_causes;

  /// No description provided for @firestore_rules.
  ///
  /// In en, this message translates to:
  /// **'- Check Firestore rules: using custom claims (request.auth.token.role).'**
  String get firestore_rules;

  /// No description provided for @custom_claims_hint.
  ///
  /// In en, this message translates to:
  /// **'- If using custom claims: set role/admin via Admin SDK and have admin re-login.'**
  String get custom_claims_hint;

  /// No description provided for @rules_temp_change.
  ///
  /// In en, this message translates to:
  /// **'- Or temporarily change rules to read role from /users/{uid}.'**
  String rules_temp_change(Object uid);

  /// No description provided for @current_users_doc.
  ///
  /// In en, this message translates to:
  /// **'Current users doc:'**
  String get current_users_doc;

  /// No description provided for @debug_info_title.
  ///
  /// In en, this message translates to:
  /// **'Debug info'**
  String get debug_info_title;

  /// No description provided for @uid_label.
  ///
  /// In en, this message translates to:
  /// **'uid: {uid}'**
  String uid_label(Object uid);

  /// No description provided for @idtoken_claims_label.
  ///
  /// In en, this message translates to:
  /// **'idToken claims: {claims}'**
  String idtoken_claims_label(Object claims);

  /// No description provided for @idtoken_error_label.
  ///
  /// In en, this message translates to:
  /// **'idToken error: {error}'**
  String idtoken_error_label(Object error);

  /// No description provided for @users_doc_label.
  ///
  /// In en, this message translates to:
  /// **'users doc: {doc}'**
  String users_doc_label(Object doc);

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @fetch_doc_title.
  ///
  /// In en, this message translates to:
  /// **'Fetch document by ID'**
  String get fetch_doc_title;

  /// No description provided for @paste_doc_id.
  ///
  /// In en, this message translates to:
  /// **'Paste the document ID from customerquestions:'**
  String get paste_doc_id;

  /// No description provided for @fetch.
  ///
  /// In en, this message translates to:
  /// **'Fetch'**
  String get fetch;

  /// No description provided for @not_found_title.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get not_found_title;

  /// No description provided for @document_not_found.
  ///
  /// In en, this message translates to:
  /// **'Document {id} does not exist or is not readable.'**
  String document_not_found(Object id);

  /// No description provided for @document_title.
  ///
  /// In en, this message translates to:
  /// **'Document {id}'**
  String document_title(Object id);

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'<empty>'**
  String get empty;

  /// No description provided for @fetch_error_title.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get fetch_error_title;

  /// No description provided for @fetch_error_message.
  ///
  /// In en, this message translates to:
  /// **'Error fetching: {error}'**
  String fetch_error_message(Object error);

  /// No description provided for @cannot_load_chats.
  ///
  /// In en, this message translates to:
  /// **'Cannot load chats: {error}'**
  String cannot_load_chats(Object error);

  /// No description provided for @no_questions_found.
  ///
  /// In en, this message translates to:
  /// **'No questions found'**
  String get no_questions_found;

  /// No description provided for @show_debug_info.
  ///
  /// In en, this message translates to:
  /// **'Show debug info'**
  String get show_debug_info;

  /// No description provided for @delete_chat_title.
  ///
  /// In en, this message translates to:
  /// **'Delete chat'**
  String get delete_chat_title;

  /// No description provided for @delete_chat_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this chat? This cannot be undone.'**
  String get delete_chat_confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @chat_deleted.
  ///
  /// In en, this message translates to:
  /// **'Chat deleted'**
  String get chat_deleted;

  /// No description provided for @delete_failed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get delete_failed;

  /// No description provided for @marked_unread.
  ///
  /// In en, this message translates to:
  /// **'Marked as unread'**
  String get marked_unread;

  /// No description provided for @action_failed.
  ///
  /// In en, this message translates to:
  /// **'Action failed'**
  String get action_failed;

  /// No description provided for @user_label_default.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user_label_default;

  /// No description provided for @reply_hint.
  ///
  /// In en, this message translates to:
  /// **'Type a reply...'**
  String get reply_hint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @notify_title.
  ///
  /// In en, this message translates to:
  /// **'New message from admin'**
  String get notify_title;

  /// No description provided for @notify_body.
  ///
  /// In en, this message translates to:
  /// **'{text}'**
  String notify_body(Object text);

  /// No description provided for @no_faq_items.
  ///
  /// In en, this message translates to:
  /// **'No FAQ items yet'**
  String get no_faq_items;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @add_new_faq.
  ///
  /// In en, this message translates to:
  /// **'Add new FAQ'**
  String get add_new_faq;

  /// No description provided for @new_faq_title.
  ///
  /// In en, this message translates to:
  /// **'New FAQ'**
  String get new_faq_title;

  /// No description provided for @question_label.
  ///
  /// In en, this message translates to:
  /// **'Question/Comment'**
  String get question_label;

  /// No description provided for @answer_label.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answer_label;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @faq_added.
  ///
  /// In en, this message translates to:
  /// **'FAQ added'**
  String get faq_added;

  /// No description provided for @faq_add_failed.
  ///
  /// In en, this message translates to:
  /// **'Add failed'**
  String get faq_add_failed;

  /// No description provided for @edit_faq_title.
  ///
  /// In en, this message translates to:
  /// **'Edit FAQ'**
  String get edit_faq_title;

  /// No description provided for @faq_updated.
  ///
  /// In en, this message translates to:
  /// **'FAQ updated'**
  String get faq_updated;

  /// No description provided for @faq_update_failed.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get faq_update_failed;

  /// No description provided for @delete_faq_title.
  ///
  /// In en, this message translates to:
  /// **'Delete FAQ'**
  String get delete_faq_title;

  /// No description provided for @delete_faq_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this FAQ?'**
  String get delete_faq_confirm;

  /// No description provided for @faq_deleted.
  ///
  /// In en, this message translates to:
  /// **'FAQ deleted'**
  String get faq_deleted;

  /// No description provided for @faq_delete_failed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get faq_delete_failed;

  /// No description provided for @admins_label.
  ///
  /// In en, this message translates to:
  /// **'Admins: {names}'**
  String admins_label(Object names);

  /// No description provided for @chat_page_title_prefix.
  ///
  /// In en, this message translates to:
  /// **'Chat: {prefix}'**
  String chat_page_title_prefix(Object prefix);

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CineTrackr'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get navWatchlist;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get navFood;

  /// No description provided for @navigationReorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder navigation'**
  String get navigationReorder;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @infoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get infoTooltip;

  /// No description provided for @watchlistInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get watchlistInfoTitle;

  /// No description provided for @watchlistInfoContent.
  ///
  /// In en, this message translates to:
  /// **'The app cannot fetch data from streaming services. You can manually check off episodes you\'ve watched.'**
  String get watchlistInfoContent;

  /// No description provided for @tutorialHome.
  ///
  /// In en, this message translates to:
  /// **'Welcome! Here are the latest movies and series.'**
  String get tutorialHome;

  /// No description provided for @tutorialWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Save your favorite movies here for later.'**
  String get tutorialWatchlist;

  /// No description provided for @tutorialSearch.
  ///
  /// In en, this message translates to:
  /// **'Search for titles or genres.'**
  String get tutorialSearch;

  /// No description provided for @tutorialFood.
  ///
  /// In en, this message translates to:
  /// **'See matching snacks for your movie night!'**
  String get tutorialFood;

  /// No description provided for @tutorialProfile.
  ///
  /// In en, this message translates to:
  /// **'Manage your profile and settings here.'**
  String get tutorialProfile;

  /// No description provided for @tutorialNavBar.
  ///
  /// In en, this message translates to:
  /// **'Here you can switch screens. Long-press a button to reorder pages.'**
  String get tutorialNavBar;

  /// No description provided for @tutorialHomeExtra.
  ///
  /// In en, this message translates to:
  /// **'On the Home screen you see latest releases and recommendations.'**
  String get tutorialHomeExtra;

  /// No description provided for @tutorialWatchlistExtra.
  ///
  /// In en, this message translates to:
  /// **'In your Watchlist you can remove films or mark them to watch later.'**
  String get tutorialWatchlistExtra;

  /// No description provided for @tutorialSearchExtra.
  ///
  /// In en, this message translates to:
  /// **'Use the search bar to quickly find titles and actors.'**
  String get tutorialSearchExtra;

  /// No description provided for @tutorialFoodExtra.
  ///
  /// In en, this message translates to:
  /// **'Find snacks and recipes that match your movie choice.'**
  String get tutorialFoodExtra;

  /// No description provided for @tutorialProfileExtra.
  ///
  /// In en, this message translates to:
  /// **'Manage settings, preferences and account details in your profile.'**
  String get tutorialProfileExtra;

  /// No description provided for @tutorialMap.
  ///
  /// In en, this message translates to:
  /// **'View the map to find nearby cinemas!'**
  String get tutorialMap;

  /// AppBar title for the cinemas map
  ///
  /// In en, this message translates to:
  /// **'Cinemas in the Netherlands'**
  String get map_all_cinemas_title;

  /// No description provided for @map_load_error.
  ///
  /// In en, this message translates to:
  /// **'Error loading cinemas: {error}'**
  String map_load_error(Object error);

  /// No description provided for @map_location_service_disabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled'**
  String get map_location_service_disabled;

  /// No description provided for @map_location_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Location access denied'**
  String get map_location_permission_denied;

  /// No description provided for @map_location_permission_denied_forever.
  ///
  /// In en, this message translates to:
  /// **'Location permissions permanently denied. Enable in settings.'**
  String get map_location_permission_denied_forever;

  /// No description provided for @map_location_fetch_error.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch location: {error}'**
  String map_location_fetch_error(Object error);

  /// No description provided for @map_no_website_content.
  ///
  /// In en, this message translates to:
  /// **'No website available — Cinema found! 🎥'**
  String get map_no_website_content;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @food_edit_favorite.
  ///
  /// In en, this message translates to:
  /// **'Edit favorite'**
  String get food_edit_favorite;

  /// No description provided for @food_name_label.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get food_name_label;

  /// No description provided for @food_only_emoji.
  ///
  /// In en, this message translates to:
  /// **'Emoji only'**
  String get food_only_emoji;

  /// No description provided for @food_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get food_location;

  /// No description provided for @food_diet.
  ///
  /// In en, this message translates to:
  /// **'Dietary preference'**
  String get food_diet;

  /// No description provided for @food_diet_info.
  ///
  /// In en, this message translates to:
  /// **'Note: Availability of restaurants with specific dietary options may vary by region.'**
  String get food_diet_info;

  /// No description provided for @food_hold_to_edit.
  ///
  /// In en, this message translates to:
  /// **'Long press an icon to edit'**
  String get food_hold_to_edit;

  /// No description provided for @food_quick_pizza.
  ///
  /// In en, this message translates to:
  /// **'Pizza'**
  String get food_quick_pizza;

  /// No description provided for @food_quick_sushi.
  ///
  /// In en, this message translates to:
  /// **'Sushi'**
  String get food_quick_sushi;

  /// No description provided for @food_quick_burger.
  ///
  /// In en, this message translates to:
  /// **'Burger'**
  String get food_quick_burger;

  /// No description provided for @food_quick_kapsalon.
  ///
  /// In en, this message translates to:
  /// **'Kapsalon'**
  String get food_quick_kapsalon;

  /// No description provided for @food_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for something...'**
  String get food_search_hint;

  /// No description provided for @food_search_button.
  ///
  /// In en, this message translates to:
  /// **'SEARCH ON THUISBEZORGD'**
  String get food_search_button;

  /// No description provided for @food_postcode_label.
  ///
  /// In en, this message translates to:
  /// **'ZIP code (4 digits)'**
  String get food_postcode_label;

  /// No description provided for @food_zip_required.
  ///
  /// In en, this message translates to:
  /// **'Enter 4 digits of your ZIP code first!'**
  String get food_zip_required;

  /// No description provided for @filter_vegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get filter_vegetarian;

  /// No description provided for @filter_vegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get filter_vegan;

  /// No description provided for @filter_gluten_free.
  ///
  /// In en, this message translates to:
  /// **'Gluten-free'**
  String get filter_gluten_free;

  /// No description provided for @filter_halal.
  ///
  /// In en, this message translates to:
  /// **'Halal'**
  String get filter_halal;

  /// No description provided for @food_what_do_you_want.
  ///
  /// In en, this message translates to:
  /// **'What do you want to eat?'**
  String get food_what_do_you_want;

  /// No description provided for @tutorialSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get tutorialSkip;

  /// No description provided for @ellipsis.
  ///
  /// In en, this message translates to:
  /// **'...'**
  String get ellipsis;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @changeNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Change your name'**
  String get changeNameTitle;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// Explainer shown when asking the user for their display name
  ///
  /// In en, this message translates to:
  /// **'We use your name to make the app more personal, for example for greetings.'**
  String get enter_name_description;

  /// Button label to save name and continue
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get save_and_continue;

  /// No description provided for @contact_admin_title.
  ///
  /// In en, this message translates to:
  /// **'Contact admin'**
  String get contact_admin_title;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @contactNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get contactNameLabel;

  /// No description provided for @contactQuestionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get contactQuestionLabel;

  /// No description provided for @question_validation.
  ///
  /// In en, this message translates to:
  /// **'Enter your question'**
  String get question_validation;

  /// No description provided for @mustBeLoggedInToSend.
  ///
  /// In en, this message translates to:
  /// **'You must be signed in to send'**
  String get mustBeLoggedInToSend;

  /// No description provided for @question_sent.
  ///
  /// In en, this message translates to:
  /// **'Question sent'**
  String get question_sent;

  /// No description provided for @ai_max_reached.
  ///
  /// In en, this message translates to:
  /// **'You have used the maximum number of AI questions for today. Try again tomorrow.'**
  String get ai_max_reached;

  /// No description provided for @ask_ai_title.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get ask_ai_title;

  /// No description provided for @ai_wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait, this may take up to a minute'**
  String get ai_wait;

  /// No description provided for @ai_answer_title.
  ///
  /// In en, this message translates to:
  /// **'AI Answer'**
  String get ai_answer_title;

  /// No description provided for @ai_answer_title_with_model.
  ///
  /// In en, this message translates to:
  /// **'AI Answer ({model})'**
  String ai_answer_title_with_model(Object model);

  /// No description provided for @ai_failed_all.
  ///
  /// In en, this message translates to:
  /// **'AI request failed for all models.'**
  String get ai_failed_all;

  /// No description provided for @ai_failed.
  ///
  /// In en, this message translates to:
  /// **'AI request failed.'**
  String get ai_failed;

  /// No description provided for @login_required_title.
  ///
  /// In en, this message translates to:
  /// **'Sign-in required'**
  String get login_required_title;

  /// No description provided for @login_required_message.
  ///
  /// In en, this message translates to:
  /// **'You must be signed in to do this. Go to the login screen?'**
  String get login_required_message;

  /// No description provided for @goto_login.
  ///
  /// In en, this message translates to:
  /// **'Go to login'**
  String get goto_login;

  /// No description provided for @search_faqs_hint.
  ///
  /// In en, this message translates to:
  /// **'Search in frequently asked questions'**
  String get search_faqs_hint;

  /// No description provided for @no_faq_matches.
  ///
  /// In en, this message translates to:
  /// **'No FAQ matches'**
  String get no_faq_matches;

  /// No description provided for @ai_questions_used.
  ///
  /// In en, this message translates to:
  /// **'AI questions: {used}/{max} used'**
  String ai_questions_used(Object max, Object used);

  /// No description provided for @ask_ai_with_cooldown.
  ///
  /// In en, this message translates to:
  /// **'Ask AI ({seconds})'**
  String ask_ai_with_cooldown(Object seconds);

  /// No description provided for @contact_admin_button.
  ///
  /// In en, this message translates to:
  /// **'Contact admin'**
  String get contact_admin_button;

  /// No description provided for @my_questions.
  ///
  /// In en, this message translates to:
  /// **'My questions'**
  String get my_questions;

  /// No description provided for @no_questions_sent.
  ///
  /// In en, this message translates to:
  /// **'You have not sent any questions yet.'**
  String get no_questions_sent;

  /// No description provided for @message_sent.
  ///
  /// In en, this message translates to:
  /// **'Message sent'**
  String get message_sent;

  /// No description provided for @followup_title.
  ///
  /// In en, this message translates to:
  /// **'Respond to your question'**
  String get followup_title;

  /// No description provided for @enter_message_hint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get enter_message_hint;

  /// No description provided for @faq_default_account_q.
  ///
  /// In en, this message translates to:
  /// **'How do I create an account?'**
  String get faq_default_account_q;

  /// No description provided for @faq_default_account_a.
  ///
  /// In en, this message translates to:
  /// **'You can register via the profile icon at the top-right of the app. Follow the steps to create a new account.'**
  String get faq_default_account_a;

  /// No description provided for @faq_default_watchlist_q.
  ///
  /// In en, this message translates to:
  /// **'How do I add a movie to my watchlist?'**
  String get faq_default_watchlist_q;

  /// No description provided for @faq_default_watchlist_a.
  ///
  /// In en, this message translates to:
  /// **'Open the movie page and tap the \"Save\" (bookmark icon) to add the movie to your watchlist.'**
  String get faq_default_watchlist_a;

  /// No description provided for @faq_missing_info_q.
  ///
  /// In en, this message translates to:
  /// **'Why is an episode or season missing information?'**
  String get faq_missing_info_q;

  /// No description provided for @faq_missing_info_a.
  ///
  /// In en, this message translates to:
  /// **'Our data comes from external providers; sometimes metadata is missing. Try again later or report it via Contact admin.'**
  String get faq_missing_info_a;

  /// No description provided for @faq_report_bug_q.
  ///
  /// In en, this message translates to:
  /// **'How can I report a bug in the app?'**
  String get faq_report_bug_q;

  /// No description provided for @faq_report_bug_a.
  ///
  /// In en, this message translates to:
  /// **'Use the \"Contact admin\" button below to send an email with a description and screenshots.'**
  String get faq_report_bug_a;

  /// No description provided for @faq_ai_q.
  ///
  /// In en, this message translates to:
  /// **'Can I ask questions to an AI?'**
  String get faq_ai_q;

  /// No description provided for @faq_ai_a.
  ///
  /// In en, this message translates to:
  /// **'Yes — use the \"Ask AI\" button to ask a question. Note that answers are automatically generated.'**
  String get faq_ai_a;

  /// No description provided for @admins_no_push.
  ///
  /// In en, this message translates to:
  /// **'Admins may not receive push notifications'**
  String get admins_no_push;

  /// No description provided for @ai_cooldown_wait.
  ///
  /// In en, this message translates to:
  /// **'Wait {seconds} seconds before using the AI again.'**
  String ai_cooldown_wait(Object seconds);

  /// No description provided for @ai_input_hint.
  ///
  /// In en, this message translates to:
  /// **'Type your question about movies or series here...'**
  String get ai_input_hint;

  /// No description provided for @user_new_message_title.
  ///
  /// In en, this message translates to:
  /// **'New message from user'**
  String get user_new_message_title;

  /// Title for the Now Playing screen
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get nowPlayingTitle;

  /// Snackbar when IMDb ID is not available
  ///
  /// In en, this message translates to:
  /// **'IMDb ID not available for this movie'**
  String get imdbIdUnavailable;

  /// Error message when now playing films failed to load
  ///
  /// In en, this message translates to:
  /// **'Could not load current films.'**
  String get cannot_load_now_playing;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Message when no films are found
  ///
  /// In en, this message translates to:
  /// **'No films found'**
  String get no_films_found;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to CineTrackr'**
  String get loginWelcome;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get loginCreateAccount;

  /// No description provided for @loginName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get loginName;

  /// No description provided for @loginNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get loginNameRequired;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get loginEmailRequired;

  /// No description provided for @loginInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get loginInvalidEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordRequired;

  /// No description provided for @loginPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get loginPasswordTooShort;

  /// No description provided for @loginRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get loginRegister;

  /// No description provided for @loginNoAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'No account yet? Register'**
  String get loginNoAccountRegister;

  /// No description provided for @loginHaveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get loginHaveAccountLogin;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get loginContinueAsGuest;

  /// No description provided for @loginOrDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get loginOrDivider;

  /// No description provided for @loginSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get loginSignInWithGoogle;

  /// No description provided for @loginSignInWithGitHub.
  ///
  /// In en, this message translates to:
  /// **'Sign in with GitHub'**
  String get loginSignInWithGitHub;

  /// No description provided for @loginSignInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get loginSignInWithApple;

  /// No description provided for @loginEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get loginEnterValidEmail;

  /// No description provided for @loginPasswordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get loginPasswordResetEmailSent;

  /// No description provided for @loginPasswordResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send reset email'**
  String get loginPasswordResetFailed;

  /// No description provided for @loginSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get loginSomethingWentWrong;

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authenticationFailed;

  /// No description provided for @loginGithubFailed.
  ///
  /// In en, this message translates to:
  /// **'GitHub login failed'**
  String get loginGithubFailed;

  /// No description provided for @googleIdTokenError.
  ///
  /// In en, this message translates to:
  /// **'Error retrieving Google ID token'**
  String get googleIdTokenError;

  /// No description provided for @googleSignInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in cancelled'**
  String get googleSignInCancelled;

  /// No description provided for @loginErrorCredentialMalformed.
  ///
  /// In en, this message translates to:
  /// **'The supplied credential is malformed or has expired.'**
  String get loginErrorCredentialMalformed;

  /// No description provided for @loginErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This user account has been disabled.'**
  String get loginErrorUserDisabled;

  /// No description provided for @loginErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'We have blocked all requests from this device due to unusual activity. Try again later.'**
  String get loginErrorTooManyRequests;

  /// No description provided for @loginErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is badly formatted.'**
  String get loginErrorInvalidEmail;

  /// No description provided for @loginErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password.'**
  String get loginErrorWrongPassword;

  /// No description provided for @loginErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No user found with this email.'**
  String get loginErrorUserNotFound;

  /// No description provided for @loginErrorAccountExists.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with the same email address but different sign-in credentials.'**
  String get loginErrorAccountExists;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translate;

  /// No description provided for @seen.
  ///
  /// In en, this message translates to:
  /// **'Seen'**
  String get seen;

  /// No description provided for @age_rating.
  ///
  /// In en, this message translates to:
  /// **'Age rating: {rated}'**
  String age_rating(Object rated);

  /// No description provided for @producers_creators.
  ///
  /// In en, this message translates to:
  /// **'Producers / Creators'**
  String get producers_creators;

  /// No description provided for @actors.
  ///
  /// In en, this message translates to:
  /// **'Actors'**
  String get actors;

  /// No description provided for @seasons.
  ///
  /// In en, this message translates to:
  /// **'Seasons: {count}'**
  String seasons(Object count);

  /// No description provided for @episodes.
  ///
  /// In en, this message translates to:
  /// **'Episodes: {count}'**
  String episodes(Object count);

  /// No description provided for @streaming.
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get streaming;

  /// No description provided for @seasons_episodes_title.
  ///
  /// In en, this message translates to:
  /// **'Seasons & Episodes ({count})'**
  String seasons_episodes_title(Object count);

  /// No description provided for @no_seasons_found.
  ///
  /// In en, this message translates to:
  /// **'No seasons found'**
  String get no_seasons_found;

  /// No description provided for @no_episodes_found.
  ///
  /// In en, this message translates to:
  /// **'No episodes found'**
  String get no_episodes_found;

  /// No description provided for @warning_title.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning_title;

  /// No description provided for @warning_bioscoop_content.
  ///
  /// In en, this message translates to:
  /// **'Please close any ads/popups on the website before viewing the agenda.'**
  String get warning_bioscoop_content;

  /// No description provided for @continue_label.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_label;

  /// No description provided for @mark_previous_episodes_title.
  ///
  /// In en, this message translates to:
  /// **'Mark previous episodes?'**
  String get mark_previous_episodes_title;

  /// No description provided for @mark_previous_episodes_message.
  ///
  /// In en, this message translates to:
  /// **'You\'re marking \"{title}\" as seen. Also mark {count} previous episode(s) of season {season} as seen?'**
  String mark_previous_episodes_message(Object count, Object season, Object title);

  /// No description provided for @episodes_marked_seen.
  ///
  /// In en, this message translates to:
  /// **'{count} episodes marked as seen'**
  String episodes_marked_seen(Object count);

  /// No description provided for @watchlist_update_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not update watchlist.'**
  String get watchlist_update_failed;

  /// No description provided for @episode_status_update_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not update episode status.'**
  String get episode_status_update_failed;

  /// No description provided for @movie_seen_update_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not update \"Seen\" status.'**
  String get movie_seen_update_failed;

  /// No description provided for @included_with_subscription.
  ///
  /// In en, this message translates to:
  /// **'Included with subscription'**
  String get included_with_subscription;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @buy_with_price.
  ///
  /// In en, this message translates to:
  /// **'Buy • {price}'**
  String buy_with_price(Object price);

  /// No description provided for @rent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rent;

  /// No description provided for @rent_with_price.
  ///
  /// In en, this message translates to:
  /// **'Rent • {price}'**
  String rent_with_price(Object price);

  /// No description provided for @addon.
  ///
  /// In en, this message translates to:
  /// **'Addon'**
  String get addon;

  /// No description provided for @addon_with_price.
  ///
  /// In en, this message translates to:
  /// **'Addon • {price}'**
  String addon_with_price(Object price);

  /// No description provided for @details_streaming_warning.
  ///
  /// In en, this message translates to:
  /// **'Click to open streaming link'**
  String get details_streaming_warning;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'stars'**
  String get stars;

  /// No description provided for @appleSignInNoIdentityToken.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign-In failed: no identity token returned'**
  String get appleSignInNoIdentityToken;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed'**
  String get googleSignInFailed;

  /// No description provided for @loginErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak.'**
  String get loginErrorWeakPassword;

  /// No description provided for @loginErrorNetworkFailed.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get loginErrorNetworkFailed;

  /// No description provided for @loginErrorRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to continue (recent authentication required).'**
  String get loginErrorRequiresRecentLogin;

  /// No description provided for @avatar_login_prompt.
  ///
  /// In en, this message translates to:
  /// **'Log in to change your profile picture'**
  String get avatar_login_prompt;

  /// No description provided for @invalid_input.
  ///
  /// In en, this message translates to:
  /// **'Invalid input'**
  String get invalid_input;

  /// No description provided for @only_emoji_error.
  ///
  /// In en, this message translates to:
  /// **'Enter only emoji'**
  String get only_emoji_error;

  /// No description provided for @use.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get use;

  /// No description provided for @emoji_input_hint.
  ///
  /// In en, this message translates to:
  /// **'Paste or type an emoji (optional)'**
  String get emoji_input_hint;

  /// No description provided for @edit_avatar_title.
  ///
  /// In en, this message translates to:
  /// **'Edit profile picture'**
  String get edit_avatar_title;

  /// No description provided for @choose_color.
  ///
  /// In en, this message translates to:
  /// **'Choose color'**
  String get choose_color;

  /// No description provided for @choose_emoji_optional.
  ///
  /// In en, this message translates to:
  /// **'Choose emoji (optional)'**
  String get choose_emoji_optional;

  /// No description provided for @your_badges.
  ///
  /// In en, this message translates to:
  /// **'YOUR BADGES'**
  String get your_badges;

  /// No description provided for @account_section.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account_section;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get edit_profile;

  /// No description provided for @films.
  ///
  /// In en, this message translates to:
  /// **'Films'**
  String get films;

  /// No description provided for @badge_level_prefix.
  ///
  /// In en, this message translates to:
  /// **'Lv'**
  String get badge_level_prefix;

  /// No description provided for @badge_adventurer.
  ///
  /// In en, this message translates to:
  /// **'Avonturer'**
  String get badge_adventurer;

  /// No description provided for @badge_horror_king.
  ///
  /// In en, this message translates to:
  /// **'Horror King'**
  String get badge_horror_king;

  /// No description provided for @badge_binge_watcher.
  ///
  /// In en, this message translates to:
  /// **'Binge Watcher'**
  String get badge_binge_watcher;

  /// No description provided for @badge_early_bird.
  ///
  /// In en, this message translates to:
  /// **'Early Bird'**
  String get badge_early_bird;

  /// App version label shown in profile footer
  ///
  /// In en, this message translates to:
  /// **'CineTrackr v1.0.4'**
  String get appVersion;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search series/movie...'**
  String get search_hint;

  /// No description provided for @clear_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear_tooltip;

  /// No description provided for @filter_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter_tooltip;

  /// No description provided for @filter_refine_title.
  ///
  /// In en, this message translates to:
  /// **'Refine filters'**
  String get filter_refine_title;

  /// No description provided for @filter_type_label.
  ///
  /// In en, this message translates to:
  /// **'TYPE'**
  String get filter_type_label;

  /// No description provided for @filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filter_all;

  /// No description provided for @filter_movies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get filter_movies;

  /// No description provided for @filter_series.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get filter_series;

  /// No description provided for @filter_keyword_label.
  ///
  /// In en, this message translates to:
  /// **'KEYWORD'**
  String get filter_keyword_label;

  /// No description provided for @filter_keyword_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Batman, Marvel...'**
  String get filter_keyword_hint;

  /// No description provided for @filter_genres_label.
  ///
  /// In en, this message translates to:
  /// **'GENRES'**
  String get filter_genres_label;

  /// No description provided for @filter_year_from_label.
  ///
  /// In en, this message translates to:
  /// **'YEAR (FROM)'**
  String get filter_year_from_label;

  /// No description provided for @filter_year_to_label.
  ///
  /// In en, this message translates to:
  /// **'YEAR (TO)'**
  String get filter_year_to_label;

  /// No description provided for @filter_min_rating_label.
  ///
  /// In en, this message translates to:
  /// **'MINIMUM RATING (0-100)'**
  String get filter_min_rating_label;

  /// No description provided for @apply_filters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get apply_filters;

  /// No description provided for @tmdb_movie_fetch_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch movie details'**
  String get tmdb_movie_fetch_failed;

  /// No description provided for @no_imdb_for_movie.
  ///
  /// In en, this message translates to:
  /// **'No IMDb ID found for this movie'**
  String get no_imdb_for_movie;

  /// No description provided for @tmdb_movie_fetch_error.
  ///
  /// In en, this message translates to:
  /// **'Error fetching movie details'**
  String get tmdb_movie_fetch_error;

  /// No description provided for @tmdb_series_fetch_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch series details'**
  String get tmdb_series_fetch_failed;

  /// No description provided for @no_imdb_for_series.
  ///
  /// In en, this message translates to:
  /// **'No IMDb ID found for this series'**
  String get no_imdb_for_series;

  /// No description provided for @tmdb_series_fetch_error.
  ///
  /// In en, this message translates to:
  /// **'Error fetching series details'**
  String get tmdb_series_fetch_error;

  /// No description provided for @load_more_results.
  ///
  /// In en, this message translates to:
  /// **'Load more results'**
  String get load_more_results;

  /// No description provided for @best_rated.
  ///
  /// In en, this message translates to:
  /// **'Best Rated'**
  String get best_rated;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @genre_action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get genre_action;

  /// No description provided for @genre_adventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get genre_adventure;

  /// No description provided for @genre_animation.
  ///
  /// In en, this message translates to:
  /// **'Animation'**
  String get genre_animation;

  /// No description provided for @genre_comedy.
  ///
  /// In en, this message translates to:
  /// **'Comedy'**
  String get genre_comedy;

  /// No description provided for @genre_crime.
  ///
  /// In en, this message translates to:
  /// **'Crime'**
  String get genre_crime;

  /// No description provided for @genre_documentary.
  ///
  /// In en, this message translates to:
  /// **'Documentary'**
  String get genre_documentary;

  /// No description provided for @genre_drama.
  ///
  /// In en, this message translates to:
  /// **'Drama'**
  String get genre_drama;

  /// No description provided for @genre_family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get genre_family;

  /// No description provided for @genre_fantasy.
  ///
  /// In en, this message translates to:
  /// **'Fantasy'**
  String get genre_fantasy;

  /// No description provided for @genre_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get genre_history;

  /// No description provided for @genre_horror.
  ///
  /// In en, this message translates to:
  /// **'Horror'**
  String get genre_horror;

  /// No description provided for @genre_music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get genre_music;

  /// No description provided for @genre_mystery.
  ///
  /// In en, this message translates to:
  /// **'Mystery'**
  String get genre_mystery;

  /// No description provided for @genre_news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get genre_news;

  /// No description provided for @genre_reality.
  ///
  /// In en, this message translates to:
  /// **'Reality'**
  String get genre_reality;

  /// No description provided for @genre_romance.
  ///
  /// In en, this message translates to:
  /// **'Romance'**
  String get genre_romance;

  /// No description provided for @genre_scifi.
  ///
  /// In en, this message translates to:
  /// **'Science Fiction'**
  String get genre_scifi;

  /// No description provided for @genre_talk.
  ///
  /// In en, this message translates to:
  /// **'Talk Show'**
  String get genre_talk;

  /// No description provided for @genre_thriller.
  ///
  /// In en, this message translates to:
  /// **'Thriller'**
  String get genre_thriller;

  /// No description provided for @genre_war.
  ///
  /// In en, this message translates to:
  /// **'War'**
  String get genre_war;

  /// No description provided for @genre_western.
  ///
  /// In en, this message translates to:
  /// **'Western'**
  String get genre_western;

  /// No description provided for @login_progress_save_snack.
  ///
  /// In en, this message translates to:
  /// **'Log in to save progress'**
  String get login_progress_save_snack;

  /// No description provided for @progress_update_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not update progress'**
  String get progress_update_failed;

  /// No description provided for @open_details.
  ///
  /// In en, this message translates to:
  /// **'Open details'**
  String get open_details;

  /// No description provided for @label_series.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get label_series;

  /// No description provided for @seen_count.
  ///
  /// In en, this message translates to:
  /// **'Seen: {count}'**
  String seen_count(Object count);

  /// No description provided for @remove_from_watchlist_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove from watchlist'**
  String get remove_from_watchlist_tooltip;

  /// No description provided for @login_manage_watchlist_snack.
  ///
  /// In en, this message translates to:
  /// **'Log in to manage your watchlist'**
  String get login_manage_watchlist_snack;

  /// No description provided for @item_removed_watchlist.
  ///
  /// In en, this message translates to:
  /// **'Item removed from watchlist'**
  String get item_removed_watchlist;

  /// No description provided for @remove_item_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not remove item'**
  String get remove_item_failed;

  /// No description provided for @remove_from_watchlist_title.
  ///
  /// In en, this message translates to:
  /// **'Remove from watchlist'**
  String get remove_from_watchlist_title;

  /// No description provided for @remove_from_watchlist_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this item from your watchlist?'**
  String get remove_from_watchlist_confirm;

  /// No description provided for @tab_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get tab_saved;

  /// No description provided for @tab_watching.
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get tab_watching;

  /// No description provided for @watchlist_not_logged_in.
  ///
  /// In en, this message translates to:
  /// **'You are not logged in.'**
  String get watchlist_not_logged_in;

  /// No description provided for @watchlist_login_tap_message.
  ///
  /// In en, this message translates to:
  /// **'Tap here to log in and view your watchlist.'**
  String get watchlist_login_tap_message;

  /// No description provided for @error_loading.
  ///
  /// In en, this message translates to:
  /// **'Error loading: {error}'**
  String error_loading(Object error);

  /// No description provided for @no_items.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get no_items;

  /// No description provided for @season_label.
  ///
  /// In en, this message translates to:
  /// **'Season {number}'**
  String season_label(Object number);

  /// Short season label
  ///
  /// In en, this message translates to:
  /// **'S{num}'**
  String season_short(Object num);

  /// No description provided for @seen_x_of_y.
  ///
  /// In en, this message translates to:
  /// **'{seen}/{total} seen'**
  String seen_x_of_y(Object seen, Object total);

  /// No description provided for @title_wait.
  ///
  /// In en, this message translates to:
  /// **'{title}: please wait...'**
  String title_wait(Object title);

  /// No description provided for @no_progress_for_films.
  ///
  /// In en, this message translates to:
  /// **'No progress for films yet'**
  String get no_progress_for_films;

  /// No description provided for @episode.
  ///
  /// In en, this message translates to:
  /// **'Episode'**
  String get episode;

  /// No description provided for @seen_episodes_label.
  ///
  /// In en, this message translates to:
  /// **'Seen episodes: {count}'**
  String seen_episodes_label(Object count);

  /// No description provided for @disclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimerTitle;

  /// No description provided for @disclaimerHeading.
  ///
  /// In en, this message translates to:
  /// **'Third parties & APIs'**
  String get disclaimerHeading;

  /// No description provided for @disclaimerText.
  ///
  /// In en, this message translates to:
  /// **'This app uses data from multiple third-party sources:\n\n* API by Brian Fritz (OMDb API)\n Licensed under CC BY-NC 4.0\n This service is not endorsed by or affiliated with IMDb.com\n\n* This application uses TMDB and the TMDB APIs but is not endorsed, certified, or otherwise approved by TMDB\n\n* Some data sourced from IMDb\n\n* Streaming availability and translation services provided via RapidAPI\n\n* Trailers provided by YouTube\n\nMap data © OpenStreetMap contributors\n\nAll trademarks, logos, and copyrights belong to their respective owners.'**
  String get disclaimerText;

  /// No description provided for @playbackDisabledByVideoOwner.
  ///
  /// In en, this message translates to:
  /// **'Playback disabled by video owner.'**
  String get playbackDisabledByVideoOwner;

  /// No description provided for @disclaimerNote.
  ///
  /// In en, this message translates to:
  /// **'Use and display of content is subject to the terms and licenses of the services listed above.'**
  String get disclaimerNote;

  /// No description provided for @add_series_button.
  ///
  /// In en, this message translates to:
  /// **'Add series'**
  String get add_series_button;

  /// No description provided for @add_series_title.
  ///
  /// In en, this message translates to:
  /// **'Add series'**
  String get add_series_title;

  /// No description provided for @add_series_use_dates.
  ///
  /// In en, this message translates to:
  /// **'Use recurring days'**
  String get add_series_use_dates;

  /// No description provided for @add_series_until_date.
  ///
  /// In en, this message translates to:
  /// **'Until date'**
  String get add_series_until_date;

  /// No description provided for @until_label.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get until_label;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @imdb_id_label.
  ///
  /// In en, this message translates to:
  /// **'ID (e.g. tt1234567)'**
  String get imdb_id_label;

  /// No description provided for @title_label.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title_label;

  /// No description provided for @number_of_seasons.
  ///
  /// In en, this message translates to:
  /// **'Number of seasons'**
  String get number_of_seasons;

  /// No description provided for @number_of_episodes.
  ///
  /// In en, this message translates to:
  /// **'Number of episodes'**
  String get number_of_episodes;

  /// No description provided for @episodes_in_season.
  ///
  /// In en, this message translates to:
  /// **'Episodes in season {season}'**
  String episodes_in_season(Object season);

  /// No description provided for @episodes_per_season_hint.
  ///
  /// In en, this message translates to:
  /// **'Episodes per season (comma separated, e.g. 10,8,12)'**
  String get episodes_per_season_hint;

  /// No description provided for @invalid_series_input.
  ///
  /// In en, this message translates to:
  /// **'Invalid input'**
  String get invalid_series_input;

  /// No description provided for @series_added.
  ///
  /// In en, this message translates to:
  /// **'Series added'**
  String get series_added;

  /// No description provided for @add_series_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add series'**
  String get add_series_failed;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'nl', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'nl': return AppLocalizationsNl();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
