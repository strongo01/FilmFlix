// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get myDashboard => 'My Dashboard';

  @override
  String get preferences => 'Preferences';

  @override
  String get notifications => 'Notifications';

  @override
  String get notifications_enabled => 'Notifications enabled';

  @override
  String get notifications_check_system => 'Check System Settings to allow notifications.';

  @override
  String get notifications_registration_failed => 'Registering for notifications failed.';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get dutch => 'Dutch';

  @override
  String get french => 'French';

  @override
  String get german => 'German';

  @override
  String get turkish => 'Turkish';

  @override
  String get spanish => 'Spanish';

  @override
  String get close => 'Close';

  @override
  String get nameLabel => 'Your name';

  @override
  String get nameValidation => 'Enter your name';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get mustBeLoggedIn => 'You must be logged in to change your name';

  @override
  String get profile_default_name => 'Kevin le Goat';

  @override
  String get profile_default_email => 'kevinlegoat@example.com';

  @override
  String get filmsDone => 'Films watched';

  @override
  String get watchlist_label => 'Watchlist';

  @override
  String get support => 'Support';

  @override
  String get customerService_title => 'Customer Service';

  @override
  String get aboutTitle => 'About CineTrackr';

  @override
  String get aboutText => 'CineTrackr\n\nWelcome to CineTrackr, your personal guide for movies and cinema visits.\n\nWith CineTrackr you can easily view movie schedules, keep your own watchlist and quickly access cinema locations and customer service.\n\nThanks for using CineTrackr — enjoy watching!';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get logout => 'Log out';

  @override
  String get loginIn => 'Sign in';

  @override
  String get nameUpdated => 'Name updated';

  @override
  String get nameUpdateFailed => 'Update failed';

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
  String get send_failed => 'Send failed';

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
  String get marked_unread => 'Marked as unread';

  @override
  String get action_failed => 'Action failed';

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
  String get map_all_cinemas_title => 'Cinemas in the Netherlands';

  @override
  String map_load_error(Object error) {
    return 'Error loading cinemas: $error';
  }

  @override
  String get map_location_service_disabled => 'Location services are disabled';

  @override
  String get map_location_permission_denied => 'Location access denied';

  @override
  String get map_location_permission_denied_forever => 'Location permissions permanently denied. Enable in settings.';

  @override
  String map_location_fetch_error(Object error) {
    return 'Could not fetch location: $error';
  }

  @override
  String get map_no_website_content => 'No website available — Cinema found! 🎥';

  @override
  String get unknown => 'Unknown';

  @override
  String get food_edit_favorite => 'Edit favorite';

  @override
  String get food_name_label => 'Name';

  @override
  String get food_only_emoji => 'Emoji only';

  @override
  String get food_location => 'Location';

  @override
  String get food_diet => 'Dietary preference';

  @override
  String get food_diet_info => 'Note: Availability of restaurants with specific dietary options may vary by region.';

  @override
  String get food_hold_to_edit => 'Long press an icon to edit';

  @override
  String get food_quick_pizza => 'Pizza';

  @override
  String get food_quick_sushi => 'Sushi';

  @override
  String get food_quick_burger => 'Burger';

  @override
  String get food_quick_kapsalon => 'Kapsalon';

  @override
  String get food_search_hint => 'Search for something...';

  @override
  String get food_search_button => 'SEARCH ON THUISBEZORGD';

  @override
  String get food_postcode_label => 'ZIP code (4 digits)';

  @override
  String get food_zip_required => 'Enter 4 digits of your ZIP code first!';

  @override
  String get filter_vegetarian => 'Vegetarian';

  @override
  String get filter_vegan => 'Vegan';

  @override
  String get filter_gluten_free => 'Gluten-free';

  @override
  String get filter_halal => 'Halal';

  @override
  String get food_what_do_you_want => 'What do you want to eat?';

  @override
  String get tutorialSkip => 'Skip';

  @override
  String get ellipsis => '...';

  @override
  String get open => 'Open';

  @override
  String get changeNameTitle => 'Change your name';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get enter_name_description => 'We use your name to make the app more personal, for example for greetings.';

  @override
  String get save_and_continue => 'Save and continue';

  @override
  String get contact_admin_title => 'Contact admin';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get contactNameLabel => 'Name';

  @override
  String get contactQuestionLabel => 'Question';

  @override
  String get question_validation => 'Enter your question';

  @override
  String get mustBeLoggedInToSend => 'You must be signed in to send';

  @override
  String get question_sent => 'Question sent';

  @override
  String get ai_max_reached => 'You have used the maximum number of AI questions for today. Try again tomorrow.';

  @override
  String get ask_ai_title => 'Ask AI';

  @override
  String get ai_wait => 'Please wait, this may take up to a minute';

  @override
  String get ai_answer_title => 'AI Answer';

  @override
  String ai_answer_title_with_model(Object model) {
    return 'AI Answer ($model)';
  }

  @override
  String get ai_failed_all => 'AI request failed for all models.';

  @override
  String get ai_failed => 'AI request failed.';

  @override
  String get login_required_title => 'Sign-in required';

  @override
  String get login_required_message => 'You must be signed in to do this. Go to the login screen?';

  @override
  String get goto_login => 'Go to login';

  @override
  String get search_faqs_hint => 'Search in frequently asked questions';

  @override
  String get no_faq_matches => 'No FAQ matches';

  @override
  String ai_questions_used(Object max, Object used) {
    return 'AI questions: $used/$max used';
  }

  @override
  String ask_ai_with_cooldown(Object seconds) {
    return 'Ask AI ($seconds)';
  }

  @override
  String get contact_admin_button => 'Contact admin';

  @override
  String get my_questions => 'My questions';

  @override
  String get no_questions_sent => 'You have not sent any questions yet.';

  @override
  String get message_sent => 'Message sent';

  @override
  String get followup_title => 'Respond to your question';

  @override
  String get enter_message_hint => 'Type a message...';

  @override
  String get faq_default_account_q => 'How do I create an account?';

  @override
  String get faq_default_account_a => 'You can register via the profile icon at the top-right of the app. Follow the steps to create a new account.';

  @override
  String get faq_default_watchlist_q => 'How do I add a movie to my watchlist?';

  @override
  String get faq_default_watchlist_a => 'Open the movie page and tap the \"Save\" (bookmark icon) to add the movie to your watchlist.';

  @override
  String get faq_missing_info_q => 'Why is an episode or season missing information?';

  @override
  String get faq_missing_info_a => 'Our data comes from external providers; sometimes metadata is missing. Try again later or report it via Contact admin.';

  @override
  String get faq_report_bug_q => 'How can I report a bug in the app?';

  @override
  String get faq_report_bug_a => 'Use the \"Contact admin\" button below to send an email with a description and screenshots.';

  @override
  String get faq_ai_q => 'Can I ask questions to an AI?';

  @override
  String get faq_ai_a => 'Yes — use the \"Ask AI\" button to ask a question. Note that answers are automatically generated.';

  @override
  String get admins_no_push => 'Admins may not receive push notifications';

  @override
  String ai_cooldown_wait(Object seconds) {
    return 'Wait $seconds seconds before using the AI again.';
  }

  @override
  String get ai_input_hint => 'Type your question about movies or series here...';

  @override
  String get user_new_message_title => 'New message from user';

  @override
  String get nowPlayingTitle => 'Now playing';

  @override
  String get imdbIdUnavailable => 'IMDb ID not available for this movie';

  @override
  String get cannot_load_now_playing => 'Could not load current films.';

  @override
  String get retry => 'Retry';

  @override
  String get no_films_found => 'No films found';

  @override
  String get loginWelcome => 'Welcome to CineTrackr';

  @override
  String get loginCreateAccount => 'Create an account';

  @override
  String get loginName => 'Name';

  @override
  String get loginNameRequired => 'Enter your name';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginEmailRequired => 'Enter your email address';

  @override
  String get loginInvalidEmail => 'Invalid email address';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginPasswordRequired => 'Enter your password';

  @override
  String get loginPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get loginRegister => 'Register';

  @override
  String get loginNoAccountRegister => 'No account yet? Register';

  @override
  String get loginHaveAccountLogin => 'Already have an account? Sign in';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginContinueAsGuest => 'Continue as guest';

  @override
  String get loginOrDivider => 'OR';

  @override
  String get loginSignInWithGoogle => 'Sign in with Google';

  @override
  String get loginSignInWithGitHub => 'Sign in with GitHub';

  @override
  String get loginSignInWithApple => 'Sign in with Apple';

  @override
  String get loginEnterValidEmail => 'Enter a valid email address';

  @override
  String get loginPasswordResetEmailSent => 'Password reset email sent';

  @override
  String get loginPasswordResetFailed => 'Could not send reset email';

  @override
  String get loginSomethingWentWrong => 'Something went wrong';

  @override
  String get authenticationFailed => 'Authentication failed';

  @override
  String get loginGithubFailed => 'GitHub login failed';

  @override
  String get googleIdTokenError => 'Error retrieving Google ID token';

  @override
  String get googleSignInCancelled => 'Google sign-in cancelled';

  @override
  String get loginErrorCredentialMalformed => 'The supplied credential is malformed or has expired.';

  @override
  String get loginErrorUserDisabled => 'This user account has been disabled.';

  @override
  String get loginErrorTooManyRequests => 'We have blocked all requests from this device due to unusual activity. Try again later.';

  @override
  String get loginErrorInvalidEmail => 'The email address is badly formatted.';

  @override
  String get loginErrorWrongPassword => 'Wrong password.';

  @override
  String get loginErrorUserNotFound => 'No user found with this email.';

  @override
  String get loginErrorAccountExists => 'An account already exists with the same email address but different sign-in credentials.';

  @override
  String get details => 'Details';

  @override
  String get translate => 'Translate';

  @override
  String get seen => 'Seen';

  @override
  String age_rating(Object rated) {
    return 'Age rating: $rated';
  }

  @override
  String get producers_creators => 'Producers / Creators';

  @override
  String get actors => 'Actors';

  @override
  String seasons(Object count) {
    return 'Seasons: $count';
  }

  @override
  String episodes(Object count) {
    return 'Episodes: $count';
  }

  @override
  String get streaming => 'Streaming';

  @override
  String seasons_episodes_title(Object count) {
    return 'Seasons & Episodes ($count)';
  }

  @override
  String get no_seasons_found => 'No seasons found';

  @override
  String get no_episodes_found => 'No episodes found';

  @override
  String get warning_title => 'Warning';

  @override
  String get warning_bioscoop_content => 'Please close any ads/popups on the website before viewing the agenda.';

  @override
  String get continue_label => 'Continue';

  @override
  String get mark_previous_episodes_title => 'Mark previous episodes?';

  @override
  String mark_previous_episodes_message(Object count, Object season, Object title) {
    return 'You\'re marking \"$title\" as seen. Also mark $count previous episode(s) of season $season as seen?';
  }

  @override
  String episodes_marked_seen(Object count) {
    return '$count episodes marked as seen';
  }

  @override
  String get watchlist_update_failed => 'Could not update watchlist.';

  @override
  String get episode_status_update_failed => 'Could not update episode status.';

  @override
  String get movie_seen_update_failed => 'Could not update \"Seen\" status.';

  @override
  String get included_with_subscription => 'Included with subscription';

  @override
  String get buy => 'Buy';

  @override
  String buy_with_price(Object price) {
    return 'Buy • $price';
  }

  @override
  String get rent => 'Rent';

  @override
  String rent_with_price(Object price) {
    return 'Rent • $price';
  }

  @override
  String get addon => 'Addon';

  @override
  String addon_with_price(Object price) {
    return 'Addon • $price';
  }

  @override
  String get details_streaming_warning => 'Click to open streaming link';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get stars => 'stars';

  @override
  String get appleSignInNoIdentityToken => 'Apple Sign-In failed: no identity token returned';

  @override
  String get googleSignInFailed => 'Google sign-in failed';

  @override
  String get loginErrorWeakPassword => 'Password is too weak.';

  @override
  String get loginErrorNetworkFailed => 'Network error. Please check your connection.';

  @override
  String get loginErrorRequiresRecentLogin => 'Please sign in again to continue (recent authentication required).';

  @override
  String get avatar_login_prompt => 'Log in to change your profile picture';

  @override
  String get invalid_input => 'Invalid input';

  @override
  String get only_emoji_error => 'Enter only emoji';

  @override
  String get use => 'Use';

  @override
  String get emoji_input_hint => 'Paste or type an emoji (optional)';

  @override
  String get edit_avatar_title => 'Edit profile picture';

  @override
  String get choose_color => 'Choose color';

  @override
  String get choose_emoji_optional => 'Choose emoji (optional)';

  @override
  String get your_badges => 'YOUR BADGES';

  @override
  String get account_section => 'ACCOUNT';

  @override
  String get edit_profile => 'Edit profile';

  @override
  String get films => 'Films';

  @override
  String get badge_level_prefix => 'Lv';

  @override
  String get badge_adventurer => 'Avonturer';

  @override
  String get badge_horror_king => 'Horror King';

  @override
  String get badge_binge_watcher => 'Binge Watcher';

  @override
  String get badge_early_bird => 'Early Bird';

  @override
  String get appVersion => 'CineTrackr v1.0.4';

  @override
  String get search_hint => 'Search series/movie...';

  @override
  String get clear_tooltip => 'Clear';

  @override
  String get filter_tooltip => 'Filter';

  @override
  String get filter_refine_title => 'Refine filters';

  @override
  String get filter_type_label => 'TYPE';

  @override
  String get filter_all => 'All';

  @override
  String get filter_movies => 'Movies';

  @override
  String get filter_series => 'Series';

  @override
  String get filter_keyword_label => 'KEYWORD';

  @override
  String get filter_keyword_hint => 'e.g. Batman, Marvel...';

  @override
  String get filter_genres_label => 'GENRES';

  @override
  String get filter_year_from_label => 'YEAR (FROM)';

  @override
  String get filter_year_to_label => 'YEAR (TO)';

  @override
  String get filter_min_rating_label => 'MINIMUM RATING (0-100)';

  @override
  String get apply_filters => 'Apply Filters';

  @override
  String get tmdb_movie_fetch_failed => 'Could not fetch movie details';

  @override
  String get no_imdb_for_movie => 'No IMDb ID found for this movie';

  @override
  String get tmdb_movie_fetch_error => 'Error fetching movie details';

  @override
  String get tmdb_series_fetch_failed => 'Could not fetch series details';

  @override
  String get no_imdb_for_series => 'No IMDb ID found for this series';

  @override
  String get tmdb_series_fetch_error => 'Error fetching series details';

  @override
  String get load_more_results => 'Load more results';

  @override
  String get best_rated => 'Best Rated';

  @override
  String get popular => 'Popular';

  @override
  String get genre_action => 'Action';

  @override
  String get genre_adventure => 'Adventure';

  @override
  String get genre_animation => 'Animation';

  @override
  String get genre_comedy => 'Comedy';

  @override
  String get genre_crime => 'Crime';

  @override
  String get genre_documentary => 'Documentary';

  @override
  String get genre_drama => 'Drama';

  @override
  String get genre_family => 'Family';

  @override
  String get genre_fantasy => 'Fantasy';

  @override
  String get genre_history => 'History';

  @override
  String get genre_horror => 'Horror';

  @override
  String get genre_music => 'Music';

  @override
  String get genre_mystery => 'Mystery';

  @override
  String get genre_news => 'News';

  @override
  String get genre_reality => 'Reality';

  @override
  String get genre_romance => 'Romance';

  @override
  String get genre_scifi => 'Science Fiction';

  @override
  String get genre_talk => 'Talk Show';

  @override
  String get genre_thriller => 'Thriller';

  @override
  String get genre_war => 'War';

  @override
  String get genre_western => 'Western';

  @override
  String get login_progress_save_snack => 'Log in to save progress';

  @override
  String get progress_update_failed => 'Could not update progress';

  @override
  String get open_details => 'Open details';

  @override
  String get label_series => 'Series';

  @override
  String seen_count(Object count) {
    return 'Seen: $count';
  }

  @override
  String get remove_from_watchlist_tooltip => 'Remove from watchlist';

  @override
  String get login_manage_watchlist_snack => 'Log in to manage your watchlist';

  @override
  String get item_removed_watchlist => 'Item removed from watchlist';

  @override
  String get remove_item_failed => 'Could not remove item';

  @override
  String get remove_from_watchlist_title => 'Remove from watchlist';

  @override
  String get remove_from_watchlist_confirm => 'Are you sure you want to remove this item from your watchlist?';

  @override
  String get tab_saved => 'Saved';

  @override
  String get tab_watching => 'Watching';

  @override
  String get watchlist_not_logged_in => 'You are not logged in.';

  @override
  String get watchlist_login_tap_message => 'Tap here to log in and view your watchlist.';

  @override
  String error_loading(Object error) {
    return 'Error loading: $error';
  }

  @override
  String get no_items => 'No items';

  @override
  String season_label(Object number) {
    return 'Season $number';
  }

  @override
  String season_short(Object num) {
    return 'S$num';
  }

  @override
  String seen_x_of_y(Object seen, Object total) {
    return '$seen/$total seen';
  }

  @override
  String title_wait(Object title) {
    return '$title: please wait...';
  }

  @override
  String get no_progress_for_films => 'No progress for films yet';

  @override
  String get episode => 'Episode';

  @override
  String seen_episodes_label(Object count) {
    return 'Seen episodes: $count';
  }

  @override
  String get disclaimerTitle => 'Disclaimer';

  @override
  String get disclaimerHeading => 'Third parties & APIs';

  @override
  String get disclaimerText => 'This app uses data from multiple third-party sources:\n\n* API by Brian Fritz (OMDb API)\n Licensed under CC BY-NC 4.0\n This service is not endorsed by or affiliated with IMDb.com\n\n* This application uses TMDB and the TMDB APIs but is not endorsed, certified, or otherwise approved by TMDB\n\n* Some data sourced from IMDb\n\n* Streaming availability and translation services provided via RapidAPI\n\n* Trailers provided by YouTube\n\nMap data © OpenStreetMap contributors\n\nAll trademarks, logos, and copyrights belong to their respective owners.';

  @override
  String get playbackDisabledByVideoOwner => 'Playback disabled by video owner.';

  @override
  String get disclaimerNote => 'Use and display of content is subject to the terms and licenses of the services listed above.';

  @override
  String get add_series_button => 'Add series';

  @override
  String get add_series_title => 'Add series';

  @override
  String get add_series_use_dates => 'Use recurring days';

  @override
  String get add_series_until_date => 'Until date';

  @override
  String get until_label => 'Until';

  @override
  String get select => 'Select';

  @override
  String get imdb_id_label => 'ID (e.g. tt1234567)';

  @override
  String get title_label => 'Title';

  @override
  String get number_of_seasons => 'Number of seasons';

  @override
  String get number_of_episodes => 'Number of episodes';

  @override
  String episodes_in_season(Object season) {
    return 'Episodes in season $season';
  }

  @override
  String get episodes_per_season_hint => 'Episodes per season (comma separated, e.g. 10,8,12)';

  @override
  String get invalid_series_input => 'Invalid input';

  @override
  String get series_added => 'Series added';

  @override
  String get add_series_failed => 'Failed to add series';
}
