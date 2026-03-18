// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get admin_title => 'Admin';

  @override
  String get tab_chats => 'Chats';

  @override
  String get tab_faqs => 'FAQs';

  @override
  String get not_logged_in_title => 'Niet ingelogd';

  @override
  String get not_logged_in_message => 'Log eerst in als admin en probeer het opnieuw.';

  @override
  String get close => 'Sluiten';

  @override
  String get no_users_doc => 'Geen users-doc gevonden.';

  @override
  String users_doc_role(Object role, Object uid) {
    return 'users/$uid role = $role';
  }

  @override
  String users_doc_no_role(Object uid) {
    return 'users/$uid bestaat, maar heeft geen role-veld.';
  }

  @override
  String users_doc_read_error(Object error) {
    return 'Fout bij lezen users-doc: $error';
  }

  @override
  String get send_failed => 'Versturen mislukt';

  @override
  String get check_permissions_title => 'Rechten controleren';

  @override
  String get possible_causes => 'Mogelijke oorzaken en oplossingen:';

  @override
  String get firestore_rules => '- Firestore rules controleren: regels gebruiken custom claims (request.auth.token.role).';

  @override
  String get custom_claims_hint => '- Als je custom claims gebruikt: zet role/admin via Admin SDK (service account) en laat admin opnieuw inloggen.';

  @override
  String rules_temp_change(Object uid) {
    return '- Of wijzig tijdelijk de rules om de rol uit /users/$uid te lezen.';
  }

  @override
  String get current_users_doc => 'Huidige users-doc:';

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
  String get paste_doc_id => 'Plak hier het document ID van customerquestions:';

  @override
  String get cancel => 'Annuleer';

  @override
  String get fetch => 'Fetch';

  @override
  String get not_found_title => 'Niet gevonden';

  @override
  String document_not_found(Object id) {
    return 'Document $id bestaat niet of is niet leesbaar.';
  }

  @override
  String document_title(Object id) {
    return 'Document $id';
  }

  @override
  String get empty => '<empty>';

  @override
  String get fetch_error_title => 'Fout';

  @override
  String fetch_error_message(Object error) {
    return 'Fout bij ophalen: $error';
  }

  @override
  String cannot_load_chats(Object error) {
    return 'Kan geen chats laden: $error';
  }

  @override
  String get no_questions_found => 'Geen vragen gevonden';

  @override
  String get show_debug_info => 'Toon debug info';

  @override
  String get delete_chat_title => 'Verwijder chat';

  @override
  String get delete_chat_confirm => 'Weet je zeker dat je deze chat wilt verwijderen? Dit kan niet ongedaan gemaakt worden.';

  @override
  String get delete => 'Verwijder';

  @override
  String get chat_deleted => 'Chat verwijderd';

  @override
  String get delete_failed => 'Verwijderen mislukt';

  @override
  String get user_label_default => 'Gebruiker';

  @override
  String get reply_hint => 'Typ een antwoord...';

  @override
  String get send => 'Verstuur';

  @override
  String get notify_title => 'Nieuw bericht van admin';

  @override
  String notify_body(Object text) {
    return '$text';
  }

  @override
  String get no_faq_items => 'Nog geen FAQ items';

  @override
  String get edit => 'Bewerk';

  @override
  String get remove => 'Verwijder';

  @override
  String get add_new_faq => 'Nieuwe FAQ toevoegen';

  @override
  String get new_faq_title => 'Nieuwe FAQ';

  @override
  String get question_label => 'Question';

  @override
  String get answer_label => 'Answer';

  @override
  String get add => 'Voeg toe';

  @override
  String get faq_added => 'FAQ toegevoegd';

  @override
  String get faq_add_failed => 'Toevoegen mislukt';

  @override
  String get edit_faq_title => 'Bewerk FAQ';

  @override
  String get save => 'Opslaan';

  @override
  String get faq_updated => 'FAQ bijgewerkt';

  @override
  String get faq_update_failed => 'Opslaan mislukt';

  @override
  String get delete_faq_title => 'Verwijder FAQ';

  @override
  String get delete_faq_confirm => 'Weet je zeker dat je deze FAQ wilt verwijderen?';

  @override
  String get faq_deleted => 'FAQ verwijderd';

  @override
  String get faq_delete_failed => 'Verwijderen mislukt';

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
  String get navSearch => 'Zoeken';

  @override
  String get navFood => 'Food';

  @override
  String get navProfile => 'Profiel';

  @override
  String get tutorialHome => 'Welkom! Hier vind je de nieuwste films en series.';

  @override
  String get tutorialWatchlist => 'Sla hier je favoriete films op voor later.';

  @override
  String get tutorialSearch => 'Zoek naar specifieke titels of genres.';

  @override
  String get tutorialFood => 'Bekijk bijpassende snacks voor je filmavond!';

  @override
  String get tutorialProfile => 'Beheer hier je profiel en instellingen.';

  @override
  String get tutorialMap => 'Hier kun je de kaart bekijken om bioscopen in de buurt te vinden!';

  @override
  String get food_edit_favorite => 'Pas favoriet aan';

  @override
  String get food_name_label => 'Naam';

  @override
  String get food_only_emoji => 'Alleen Emoji';

  @override
  String get food_location => 'Locatie';

  @override
  String get food_diet => 'Dieetwens';

  @override
  String get food_diet_info => 'Let op: Het aanbod van restaurants met specifieke dieetopties kan variëren per regio.';

  @override
  String get food_hold_to_edit => 'Houd een icoon ingedrukt om aan te passen';

  @override
  String get food_quick_pizza => 'Pizza';

  @override
  String get food_quick_sushi => 'Sushi';

  @override
  String get food_quick_burger => 'Burger';

  @override
  String get food_quick_kapsalon => 'Kapsalon';

  @override
  String get food_search_hint => 'Zelf iets zoeken...';

  @override
  String get food_search_button => 'ZOEK OP THUISBEZORGD';

  @override
  String get filter_vegetarian => 'Vegetarisch';

  @override
  String get filter_vegan => 'Vegan';

  @override
  String get filter_gluten_free => 'Glutenvrij';

  @override
  String get filter_halal => 'Halal';

  @override
  String get food_what_do_you_want => 'Wat wil je eten?';

  @override
  String get tutorialSkip => 'Overslaan';

  @override
  String get ellipsis => '...';

  @override
  String get open => 'Open';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get myDashboard => 'Mijn Dashboard';

  @override
  String get preferences => 'Voorkeuren';

  @override
  String get support => 'Support';

  @override
  String get notifications => 'Meldingen';

  @override
  String get language => 'Taal';

  @override
  String get dutch => 'Nederlands';

  @override
  String get mustBeLoggedIn => 'Je moet ingelogd zijn om je naam te wijzigen';

  @override
  String get changeNameTitle => 'Wijzig je naam';

  @override
  String get nameLabel => 'Je naam';

  @override
  String get nameValidation => 'Vul je naam in';

  @override
  String get nameUpdated => 'Naam bijgewerkt';

  @override
  String get updateFailed => 'Bijwerken mislukt';

  @override
  String get customerService_title => 'Klantenservice';

  @override
  String get contact_admin_title => 'Contact admin';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get contactNameLabel => 'Naam';

  @override
  String get contactQuestionLabel => 'Vraag';

  @override
  String get question_validation => 'Vul je vraag in';

  @override
  String get mustBeLoggedInToSend => 'Je moet ingelogd zijn om te versturen';

  @override
  String get question_sent => 'Vraag verstuurd';

  @override
  String get ai_max_reached => 'Je hebt het maximale aantal AI-vragen voor vandaag gebruikt. Probeer morgen opnieuw.';

  @override
  String get ask_ai_title => 'Vraag AI';

  @override
  String get ai_wait => 'Even geduld, dit kan tot een minuut duren';

  @override
  String get ai_answer_title => 'AI Antwoord';

  @override
  String ai_answer_title_with_model(Object model) {
    return 'AI Antwoord ($model)';
  }

  @override
  String get ai_failed_all => 'AI aanvraag is mislukt voor alle modellen.';

  @override
  String get ai_failed => 'AI aanvraag is mislukt.';

  @override
  String get login_required_title => 'Inloggen vereist';

  @override
  String get login_required_message => 'Je moet ingelogd zijn om dit te doen. Wil je naar het login-scherm?';

  @override
  String get goto_login => 'Naar login';

  @override
  String get search_faqs_hint => 'Zoek in veelgestelde vragen';

  @override
  String get no_faq_matches => 'Geen FAQ matches';

  @override
  String ai_questions_used(Object max, Object used) {
    return 'AI-vragen: $used/$max gebruikt';
  }

  @override
  String ask_ai_with_cooldown(Object seconds) {
    return 'Vraag AI ($seconds)';
  }

  @override
  String get contact_admin_button => 'Contact admin';

  @override
  String get my_questions => 'Mijn vragen';

  @override
  String get no_questions_sent => 'Je hebt nog geen vragen gestuurd.';

  @override
  String get message_sent => 'Bericht verstuurd';

  @override
  String get followup_title => 'Reageer op je vraag';

  @override
  String get enter_message_hint => 'Typ een bericht...';

  @override
  String get faq_default_account_q => 'Hoe maak ik een account aan?';

  @override
  String get faq_default_account_a => 'Je kunt je registreren via het profiel-icoon rechtsboven in de app. Volg de stappen om een nieuw account aan te maken.';

  @override
  String get faq_default_watchlist_q => 'Hoe voeg ik een film toe aan mijn watchlist?';

  @override
  String get faq_default_watchlist_a => 'Open de filmpagina en klik op de knop \"Opslaan\" (bookmark-icoon) om de film aan je watchlist toe te voegen.';

  @override
  String get faq_missing_info_q => 'Waarom mist een aflevering of seizoen informatie?';

  @override
  String get faq_missing_info_a => 'Onze data komt van externe providers; soms ontbreken metadata. Probeer later opnieuw of meld het via Contact admin.';

  @override
  String get faq_report_bug_q => 'Hoe kan ik een fout in de app melden?';

  @override
  String get faq_report_bug_a => 'Gebruik de knop \"Contact admin\" hieronder om een e-mail te sturen met een beschrijving en screenshots.';

  @override
  String get faq_ai_q => 'Kan ik vragen aan een AI stellen?';

  @override
  String get faq_ai_a => 'Ja — gebruik de knop \"Vraag AI\" om een vraag te stellen. Houd er rekening mee dat antwoorden automatisch gegenereerd zijn.';

  @override
  String get admins_no_push => 'Admins ontvangen mogelijk geen pushmeldingen';

  @override
  String ai_cooldown_wait(Object seconds) {
    return 'Wacht nog $seconds seconden voordat je opnieuw de AI kunt gebruiken.';
  }

  @override
  String get ai_input_hint => 'Typ hier je vraag over films of series...';

  @override
  String get user_new_message_title => 'Nieuw bericht van gebruiker';

  @override
  String get nowPlayingTitle => 'Actuele films';

  @override
  String get imdbIdUnavailable => 'IMDb ID niet beschikbaar voor deze film';

  @override
  String get cannot_load_now_playing => 'Kon actuele films niet laden.';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get no_films_found => 'Geen films gevonden';
}
