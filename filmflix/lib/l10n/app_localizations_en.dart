// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get admin_title => 'Admin';

  @override
  String get tab_chats => 'Chats';

  @override
  String get tab_faqs => 'FAQs';

  @override
  String get not_logged_in_title => 'Not logged in';

  @override
  String get not_logged_in_message => 'Please sign in as admin and try again.';

  @override
  String get close => 'Close';

  @override
  String get no_users_doc => 'No users doc found.';

  @override
  String users_doc_role(Object role, Object uid) {
    return 'users/$uid role = $role';
  }

  @override
  String users_doc_no_role(Object uid) {
    return 'users/$uid exists but has no role field.';
  }

  @override
  String users_doc_read_error(Object error) {
    return 'Error reading users doc: $error';
  }

  @override
  String get check_permissions_title => 'Check permissions';

  @override
  String get possible_causes => 'Possible causes and fixes:';

  @override
  String get firestore_rules => '- Check Firestore rules: using custom claims (request.auth.token.role).';

  @override
  String get custom_claims_hint => '- If using custom claims: set role/admin via Admin SDK and have admin re-login.';

  @override
  String rules_temp_change(Object uid) {
    return '- Or temporarily change rules to read role from /users/$uid.';
  }

  @override
  String get current_users_doc => 'Current users doc:';

  @override
  String get debug_info_title => 'Debug info';

  @override
  String uid_label(Object uid) {
    return 'uid: $uid';
  }

  @override
  String idtoken_claims_label(Object claims) {
    return 'idToken claims: $claims';
  }

  @override
  String idtoken_error_label(Object error) {
    return 'idToken error: $error';
  }

  @override
  String users_doc_label(Object doc) {
    return 'users doc: $doc';
  }

  @override
  String get ok => 'OK';

  @override
  String get fetch_doc_title => 'Fetch document by ID';

  @override
  String get paste_doc_id => 'Paste the document ID from customerquestions:';

  @override
  String get cancel => 'Cancel';

  @override
  String get fetch => 'Fetch';

  @override
  String get not_found_title => 'Not found';

  @override
  String document_not_found(Object id) {
    return 'Document $id does not exist or is not readable.';
  }

  @override
  String document_title(Object id) {
    return 'Document $id';
  }

  @override
  String get empty => '<empty>';

  @override
  String get fetch_error_title => 'Error';

  @override
  String fetch_error_message(Object error) {
    return 'Error fetching: $error';
  }

  @override
  String cannot_load_chats(Object error) {
    return 'Cannot load chats: $error';
  }

  @override
  String get no_questions_found => 'No questions found';

  @override
  String get show_debug_info => 'Show debug info';

  @override
  String get delete_chat_title => 'Delete chat';

  @override
  String get delete_chat_confirm => 'Are you sure you want to delete this chat? This cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get chat_deleted => 'Chat deleted';

  @override
  String get delete_failed => 'Delete failed';

  @override
  String get user_label_default => 'User';

  @override
  String get reply_hint => 'Type a reply...';

  @override
  String get send => 'Send';

  @override
  String get notify_title => 'New message from admin';

  @override
  String notify_body(Object text) {
    return '$text';
  }

  @override
  String get no_faq_items => 'No FAQ items yet';

  @override
  String get edit => 'Edit';

  @override
  String get remove => 'Remove';

  @override
  String get add_new_faq => 'Add new FAQ';

  @override
  String get new_faq_title => 'New FAQ';

  @override
  String get question_label => 'Question';

  @override
  String get answer_label => 'Answer';

  @override
  String get add => 'Add';

  @override
  String get faq_added => 'FAQ added';

  @override
  String get faq_add_failed => 'Add failed';

  @override
  String get edit_faq_title => 'Edit FAQ';

  @override
  String get save => 'Save';

  @override
  String get faq_updated => 'FAQ updated';

  @override
  String get faq_update_failed => 'Save failed';

  @override
  String get delete_faq_title => 'Delete FAQ';

  @override
  String get delete_faq_confirm => 'Are you sure you want to delete this FAQ?';

  @override
  String get faq_deleted => 'FAQ deleted';

  @override
  String get faq_delete_failed => 'Delete failed';

  @override
  String admins_label(Object names) {
    return 'Admins: $names';
  }

  @override
  String chat_page_title_prefix(Object prefix) {
    return 'Chat: $prefix';
  }

  @override
  String get appTitle => 'CineTrackr';

  @override
  String get navHome => 'Home';

  @override
  String get navWatchlist => 'Watchlist';

  @override
  String get navSearch => 'Search';

  @override
  String get navFood => 'Food';

  @override
  String get navProfile => 'Profile';

  @override
  String get tutorialHome => 'Welcome! Here are the latest movies and series.';

  @override
  String get tutorialWatchlist => 'Save your favorite movies here for later.';

  @override
  String get tutorialSearch => 'Search for titles or genres.';

  @override
  String get tutorialFood => 'See matching snacks for your movie night!';

  @override
  String get tutorialProfile => 'Manage your profile and settings here.';

  @override
  String get tutorialMap => 'View the map to find nearby cinemas!';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get myDashboard => 'My Dashboard';

  @override
  String get preferences => 'Preferences';

  @override
  String get support => 'Support';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get dutch => 'Dutch';

  @override
  String get mustBeLoggedIn => 'You must be logged in to change your name';

  @override
  String get changeNameTitle => 'Change your name';

  @override
  String get nameLabel => 'Your name';

  @override
  String get nameValidation => 'Enter your name';

  @override
  String get nameUpdated => 'Name updated';

  @override
  String get updateFailed => 'Update failed';
}
