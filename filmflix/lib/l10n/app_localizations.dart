import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

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
    Locale('en'),
    Locale('nl')
  ];

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

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

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

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

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
  /// **'Question'**
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

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

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

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

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

  /// No description provided for @tutorialMap.
  ///
  /// In en, this message translates to:
  /// **'View the map to find nearby cinemas!'**
  String get tutorialMap;

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

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @dutch.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get dutch;

  /// No description provided for @mustBeLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to change your name'**
  String get mustBeLoggedIn;

  /// No description provided for @changeNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Change your name'**
  String get changeNameTitle;

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

  /// No description provided for @nameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated'**
  String get nameUpdated;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// No description provided for @customerService_title.
  ///
  /// In en, this message translates to:
  /// **'Customer Service'**
  String get customerService_title;

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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'nl': return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
