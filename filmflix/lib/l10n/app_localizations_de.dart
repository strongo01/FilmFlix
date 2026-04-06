// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get myDashboard => 'Mein Dashboard';

  @override
  String get preferences => 'Präferenzen';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get notifications_enabled => 'Benachrichtigungen aktiviert';

  @override
  String get notifications_check_system => 'Überprüfen Sie die Systemeinstellungen, um Benachrichtigungen zuzulassen.';

  @override
  String get notifications_registration_failed => 'Anmeldung für Benachrichtigungen fehlgeschlagen.';

  @override
  String get language => 'Sprache';

  @override
  String get english => 'English';

  @override
  String get dutch => 'Nederlands';

  @override
  String get french => 'Französisch';

  @override
  String get german => 'Deutsch';

  @override
  String get turkish => 'Türkisch';

  @override
  String get spanish => 'Spanisch';

  @override
  String get close => 'Schließen';

  @override
  String get nameLabel => 'Ihr Name';

  @override
  String get nameValidation => 'Bitte geben Sie Ihren Namen ein';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get mustBeLoggedIn => 'Sie müssen eingeloggt sein, um Ihren Namen zu ändern';

  @override
  String get profile_default_name => 'Kevin le Goat';

  @override
  String get profile_default_email => 'kevinlegoat@example.com';

  @override
  String get filmsDone => 'Filme abgeschlossen';

  @override
  String get watchlist_label => 'Watchlist';

  @override
  String get support => 'Support';

  @override
  String get customerService_title => 'Kundenservice';

  @override
  String get aboutTitle => 'Über CineTrackr';

  @override
  String get aboutText => 'CineTrackr\n\nWillkommen bei CineTrackr, Ihrem persönlichen Guide für Filme und Kinobesuche.\n\nMit CineTrackr können Sie ganz einfach Kinoprogramme einsehen, Ihre eigene Watchlist führen und schnell auf Kinostandorte sowie den Kundenservice zugreifen.\n\nVielen Dank, dass Sie CineTrackr nutzen — viel Spaß beim Schauen!';

  @override
  String get privacyPolicy => 'Datenschutzbestimmungen';

  @override
  String get logout => 'Abmelden';

  @override
  String get loginIn => 'Anmelden';

  @override
  String get nameUpdated => 'Name aktualisiert';

  @override
  String get nameUpdateFailed => 'Aktualisierung fehlgeschlagen';

  @override
  String get admin_title => 'Admin';

  @override
  String get tab_chats => 'Chats';

  @override
  String get tab_faqs => 'FAQs';

  @override
  String get not_logged_in_title => 'Nicht eingeloggt';

  @override
  String get not_logged_in_message => 'Bitte melden Sie sich zuerst als Admin an und versuchen Sie es erneut.';

  @override
  String get no_users_doc => 'Kein User-Dokument gefunden.';

  @override
  String users_doc_role(Object role, Object uid) {
    return 'users/$uid role = $role';
  }

  @override
  String users_doc_no_role(Object uid) {
    return 'users/$uid existiert, hat aber kein Rollen-Feld.';
  }

  @override
  String users_doc_read_error(Object error) {
    return 'Fehler beim Lesen des User-Dokuments: $error';
  }

  @override
  String get send_failed => 'Senden fehlgeschlagen';

  @override
  String get check_permissions_title => 'Berechtigungen prüfen';

  @override
  String get possible_causes => 'Mögliche Ursachen und Lösungen:';

  @override
  String get firestore_rules => '- Firestore-Regeln prüfen: Regeln verwenden Custom Claims (request.auth.token.role).';

  @override
  String get custom_claims_hint => '- Falls Sie Custom Claims nutzen: Setzen Sie role/admin über das Admin SDK (Service Account) und lassen Sie den Admin sich neu anmelden.';

  @override
  String rules_temp_change(Object uid) {
    return '- Oder ändern Sie vorübergehend die Regeln, um die Rolle aus /users/$uid zu lesen.';
  }

  @override
  String get current_users_doc => 'Aktuelles User-Dokument:';

  @override
  String get debug_info_title => 'Debug-Info';

  @override
  String uid_label(Object uid) {
    return 'UID: $uid';
  }

  @override
  String idtoken_claims_label(Object claims) {
    return 'idToken Claims: $claims';
  }

  @override
  String idtoken_error_label(Object error) {
    return 'idToken Fehler: $error';
  }

  @override
  String users_doc_label(Object doc) {
    return 'User-Dokument: $doc';
  }

  @override
  String get ok => 'OK';

  @override
  String get fetch_doc_title => 'Dokument nach ID abrufen';

  @override
  String get paste_doc_id => 'Fügen Sie hier die Dokument-ID von customerquestions ein:';

  @override
  String get fetch => 'Abrufen';

  @override
  String get not_found_title => 'Nicht gefunden';

  @override
  String document_not_found(Object id) {
    return 'Dokument $id existiert nicht oder ist nicht lesbar.';
  }

  @override
  String document_title(Object id) {
    return 'Dokument $id';
  }

  @override
  String get empty => '<leer>';

  @override
  String get fetch_error_title => 'Fehler';

  @override
  String fetch_error_message(Object error) {
    return 'Fehler beim Abrufen: $error';
  }

  @override
  String cannot_load_chats(Object error) {
    return 'Chats können nicht geladen werden: $error';
  }

  @override
  String get no_questions_found => 'Keine Fragen gefunden';

  @override
  String get show_debug_info => 'Debug-Info anzeigen';

  @override
  String get delete_chat_title => 'Chat löschen';

  @override
  String get delete_chat_confirm => 'Sind Sie sicher, dass Sie diesen Chat löschen möchten? Dies kann nicht rückgängig gemacht werden.';

  @override
  String get delete => 'Löschen';

  @override
  String get chat_deleted => 'Chat gelöscht';

  @override
  String get delete_failed => 'Löschen fehlgeschlagen';

  @override
  String get marked_unread => 'Als ungelesen markiert';

  @override
  String get action_failed => 'Aktion fehlgeschlagen';

  @override
  String get user_label_default => 'Benutzer';

  @override
  String get reply_hint => 'Antwort schreiben...';

  @override
  String get send => 'Senden';

  @override
  String get notify_title => 'Neue Nachricht vom Admin';

  @override
  String notify_body(Object text) {
    return '$text';
  }

  @override
  String get no_faq_items => 'Noch keine FAQ-Einträge';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get remove => 'Entfernen';

  @override
  String get add_new_faq => 'Neues FAQ hinzufügen';

  @override
  String get new_faq_title => 'Neues FAQ';

  @override
  String get question_label => 'Frage/Kommentar';

  @override
  String get answer_label => 'Antwort';

  @override
  String get add => 'Hinzufügen';

  @override
  String get faq_added => 'FAQ hinzugefügt';

  @override
  String get faq_add_failed => 'Hinzufügen fehlgeschlagen';

  @override
  String get edit_faq_title => 'FAQ bearbeiten';

  @override
  String get faq_updated => 'FAQ aktualisiert';

  @override
  String get faq_update_failed => 'Speichern fehlgeschlagen';

  @override
  String get delete_faq_title => 'FAQ löschen';

  @override
  String get delete_faq_confirm => 'Sind Sie sicher, dass Sie dieses FAQ löschen möchten?';

  @override
  String get faq_deleted => 'FAQ gelöscht';

  @override
  String get faq_delete_failed => 'Löschen fehlgeschlagen';

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
  String get navSearch => 'Suchen';

  @override
  String get navFood => 'Food';

  @override
  String get navigationReorder => 'Navigation neu anordnen';

  @override
  String get navProfile => 'Profil';

  @override
  String get infoTooltip => 'Info';

  @override
  String get watchlistInfoTitle => 'Info';

  @override
  String get watchlistInfoContent => 'Die App kann leider keine Daten von Streaming-Diensten abrufen. Du kannst manuell die Episoden abhaken, die du gesehen hast.';

  @override
  String get tutorialHome => 'Willkommen! Hier finden Sie die neuesten Filme und Serien.';

  @override
  String get tutorialWatchlist => 'Speichern Sie hier Ihre Lieblingsfilme für später.';

  @override
  String get tutorialSearch => 'Suchen Sie nach bestimmten Titeln oder Genres.';

  @override
  String get tutorialFood => 'Entdecken Sie passende Snacks für Ihren Filmabend!';

  @override
  String get tutorialProfile => 'Verwalten Sie hier Ihr Profil und Ihre Einstellungen.';

  @override
  String get tutorialNavBar => 'Hier kannst du zwischen Bildschirmen wechseln. Halte einen Button lange gedrückt, um die Reihenfolge zu ändern.';

  @override
  String get tutorialHomeExtra => 'Auf dem Home-Bildschirm siehst du die neuesten Veröffentlichungen und Empfehlungen.';

  @override
  String get tutorialWatchlistExtra => 'In deiner Watchlist kannst du Filme entfernen oder für später speichern.';

  @override
  String get tutorialSearchExtra => 'Verwende die Suche, um schnell Titel und Schauspieler zu finden.';

  @override
  String get tutorialFoodExtra => 'Finde Snacks und Rezepte, die zu deinem Film passen.';

  @override
  String get tutorialProfileExtra => 'Verwalte Einstellungen, Präferenzen und Kontodaten in deinem Profil.';

  @override
  String get tutorialMap => 'Hier können Sie die Karte ansehen, um Kinos in Ihrer Nähe zu finden!';

  @override
  String get map_all_cinemas_title => 'Kinos in den Niederlanden';

  @override
  String map_load_error(Object error) {
    return 'Fehler beim Laden der Kinos: $error';
  }

  @override
  String get map_location_service_disabled => 'Standortdienst ist deaktiviert';

  @override
  String get map_location_permission_denied => 'Standortzugriff verweigert';

  @override
  String get map_location_permission_denied_forever => 'Standortberechtigungen dauerhaft verweigert. Bitte in den Einstellungen aktivieren.';

  @override
  String map_location_fetch_error(Object error) {
    return 'Standort konnte nicht abgerufen werden: $error';
  }

  @override
  String get map_no_website_content => 'Keine Website verfügbar — Kino gefunden! 🎥';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get food_edit_favorite => 'Favorit anpassen';

  @override
  String get food_name_label => 'Name';

  @override
  String get food_only_emoji => 'Nur Emoji';

  @override
  String get food_location => 'Standort';

  @override
  String get food_diet => 'Ernährungswunsch';

  @override
  String get food_diet_info => 'Hinweis: Das Angebot an Restaurants mit speziellen Ernährungsoptionen kann je nach Region variieren.';

  @override
  String get food_hold_to_edit => 'Halten Sie ein Symbol gedrückt, um es zu bearbeiten';

  @override
  String get food_quick_pizza => 'Pizza';

  @override
  String get food_quick_sushi => 'Sushi';

  @override
  String get food_quick_burger => 'Burger';

  @override
  String get food_quick_kapsalon => 'Kapsalon';

  @override
  String get food_search_hint => 'Selbst etwas suchen...';

  @override
  String get food_search_button => 'AUF THUISBEZORGD SUCHEN';

  @override
  String get food_postcode_label => 'Postleitzahl (4 Ziffern)';

  @override
  String get food_zip_required => 'Bitte geben Sie zuerst die 4 Ziffern Ihrer Postleitzahl ein!';

  @override
  String get filter_vegetarian => 'Vegetarisch';

  @override
  String get filter_vegan => 'Vegan';

  @override
  String get filter_gluten_free => 'Glutenfrei';

  @override
  String get filter_halal => 'Halal';

  @override
  String get food_what_do_you_want => 'Was möchten Sie essen?';

  @override
  String get tutorialSkip => 'Überspringen';

  @override
  String get ellipsis => '...';

  @override
  String get open => 'Öffnen';

  @override
  String get changeNameTitle => 'Namen ändern';

  @override
  String get updateFailed => 'Aktualisierung fehlgeschlagen';

  @override
  String get enter_name_description => 'Wir verwenden Ihren Namen, um die App persönlicher zu gestalten, z. B. für Begrüßungen.';

  @override
  String get save_and_continue => 'Speichern und Fortfahren';

  @override
  String get contact_admin_title => 'Admin kontaktieren';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get contactNameLabel => 'Name';

  @override
  String get contactQuestionLabel => 'Frage';

  @override
  String get question_validation => 'Bitte geben Sie Ihre Frage ein';

  @override
  String get mustBeLoggedInToSend => 'Sie müssen eingeloggt sein, um zu senden';

  @override
  String get question_sent => 'Frage gesendet';

  @override
  String get ai_max_reached => 'Sie haben die maximale Anzahl an KI-Fragen für heute erreicht. Bitte versuchen Sie es morgen erneut.';

  @override
  String get ask_ai_title => 'KI fragen';

  @override
  String get ai_wait => 'Einen Moment Geduld, dies kann bis zu einer Minute dauern';

  @override
  String get ai_answer_title => 'KI-Antwort';

  @override
  String ai_answer_title_with_model(Object model) {
    return 'KI-Antwort ($model)';
  }

  @override
  String get ai_failed_all => 'KI-Anfrage ist für alle Modelle fehlgeschlagen.';

  @override
  String get ai_failed => 'KI-Anfrage fehlgeschlagen.';

  @override
  String get login_required_title => 'Anmeldung erforderlich';

  @override
  String get login_required_message => 'Sie müssen eingeloggt sein, um dies zu tun. Möchten Sie zum Login-Bildschirm?';

  @override
  String get goto_login => 'Zum Login';

  @override
  String get search_faqs_hint => 'Häufig gestellte Fragen durchsuchen';

  @override
  String get no_faq_matches => 'Keine FAQ-Treffer';

  @override
  String ai_questions_used(Object max, Object used) {
    return 'KI-Fragen: $used/$max verwendet';
  }

  @override
  String ask_ai_with_cooldown(Object seconds) {
    return 'KI fragen (${seconds}s)';
  }

  @override
  String get contact_admin_button => 'Admin kontaktieren';

  @override
  String get my_questions => 'Meine Fragen';

  @override
  String get no_questions_sent => 'Sie haben noch keine Fragen gesendet.';

  @override
  String get message_sent => 'Nachricht gesendet';

  @override
  String get followup_title => 'Auf Ihre Frage antworten';

  @override
  String get enter_message_hint => 'Nachricht eingeben...';

  @override
  String get faq_default_account_q => 'Wie erstelle ich ein Konto?';

  @override
  String get faq_default_account_a => 'Sie können sich über das Profil-Icon oben rechts in der App registrieren. Folgen Sie den Schritten, um ein neues Konto zu erstellen.';

  @override
  String get faq_default_watchlist_q => 'Wie füge ich einen Film zu meiner Watchlist hinzu?';

  @override
  String get faq_default_watchlist_a => 'Öffnen Sie die Filmseite und klicken Sie auf die Schaltfläche \"Speichern\" (Lesezeichen-Symbol), um den Film zu Ihrer Watchlist hinzuzufügen.';

  @override
  String get faq_missing_info_q => 'Warum fehlen Informationen zu einer Folge oder Staffel?';

  @override
  String get faq_missing_info_a => 'Unsere Daten stammen von externen Anbietern; manchmal fehlen Metadaten. Bitte versuchen Sie es später erneut oder melden Sie es über \"Admin kontaktieren\".';

  @override
  String get faq_report_bug_q => 'Wie kann ich einen Fehler in der App melden?';

  @override
  String get faq_report_bug_a => 'Nutzen Sie die Schaltfläche \"Admin kontaktieren\" unten, um eine E-Mail mit einer Beschreibung und Screenshots zu senden.';

  @override
  String get faq_ai_q => 'Kann ich Fragen an eine KI stellen?';

  @override
  String get faq_ai_a => 'Ja — nutzen Sie die Schaltfläche \"KI fragen\", um eine Frage zu stellen. Bitte beachten Sie, dass Antworten automatisch generiert werden.';

  @override
  String get admins_no_push => 'Admins erhalten möglicherweise keine Push-Benachrichtigungen';

  @override
  String ai_cooldown_wait(Object seconds) {
    return 'Bitte warten Sie noch $seconds Sekunden, bevor Sie die KI erneut nutzen.';
  }

  @override
  String get ai_input_hint => 'Geben Sie hier Ihre Frage zu Filmen oder Serien ein...';

  @override
  String get user_new_message_title => 'Neue Nachricht vom Benutzer';

  @override
  String get nowPlayingTitle => 'Aktuelle Filme';

  @override
  String get imdbIdUnavailable => 'IMDb-ID für diesen Film nicht verfügbar';

  @override
  String get cannot_load_now_playing => 'Aktuelle Filme konnten nicht geladen werden.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get no_films_found => 'Keine Filme gefunden';

  @override
  String get loginWelcome => 'Willkommen bei CineTrackr';

  @override
  String get loginCreateAccount => 'Konto erstellen';

  @override
  String get loginName => 'Name';

  @override
  String get loginNameRequired => 'Bitte geben Sie Ihren Namen ein';

  @override
  String get loginEmail => 'E-Mail';

  @override
  String get loginEmailRequired => 'Bitte geben Sie Ihre E-Mail-Adresse ein';

  @override
  String get loginInvalidEmail => 'Ungültige E-Mail-Adresse';

  @override
  String get loginPassword => 'Passwort';

  @override
  String get loginPasswordRequired => 'Bitte geben Sie Ihr Passwort ein';

  @override
  String get loginPasswordTooShort => 'Das Passwort muss mindestens 6 Zeichen lang sein';

  @override
  String get loginRegister => 'Registrieren';

  @override
  String get loginNoAccountRegister => 'Noch kein Konto? Registrieren';

  @override
  String get loginHaveAccountLogin => 'Bereits ein Konto? Einloggen';

  @override
  String get loginForgotPassword => 'Passwort vergessen?';

  @override
  String get loginContinueAsGuest => 'Als Gast fortfahren';

  @override
  String get loginOrDivider => 'ODER';

  @override
  String get loginSignInWithGoogle => 'Mit Google anmelden';

  @override
  String get loginSignInWithGitHub => 'Mit GitHub anmelden';

  @override
  String get loginSignInWithApple => 'Mit Apple anmelden';

  @override
  String get loginEnterValidEmail => 'Bitte geben Sie eine gültige E-Mail-Adresse ein';

  @override
  String get loginPasswordResetEmailSent => 'Passwort-Reset-E-Mail gesendet';

  @override
  String get loginPasswordResetFailed => 'Reset-E-Mail konnte nicht gesendet werden';

  @override
  String get loginSomethingWentWrong => 'Etwas ist schiefgelaufen';

  @override
  String get authenticationFailed => 'Authentifizierung fehlgeschlagen';

  @override
  String get loginGithubFailed => 'GitHub-Login fehlgeschlagen';

  @override
  String get googleIdTokenError => 'Fehler beim Abrufen des Google ID-Tokens';

  @override
  String get googleSignInCancelled => 'Google-Anmeldung abgebrochen';

  @override
  String get loginErrorCredentialMalformed => 'Die angegebenen Anmeldedaten sind ungültig oder abgelaufen.';

  @override
  String get loginErrorUserDisabled => 'Dieses Benutzerkonto wurde deaktiviert.';

  @override
  String get loginErrorTooManyRequests => 'Wir haben alle Anfragen von diesem Gerät aufgrund ungewöhnlicher Aktivitäten blockiert. Versuchen Sie es später erneut.';

  @override
  String get loginErrorInvalidEmail => 'Die E-Mail-Adresse ist falsch formatiert.';

  @override
  String get loginErrorWrongPassword => 'Falsches Passwort.';

  @override
  String get loginErrorUserNotFound => 'Kein Benutzer mit dieser E-Mail gefunden.';

  @override
  String get loginErrorAccountExists => 'Es existiert bereits ein Konto mit derselben E-Mail-Adresse, aber anderen Anmeldedaten.';

  @override
  String get details => 'Details';

  @override
  String get translate => 'Übersetzen';

  @override
  String get seen => 'Gesehen';

  @override
  String age_rating(Object rated) {
    return 'Altersfreigabe: $rated';
  }

  @override
  String get producers_creators => 'Produzenten / Macher';

  @override
  String get actors => 'Schauspieler';

  @override
  String seasons(Object count) {
    return 'Staffeln: $count';
  }

  @override
  String episodes(Object count) {
    return 'Folgen: $count';
  }

  @override
  String get streaming => 'Streaming';

  @override
  String seasons_episodes_title(Object count) {
    return 'Staffeln & Folgen ($count)';
  }

  @override
  String get no_seasons_found => 'Keine Staffeln gefunden';

  @override
  String get no_episodes_found => 'Keine Folgen gefunden';

  @override
  String get warning_title => '!!Warnung!!';

  @override
  String get warning_bioscoop_content => 'Bitte schließen Sie zuerst eventuelle Werbung/Pop-ups auf der Website, bevor Sie den Spielplan einsehen.';

  @override
  String get continue_label => 'Fortfahren';

  @override
  String get mark_previous_episodes_title => 'Vorherige Folgen als gesehen markieren?';

  @override
  String mark_previous_episodes_message(Object count, Object season, Object title) {
    return 'Sie markieren \"$title\" als gesehen. Möchten Sie auch $count vorherige Folge(n) von Staffel $season als gesehen markieren?';
  }

  @override
  String episodes_marked_seen(Object count) {
    return '$count Folgen als gesehen markiert';
  }

  @override
  String get watchlist_update_failed => 'Watchlist konnte nicht aktualisiert werden.';

  @override
  String get episode_status_update_failed => 'Folgenstatus konnte nicht aktualisiert werden.';

  @override
  String get movie_seen_update_failed => '\"Gesehen\"-Status konnte nicht aktualisiert werden.';

  @override
  String get included_with_subscription => 'Inbegriffen';

  @override
  String get buy => 'Kaufen';

  @override
  String buy_with_price(Object price) {
    return 'Kaufen • $price';
  }

  @override
  String get rent => 'Leihen';

  @override
  String rent_with_price(Object price) {
    return 'Leihen • $price';
  }

  @override
  String get addon => 'Erweiterung';

  @override
  String addon_with_price(Object price) {
    return 'Erweiterung • $price';
  }

  @override
  String get details_streaming_warning => 'Klicken, um Streaming-Link zu öffnen';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get stars => 'Sterne';

  @override
  String get appleSignInNoIdentityToken => 'Apple-Anmeldung fehlgeschlagen: Kein Identity-Token empfangen';

  @override
  String get googleSignInFailed => 'Google-Anmeldung fehlgeschlagen';

  @override
  String get loginErrorWeakPassword => 'Das Passwort ist zu schwach.';

  @override
  String get loginErrorNetworkFailed => 'Netzwerkfehler. Bitte überprüfen Sie Ihre Verbindung.';

  @override
  String get loginErrorRequiresRecentLogin => 'Bitte melden Sie sich erneut an, um fortzufahren (kürzliche Authentifizierung erforderlich).';

  @override
  String get avatar_login_prompt => 'Loggen Sie sich ein, um Ihr Profilbild anzupassen';

  @override
  String get invalid_input => 'Ungültige Eingabe';

  @override
  String get only_emoji_error => 'Bitte nur Emojis eingeben';

  @override
  String get use => 'Verwenden';

  @override
  String get emoji_input_hint => 'Emoji einfügen oder tippen (optional)';

  @override
  String get edit_avatar_title => 'Profilbild anpassen';

  @override
  String get choose_color => 'Farbe wählen';

  @override
  String get choose_emoji_optional => 'Emoji wählen (optional)';

  @override
  String get your_badges => 'IHRE BADGES';

  @override
  String get account_section => 'KONTO';

  @override
  String get edit_profile => 'Profil bearbeiten';

  @override
  String get films => 'Filme';

  @override
  String get badge_level_prefix => 'Lv';

  @override
  String get badge_adventurer => 'Abenteurer';

  @override
  String get badge_horror_king => 'Horror-König';

  @override
  String get badge_binge_watcher => 'Binge-Watcher';

  @override
  String get badge_early_bird => 'Früher Vogel';

  @override
  String get appVersion => 'CineTrackr v1.0.4';

  @override
  String get search_hint => 'Serie/Film suchen...';

  @override
  String get clear_tooltip => 'Löschen';

  @override
  String get filter_tooltip => 'Filter';

  @override
  String get filter_refine_title => 'Filter verfeinern';

  @override
  String get filter_type_label => 'TYP';

  @override
  String get filter_all => 'Alles';

  @override
  String get filter_movies => 'Filme';

  @override
  String get filter_series => 'Serien';

  @override
  String get filter_keyword_label => 'SUCHWORT';

  @override
  String get filter_keyword_hint => 'Z.B. Batman, Marvel...';

  @override
  String get filter_genres_label => 'GENRES';

  @override
  String get filter_year_from_label => 'JAHR (VON)';

  @override
  String get filter_year_to_label => 'JAUR (BIS)';

  @override
  String get filter_min_rating_label => 'MINDESTBEWERTUNG (0-100)';

  @override
  String get apply_filters => 'Filter anwenden';

  @override
  String get tmdb_movie_fetch_failed => 'Filmdetails konnten nicht abgerufen werden';

  @override
  String get no_imdb_for_movie => 'Keine IMDb-ID für diesen Film gefunden';

  @override
  String get tmdb_movie_fetch_error => 'Fehler beim Abrufen der Filmdetails';

  @override
  String get tmdb_series_fetch_failed => 'Seriendetails konnten nicht abgerufen werden';

  @override
  String get no_imdb_for_series => 'Keine IMDb-ID für diese Serie gefunden';

  @override
  String get tmdb_series_fetch_error => 'Fehler beim Abrufen der Seriendetails';

  @override
  String get load_more_results => 'Mehr Ergebnisse laden';

  @override
  String get best_rated => 'Bestbewertet';

  @override
  String get popular => 'Beliebt';

  @override
  String get genre_action => 'Action';

  @override
  String get genre_adventure => 'Abenteuer';

  @override
  String get genre_animation => 'Animation';

  @override
  String get genre_comedy => 'Komödie';

  @override
  String get genre_crime => 'Krimi';

  @override
  String get genre_documentary => 'Dokumentation';

  @override
  String get genre_drama => 'Drama';

  @override
  String get genre_family => 'Familie';

  @override
  String get genre_fantasy => 'Fantasy';

  @override
  String get genre_history => 'Historie';

  @override
  String get genre_horror => 'Horror';

  @override
  String get genre_music => 'Musik';

  @override
  String get genre_mystery => 'Mystery';

  @override
  String get genre_news => 'Nachrichten';

  @override
  String get genre_reality => 'Reality';

  @override
  String get genre_romance => 'Romanze';

  @override
  String get genre_scifi => 'Science Fiction';

  @override
  String get genre_talk => 'Talkshow';

  @override
  String get genre_thriller => 'Thriller';

  @override
  String get genre_war => 'Krieg';

  @override
  String get genre_western => 'Western';

  @override
  String get login_progress_save_snack => 'Einloggen, um Fortschritt zu speichern';

  @override
  String get progress_update_failed => 'Fortschritt konnte nicht aktualisiert werden';

  @override
  String get open_details => 'Details öffnen';

  @override
  String get label_series => 'Serien';

  @override
  String seen_count(Object count) {
    return 'Gesehen: $count';
  }

  @override
  String get remove_from_watchlist_tooltip => 'Aus Watchlist entfernen';

  @override
  String get login_manage_watchlist_snack => 'Einloggen, um Watchlist zu verwalten';

  @override
  String get item_removed_watchlist => 'Eintrag aus Watchlist entfernt';

  @override
  String get remove_item_failed => 'Eintrag konnte nicht entfernt werden';

  @override
  String get remove_from_watchlist_title => 'Aus Watchlist entfernen';

  @override
  String get remove_from_watchlist_confirm => 'Sind Sie sicher, dass Sie diesen Eintrag aus Ihrer Watchlist entfernen möchten?';

  @override
  String get tab_saved => 'Gespeichert';

  @override
  String get tab_watching => 'Am Schauen';

  @override
  String get watchlist_not_logged_in => 'Sie sind noch nicht eingeloggt.';

  @override
  String get watchlist_login_tap_message => 'Tippen Sie hier, um sich einzuloggen und Ihre Watchlist zu sehen.';

  @override
  String error_loading(Object error) {
    return 'Fehler beim Laden: $error';
  }

  @override
  String get no_items => 'Keine Einträge';

  @override
  String season_label(Object number) {
    return 'Staffel $number';
  }

  @override
  String season_short(Object num) {
    return 'S$num';
  }

  @override
  String seen_x_of_y(Object seen, Object total) {
    return '$seen/$total gesehen';
  }

  @override
  String title_wait(Object title) {
    return '$title: einen Moment Geduld...';
  }

  @override
  String get no_progress_for_films => 'Noch kein Fortschritt für Filme';

  @override
  String get episode => 'Folge';

  @override
  String seen_episodes_label(Object count) {
    return 'Gesehene Folgen: $count';
  }

  @override
  String get disclaimerTitle => 'Haftungsausschluss';

  @override
  String get disclaimerHeading => 'Dienste von Drittanbietern und Datenquellen';

  @override
  String get disclaimerText => 'Diese App verwendet Daten aus mehreren Drittanbieterquellen:\n\n* API von Brian Fritz (OMDb API)\n Lizenziert unter CC BY-NC 4.0\n Dieser Dienst wird nicht von IMDb.com unterstützt oder mit ihr in Verbindung gebracht\n\n* Diese Anwendung verwendet TMDB und die TMDB-APIs, ist jedoch nicht von TMDB unterstützt, zertifiziert oder anderweitig genehmigt\n\n* Einige Daten stammen von IMDb\n\n* Streaming-Verfügbarkeit und Übersetzungsdienste werden über RapidAPI bereitgestellt\n\n* Trailer werden von YouTube bereitgestellt\n\nKartendaten © OpenStreetMap-Mitwirkende\n\nAlle Marken, Logos und Urheberrechte gehören ihren jeweiligen Eigentümern.';

  @override
  String get playbackDisabledByVideoOwner => 'Wiedergabe vom Videoeigentümer deaktiviert.';

  @override
  String get disclaimerNote => 'Alle Marken, Logos und Daten Dritter bleiben Eigentum ihrer jeweiligen Inhaber; bitte konsultieren Sie deren Nutzungsbedingungen und Datenschutzrichtlinien für Details.';

  @override
  String get add_series_button => 'Serie hinzufügen';

  @override
  String get add_series_title => 'Serie hinzufügen';

  @override
  String get add_series_use_dates => 'Wiederkehrende Tage verwenden';

  @override
  String get add_series_until_date => 'Bis Datum';

  @override
  String get until_label => 'Bis';

  @override
  String get select => 'Auswählen';

  @override
  String get imdb_id_label => 'ID (z. B. tt1234567)';

  @override
  String get title_label => 'Titel';

  @override
  String get number_of_seasons => 'Anzahl Staffeln';

  @override
  String get number_of_episodes => 'Anzahl Episoden';

  @override
  String episodes_in_season(Object season) {
    return 'Episoden in Staffel $season';
  }

  @override
  String get episodes_per_season_hint => 'Episoden pro Staffel (kommagetrennt, z. B. 10,8,12)';

  @override
  String get invalid_series_input => 'Ungültige Eingabe';

  @override
  String get series_added => 'Serie hinzugefügt';

  @override
  String get add_series_failed => 'Hinzufügen der Serie fehlgeschlagen';
}
