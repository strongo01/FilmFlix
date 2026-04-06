// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get myDashboard => 'Mijn Dashboard';

  @override
  String get preferences => 'Voorkeuren';

  @override
  String get notifications => 'Meldingen';

  @override
  String get notifications_enabled => 'Meldingen ingeschakeld';

  @override
  String get notifications_check_system => 'Controleer de systeeminstellingen om meldingen toe te laten.';

  @override
  String get notifications_registration_failed => 'Aanmelden voor notificaties mislukt.';

  @override
  String get language => 'Taal';

  @override
  String get english => 'Engels';

  @override
  String get dutch => 'Nederlands';

  @override
  String get french => 'Frans';

  @override
  String get german => 'Duits';

  @override
  String get turkish => 'Turks';

  @override
  String get spanish => 'Spaans';

  @override
  String get close => 'Sluiten';

  @override
  String get nameLabel => 'Je naam';

  @override
  String get nameValidation => 'Vul je naam in';

  @override
  String get cancel => 'Annuleren';

  @override
  String get save => 'Opslaan';

  @override
  String get mustBeLoggedIn => 'Je moet ingelogd zijn om je naam te wijzigen';

  @override
  String get profile_default_name => 'Kevin le Goat';

  @override
  String get profile_default_email => 'kevinlegoat@example.com';

  @override
  String get filmsDone => 'Films afgekeken';

  @override
  String get watchlist_label => 'Watchlist';

  @override
  String get support => 'Ondersteuning';

  @override
  String get customerService_title => 'Klantenservice';

  @override
  String get aboutTitle => 'Over CineTrackr';

  @override
  String get aboutText => 'CineTrackr\n\nWelkom bij CineTrackr, jouw persoonlijke gids voor films en bioscoopbezoek.\n\nMet CineTrackr kun je eenvoudig filmprogramma\'s bekijken, je eigen watchlist bijhouden en snel toegang krijgen tot bioscooplocaties en klantenservice.\n\nBedankt voor het gebruiken van CineTrackr, veel kijkplezier!';

  @override
  String get privacyPolicy => 'Privacybeleid';

  @override
  String get logout => 'Uitloggen';

  @override
  String get loginIn => 'Inloggen';

  @override
  String get nameUpdated => 'Naam bijgewerkt';

  @override
  String get nameUpdateFailed => 'Bijwerken mislukt';

  @override
  String get admin_title => 'Beheerder';

  @override
  String get tab_chats => 'Chats';

  @override
  String get tab_faqs => 'Veelgestelde vragen';

  @override
  String get not_logged_in_title => 'Niet ingelogd';

  @override
  String get not_logged_in_message => 'Log eerst in als beheerder en probeer het opnieuw.';

  @override
  String get no_users_doc => 'Geen gebruikersdocument gevonden.';

  @override
  String users_doc_role(Object role, Object uid) {
    return 'gebruikers/$uid rol = $role';
  }

  @override
  String users_doc_no_role(Object uid) {
    return 'gebruikers/$uid bestaat, maar heeft geen rol-veld.';
  }

  @override
  String users_doc_read_error(Object error) {
    return 'Fout bij lezen gebruikersdocument: $error';
  }

  @override
  String get send_failed => 'Versturen mislukt';

  @override
  String get check_permissions_title => 'Rechten controleren';

  @override
  String get possible_causes => 'Mogelijke oorzaken en oplossingen:';

  @override
  String get firestore_rules => '- Firestore-regels controleren: regels gebruiken aangepaste claims (request.auth.token.role).';

  @override
  String get custom_claims_hint => '- Als je aangepaste claims gebruikt: zet rol/admin via Admin SDK (service-account) en laat de beheerder opnieuw inloggen.';

  @override
  String rules_temp_change(Object uid) {
    return '- Of wijzig tijdelijk de regels om de rol uit /users/$uid te lezen.';
  }

  @override
  String get current_users_doc => 'Huidig gebruikersdocument:';

  @override
  String get debug_info_title => 'Debug-informatie';

  @override
  String uid_label(Object uid) {
    return 'Gebruikers-ID: $uid';
  }

  @override
  String idtoken_claims_label(Object claims) {
    return 'idToken-claims: $claims';
  }

  @override
  String idtoken_error_label(Object error) {
    return 'idToken-fout: $error';
  }

  @override
  String users_doc_label(Object doc) {
    return 'Gebruikersdocument: $doc';
  }

  @override
  String get ok => 'OK';

  @override
  String get fetch_doc_title => 'Document ophalen via ID';

  @override
  String get paste_doc_id => 'Plak hier het document-ID van de klantvragen:';

  @override
  String get fetch => 'Ophalen';

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
  String get empty => '<leeg>';

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
  String get show_debug_info => 'Toon debug-informatie';

  @override
  String get delete_chat_title => 'Chat verwijderen';

  @override
  String get delete_chat_confirm => 'Weet je zeker dat je deze chat wilt verwijderen? Dit kan niet ongedaan gemaakt worden.';

  @override
  String get delete => 'Verwijderen';

  @override
  String get chat_deleted => 'Chat verwijderd';

  @override
  String get delete_failed => 'Verwijderen mislukt';

  @override
  String get marked_unread => 'Als ongelezen gemarkeerd';

  @override
  String get action_failed => 'Actie mislukt';

  @override
  String get user_label_default => 'Gebruiker';

  @override
  String get reply_hint => 'Typ een antwoord...';

  @override
  String get send => 'Versturen';

  @override
  String get notify_title => 'Nieuw bericht van beheerder';

  @override
  String notify_body(Object text) {
    return '$text';
  }

  @override
  String get no_faq_items => 'Nog geen veelgestelde vragen';

  @override
  String get edit => 'Bewerken';

  @override
  String get remove => 'Verwijderen';

  @override
  String get add_new_faq => 'Nieuwe vraag toevoegen';

  @override
  String get new_faq_title => 'Nieuwe veelgestelde vraag';

  @override
  String get question_label => 'Vraag/Opmerking';

  @override
  String get answer_label => 'Antwoord';

  @override
  String get add => 'Toevoegen';

  @override
  String get faq_added => 'Vraag toegevoegd';

  @override
  String get faq_add_failed => 'Toevoegen mislukt';

  @override
  String get edit_faq_title => 'Vraag bewerken';

  @override
  String get faq_updated => 'Vraag bijgewerkt';

  @override
  String get faq_update_failed => 'Opslaan mislukt';

  @override
  String get delete_faq_title => 'Vraag verwijderen';

  @override
  String get delete_faq_confirm => 'Weet je zeker dat je deze vraag wilt verwijderen?';

  @override
  String get faq_deleted => 'Vraag verwijderd';

  @override
  String get faq_delete_failed => 'Verwijderen mislukt';

  @override
  String admins_label(Object names) {
    return 'Beheerders: $names';
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
  String get navFood => 'Eten';

  @override
  String get navigationReorder => 'Herorden navigatie';

  @override
  String get navProfile => 'Profiel';

  @override
  String get infoTooltip => 'Info';

  @override
  String get watchlistInfoTitle => 'Info';

  @override
  String get watchlistInfoContent => 'De app kan helaas geen gegevens ophalen uit streamingdiensten. Je kunt handmatig afleveringen aanvinken die je hebt gekeken.';

  @override
  String get tutorialHome => 'Hier vind je de nieuwste films en series.';

  @override
  String get tutorialWatchlist => 'Sla hier je favoriete films op voor later.';

  @override
  String get tutorialSearch => 'Zoek naar specifieke titels of genres.';

  @override
  String get tutorialFood => 'Bekijk bijpassende snacks voor je filmavond!';

  @override
  String get tutorialProfile => 'Beheer hier je profiel en instellingen.';

  @override
  String get tutorialNavBar => 'Welkom! Hier kan je het startscherm veranderen. Houd een knop lang ingedrukt om dat scherm je startscherm te maken.';

  @override
  String get tutorialNavBar2 => 'Als je de ruimte tussen de knoppen ingedrukt houdt, kun je de volgorde van de knoppen veranderen.';

  @override
  String get tutorialHomeExtra => 'In dit scherm kan je de films bekijken die net zijn uitgebracht. Door op een film te tikken, zie je meer informatie over deze film.';

  @override
  String get tutorialMainNavigation => 'Hoofd navigatie';

  @override
  String get tutorialMainNavigationDesc => 'Uitleg over de balk en startscherm';

  @override
  String get tutorialHomeScreen => 'In dit scherm kan je de films bekijken die net zijn uitgebracht. Door op een film te tikken, zie je meer informatie over deze film.';

  @override
  String get tutorialHomeScreenDesc => 'Uitleg over het hoofdscherm';

  @override
  String get tutorialResetAll => 'Alles resetten';

  @override
  String get tutorialWatchlistExtra => 'In je Watchlist kun je films verwijderen of later terugkijken.';

  @override
  String get tutorialSearchExtra => 'Gebruik de zoekbalk om snel titels en acteurs te vinden.';

  @override
  String get tutorialFoodExtra => 'Bekijk snacks en recepten die passen bij je filmkeuze.';

  @override
  String get tutorialProfileExtra => 'Beheer instellingen, voorkeuren en accountgegevens in je profiel.';

  @override
  String get tutorialMap => 'Hier kun je de kaart bekijken om bioscopen in de buurt te vinden!';

  @override
  String get resetTutorial => 'Tutorial resetten';

  @override
  String get tutorialResetMessage => 'Tutorial gereset, wordt opnieuw gestart';

  @override
  String get map_all_cinemas_title => 'Bioscopen in Nederland';

  @override
  String map_load_error(Object error) {
    return 'Fout bij laden bioscopen: $error';
  }

  @override
  String get map_location_service_disabled => 'Locatiedienst is uitgeschakeld';

  @override
  String get map_location_permission_denied => 'Locatietoegang geweigerd';

  @override
  String get map_location_permission_denied_forever => 'Locatiepermissies permanent geweigerd. Schakel dit in bij de instellingen.';

  @override
  String map_location_fetch_error(Object error) {
    return 'Kon locatie niet ophalen: $error';
  }

  @override
  String get map_no_website_content => 'Geen website beschikbaar, Bioscoop gevonden! 🎥';

  @override
  String get unknown => 'Onbekend';

  @override
  String get food_edit_favorite => 'Favoriet aanpassen';

  @override
  String get food_name_label => 'Naam';

  @override
  String get food_only_emoji => 'Alleen Emoji';

  @override
  String get food_location => 'Locatie';

  @override
  String get food_diet => 'Dieetwensen';

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
  String get food_postcode_label => 'Postcode (4 cijfers)';

  @override
  String get food_zip_required => 'Vul eerst de 4 cijfers van je postcode in!';

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
  String get open => 'Openen';

  @override
  String get changeNameTitle => 'Wijzig je naam';

  @override
  String get updateFailed => 'Bijwerken mislukt';

  @override
  String get enter_name_description => 'We gebruiken je naam om de app persoonlijker te maken, bijvoorbeeld voor begroetingen.';

  @override
  String get save_and_continue => 'Opslaan en doorgaan';

  @override
  String get contact_admin_title => 'Contact met beheerder';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get contactNameLabel => 'Naam';

  @override
  String get contactQuestionLabel => 'Vraag';

  @override
  String get question_validation => 'Vul je vraag in';

  @override
  String get mustBeLoggedInToSend => 'Je moet ingelogd zijn om te kunnen versturen';

  @override
  String get question_sent => 'Vraag verstuurd';

  @override
  String get ai_max_reached => 'Je hebt het maximale aantal AI-vragen voor vandaag gebruikt. Probeer het morgen opnieuw.';

  @override
  String get ask_ai_title => 'Vraag AI';

  @override
  String get ai_wait => 'Even geduld, dit kan tot een minuut duren';

  @override
  String get ai_answer_title => 'AI-antwoord';

  @override
  String ai_answer_title_with_model(Object model) {
    return 'AI-antwoord ($model)';
  }

  @override
  String get ai_failed_all => 'AI-aanvraag is mislukt voor alle modellen.';

  @override
  String get ai_failed => 'AI-aanvraag is mislukt.';

  @override
  String get login_required_title => 'Inloggen vereist';

  @override
  String get login_required_message => 'Je moet ingelogd zijn om dit te doen. Wil je naar het inlogscherm?';

  @override
  String get goto_login => 'Naar inloggen';

  @override
  String get search_faqs_hint => 'Zoek in veelgestelde vragen';

  @override
  String get no_faq_matches => 'Geen resultaten in veelgestelde vragen';

  @override
  String ai_questions_used(Object max, Object used) {
    return 'AI-vragen: $used/$max gebruikt';
  }

  @override
  String ask_ai_with_cooldown(Object seconds) {
    return 'Vraag AI ($seconds)';
  }

  @override
  String get contact_admin_button => 'Contact beheerder';

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
  String get faq_default_watchlist_a => 'Open de filmpagina en klik op de knop \"Opslaan\" (bladwijzer-icoon) om de film aan je watchlist toe te voegen.';

  @override
  String get faq_missing_info_q => 'Waarom mist een aflevering of seizoen informatie?';

  @override
  String get faq_missing_info_a => 'Onze gegevens komen van externe providers; soms ontbreken er metadata. Probeer het later opnieuw of meld het via \'Contact beheerder\'.';

  @override
  String get faq_report_bug_q => 'Hoe kan ik een fout in de app melden?';

  @override
  String get faq_report_bug_a => 'Gebruik de knop \"Contact beheerder\" hieronder om een e-mail te sturen met een beschrijving en eventueel screenshots.';

  @override
  String get faq_ai_q => 'Kan ik vragen aan een AI stellen?';

  @override
  String get faq_ai_a => 'Ja, gebruik de knop \"Vraag AI\" om een vraag te stellen. Houd er rekening mee dat antwoorden automatisch gegenereerd zijn.';

  @override
  String get admins_no_push => 'Beheerders ontvangen mogelijk geen pushmeldingen';

  @override
  String ai_cooldown_wait(Object seconds) {
    return 'Wacht nog $seconds seconden voordat je opnieuw de AI kunt gebruiken.';
  }

  @override
  String get ai_input_hint => 'Typ hier je vraag over films of series...';

  @override
  String get user_new_message_title => 'Nieuw bericht van gebruiker';

  @override
  String get nowPlayingTitle => 'Nu in de bioscoop';

  @override
  String get imdbIdUnavailable => 'IMDb-ID niet beschikbaar voor deze film';

  @override
  String get cannot_load_now_playing => 'Kon actuele films niet laden.';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get no_films_found => 'Geen films gevonden';

  @override
  String get loginWelcome => 'Welkom bij CineTrackr';

  @override
  String get loginCreateAccount => 'Account aanmaken';

  @override
  String get loginName => 'Naam';

  @override
  String get loginNameRequired => 'Vul je naam in';

  @override
  String get loginEmail => 'E-mail';

  @override
  String get loginEmailRequired => 'Vul je e-mailadres in';

  @override
  String get loginInvalidEmail => 'Ongeldig e-mailadres';

  @override
  String get loginPassword => 'Wachtwoord';

  @override
  String get loginPasswordRequired => 'Vul je wachtwoord in';

  @override
  String get loginPasswordTooShort => 'Wachtwoord moet minstens 6 tekens bevatten';

  @override
  String get loginRegister => 'Registreren';

  @override
  String get loginNoAccountRegister => 'Nog geen account? Registreer hier';

  @override
  String get loginHaveAccountLogin => 'Al een account? Log hier in';

  @override
  String get loginForgotPassword => 'Wachtwoord vergeten?';

  @override
  String get loginContinueAsGuest => 'Doorgaan als gast';

  @override
  String get loginOrDivider => 'OF';

  @override
  String get loginSignInWithGoogle => 'Inloggen met Google';

  @override
  String get loginSignInWithGitHub => 'Inloggen met GitHub';

  @override
  String get loginSignInWithApple => 'Inloggen met Apple';

  @override
  String get loginEnterValidEmail => 'Vul een geldig e-mailadres in';

  @override
  String get loginPasswordResetEmailSent => 'E-mail voor wachtwoordherstel verzonden';

  @override
  String get loginPasswordResetFailed => 'Kon geen herstel-e-mail sturen';

  @override
  String get loginSomethingWentWrong => 'Er is iets misgegaan';

  @override
  String get authenticationFailed => 'Authenticatie mislukt';

  @override
  String get loginGithubFailed => 'GitHub-login mislukt';

  @override
  String get googleIdTokenError => 'Fout bij ophalen van Google ID-token';

  @override
  String get googleSignInCancelled => 'Google-aanmelding geannuleerd';

  @override
  String get loginErrorCredentialMalformed => 'De opgegeven inloggegevens zijn ongeldig of verlopen.';

  @override
  String get loginErrorUserDisabled => 'Dit account is uitgeschakeld.';

  @override
  String get loginErrorTooManyRequests => 'Te veel mislukte pogingen. We hebben alle verzoeken van dit apparaat tijdelijk geblokkeerd.';

  @override
  String get loginErrorInvalidEmail => 'Het e-mailadres is ongeldig.';

  @override
  String get loginErrorWrongPassword => 'Onjuist wachtwoord.';

  @override
  String get loginErrorUserNotFound => 'Geen gebruiker gevonden met dit e-mailadres.';

  @override
  String get loginErrorAccountExists => 'Er bestaat al een account met dit e-mailadres via een andere inlogmethode.';

  @override
  String get details => 'Details';

  @override
  String get translate => 'Vertalen';

  @override
  String get seen => 'Gezien';

  @override
  String age_rating(Object rated) {
    return 'Leeftijdsclassificatie: $rated';
  }

  @override
  String get producers_creators => 'Producenten / Makers';

  @override
  String get actors => 'Acteurs';

  @override
  String seasons(Object count) {
    return 'Seizoenen: $count';
  }

  @override
  String episodes(Object count) {
    return 'Afleveringen: $count';
  }

  @override
  String get streaming => 'Streaming';

  @override
  String seasons_episodes_title(Object count) {
    return 'Seizoenen & Afleveringen ($count)';
  }

  @override
  String get no_seasons_found => 'Geen seizoenen gevonden';

  @override
  String get no_episodes_found => 'Geen afleveringen gevonden';

  @override
  String get warning_title => '!! Waarschuwing !!';

  @override
  String get warning_bioscoop_content => 'Klik eerst eventuele reclames of pop-ups op de website weg voordat je de agenda bekijkt.';

  @override
  String get continue_label => 'Doorgaan';

  @override
  String get mark_previous_episodes_title => 'Vorige afleveringen markeren?';

  @override
  String mark_previous_episodes_message(Object count, Object season, Object title) {
    return 'Je markeert \"$title\" als gezien. Wil je ook $count vorige aflevering(en) van seizoen $season markeren als gezien?';
  }

  @override
  String episodes_marked_seen(Object count) {
    return '$count afleveringen gemarkeerd als gezien';
  }

  @override
  String get watchlist_update_failed => 'Kon watchlist niet bijwerken.';

  @override
  String get episode_status_update_failed => 'Kon afleveringstatus niet bijwerken.';

  @override
  String get movie_seen_update_failed => 'Kon \'Gezien\'-status niet bijwerken.';

  @override
  String get included_with_subscription => 'Inbegrepen';

  @override
  String get buy => 'Kopen';

  @override
  String buy_with_price(Object price) {
    return 'Kopen • $price';
  }

  @override
  String get rent => 'Huren';

  @override
  String rent_with_price(Object price) {
    return 'Huren • $price';
  }

  @override
  String get addon => 'Uitbreiding';

  @override
  String addon_with_price(Object price) {
    return 'Uitbreiding • $price';
  }

  @override
  String get details_streaming_warning => 'Klik om de streaminglink te openen';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nee';

  @override
  String get stars => 'sterren';

  @override
  String get appleSignInNoIdentityToken => 'Apple-aanmelding mislukt: geen identiteitstoken ontvangen';

  @override
  String get googleSignInFailed => 'Google-aanmelding mislukt';

  @override
  String get loginErrorWeakPassword => 'Wachtwoord is te zwak.';

  @override
  String get loginErrorNetworkFailed => 'Netwerkfout. Controleer je verbinding.';

  @override
  String get loginErrorRequiresRecentLogin => 'Log opnieuw in om door te gaan (recente aanmelding vereist).';

  @override
  String get avatar_login_prompt => 'Log in om je profielfoto aan te passen';

  @override
  String get invalid_input => 'Ongeldige invoer';

  @override
  String get only_emoji_error => 'Voer alleen emoji\'s in';

  @override
  String get use => 'Gebruik';

  @override
  String get emoji_input_hint => 'Plak of typ een emoji (optioneel)';

  @override
  String get edit_avatar_title => 'Profielfoto aanpassen';

  @override
  String get choose_color => 'Kies een kleur';

  @override
  String get choose_emoji_optional => 'Kies een emoji (optioneel)';

  @override
  String get your_badges => 'JOUW BADGES';

  @override
  String get account_section => 'ACCOUNT';

  @override
  String get edit_profile => 'Profiel bewerken';

  @override
  String get films => 'Films';

  @override
  String get badge_level_prefix => 'Lv';

  @override
  String get badge_adventurer => 'Avonturier';

  @override
  String get badge_horror_king => 'Horror-koning';

  @override
  String get badge_binge_watcher => 'Binge-watcher';

  @override
  String get badge_early_bird => 'Vroege vogel';

  @override
  String get appVersion => 'CineTrackr v1.0.4';

  @override
  String get search_hint => 'Zoek serie of film...';

  @override
  String get clear_tooltip => 'Wissen';

  @override
  String get filter_tooltip => 'Filteren';

  @override
  String get filter_refine_title => 'Filters verfijnen';

  @override
  String get filter_type_label => 'TYPE';

  @override
  String get filter_all => 'Alles';

  @override
  String get filter_movies => 'Films';

  @override
  String get filter_series => 'Series';

  @override
  String get filter_keyword_label => 'ZOEKWOORD';

  @override
  String get filter_keyword_hint => 'Bijv. Batman, Marvel...';

  @override
  String get filter_genres_label => 'GENRES';

  @override
  String get filter_year_from_label => 'JAAR (VANAF)';

  @override
  String get filter_year_to_label => 'JAAR (TOT)';

  @override
  String get filter_min_rating_label => 'MINIMALE SCORE (0-100)';

  @override
  String get apply_filters => 'Filters toepassen';

  @override
  String get tmdb_movie_fetch_failed => 'Kon filmdetails niet ophalen';

  @override
  String get no_imdb_for_movie => 'Geen IMDb-ID gevonden voor deze film';

  @override
  String get tmdb_movie_fetch_error => 'Fout bij ophalen filmdetails';

  @override
  String get tmdb_series_fetch_failed => 'Kon seriedetails niet ophalen';

  @override
  String get no_imdb_for_series => 'Geen IMDb-ID gevonden voor deze serie';

  @override
  String get tmdb_series_fetch_error => 'Fout bij ophalen seriedetails';

  @override
  String get load_more_results => 'Laad meer resultaten';

  @override
  String get best_rated => 'Best beoordeeld';

  @override
  String get popular => 'Populair';

  @override
  String get genre_action => 'Actie';

  @override
  String get genre_adventure => 'Avontuur';

  @override
  String get genre_animation => 'Animatie';

  @override
  String get genre_comedy => 'Komedie';

  @override
  String get genre_crime => 'Misdaad';

  @override
  String get genre_documentary => 'Documentaire';

  @override
  String get genre_drama => 'Drama';

  @override
  String get genre_family => 'Familie';

  @override
  String get genre_fantasy => 'Fantasie';

  @override
  String get genre_history => 'Geschiedenis';

  @override
  String get genre_horror => 'Horror';

  @override
  String get genre_music => 'Muziek';

  @override
  String get genre_mystery => 'Mysterie';

  @override
  String get genre_news => 'Nieuws';

  @override
  String get genre_reality => 'Reality';

  @override
  String get genre_romance => 'Romantiek';

  @override
  String get genre_scifi => 'Sciencefiction';

  @override
  String get genre_talk => 'Talkshow';

  @override
  String get genre_thriller => 'Thriller';

  @override
  String get genre_war => 'Oorlog';

  @override
  String get genre_western => 'Western';

  @override
  String get login_progress_save_snack => 'Log in om voortgang op te slaan';

  @override
  String get progress_update_failed => 'Kon voortgang niet bijwerken';

  @override
  String get open_details => 'Open details';

  @override
  String get label_series => 'Series';

  @override
  String seen_count(Object count) {
    return 'Gezien: $count';
  }

  @override
  String get remove_from_watchlist_tooltip => 'Verwijder uit watchlist';

  @override
  String get login_manage_watchlist_snack => 'Log in om je watchlist te beheren';

  @override
  String get item_removed_watchlist => 'Item verwijderd uit watchlist';

  @override
  String get remove_item_failed => 'Kon item niet verwijderen';

  @override
  String get remove_from_watchlist_title => 'Verwijderen uit watchlist';

  @override
  String get remove_from_watchlist_confirm => 'Weet je zeker dat je dit item uit je watchlist wilt verwijderen?';

  @override
  String get tab_saved => 'Opgeslagen';

  @override
  String get tab_watching => 'Aan het kijken';

  @override
  String get watchlist_not_logged_in => 'Je bent nog niet ingelogd.';

  @override
  String get watchlist_login_tap_message => 'Tik hier om in te loggen en je watchlist te bekijken.';

  @override
  String error_loading(Object error) {
    return 'Fout bij laden: $error';
  }

  @override
  String get no_items => 'Geen items gevonden';

  @override
  String season_label(Object number) {
    return 'Seizoen $number';
  }

  @override
  String season_short(Object num) {
    return 'S$num';
  }

  @override
  String seen_x_of_y(Object seen, Object total) {
    return '$seen/$total gezien';
  }

  @override
  String title_wait(Object title) {
    return '$title: een moment geduld...';
  }

  @override
  String get no_progress_for_films => 'Nog geen voortgang voor films';

  @override
  String get episode => 'Aflevering';

  @override
  String seen_episodes_label(Object count) {
    return 'Gezien afleveringen: $count';
  }

  @override
  String get disclaimerTitle => 'Disclaimer';

  @override
  String get disclaimerHeading => 'Derden & APIs';

  @override
  String get disclaimerText => 'Deze app gebruikt gegevens van meerdere externe bronnen:\n\n* API door Brian Fritz (OMDb API)\n Gelicentieerd onder CC BY-NC 4.0\n Deze dienst is niet goedgekeurd door of verbonden met IMDb.com\n\n* Deze applicatie maakt gebruik van TMDB en de TMDB API’s maar is niet goedgekeurd, gecertificeerd of anderszins ondersteund door TMDB\n\n* Sommige gegevens zijn afkomstig van IMDb\n\n* Streaminginformatie en vertaaldiensten worden geleverd via RapidAPI\n\n* Trailers worden geleverd door YouTube\n\nKaartgegevens © OpenStreetMap contributors\n\nAlle handelsmerken, logo’s en auteursrechten behoren toe aan hun respectieve eigenaren';

  @override
  String get playbackDisabledByVideoOwner => 'Afspelen uitgeschakeld door de eigenaar van de video.';

  @override
  String get disclaimerNote => 'Gebruik en weergave van content is onderhevig aan de voorwaarden en licenties van bovengenoemde diensten.';

  @override
  String get add_series_button => 'Serie toevoegen';

  @override
  String get add_series_title => 'Serie toevoegen';

  @override
  String get add_series_use_dates => 'Gebruik terugkerende dagen';

  @override
  String get add_series_until_date => 'Tot en met datum';

  @override
  String get until_label => 'Tot en met';

  @override
  String get select => 'Kies';

  @override
  String get imdb_id_label => 'ID (bijv. tt1234567)';

  @override
  String get title_label => 'Titel';

  @override
  String get number_of_seasons => 'Aantal seizoenen';

  @override
  String get number_of_episodes => 'Aantal afleveringen';

  @override
  String episodes_in_season(Object season) {
    return 'Afleveringen in seizoen $season';
  }

  @override
  String get episodes_per_season_hint => 'Afleveringen per seizoen (komma-gescheiden, bv. 10,8,12)';

  @override
  String get invalid_series_input => 'Ongeldige invoer';

  @override
  String get series_added => 'Serie toegevoegd';

  @override
  String get add_series_failed => 'Toevoegen mislukt';

  @override
  String set_as_start_screen(Object label) {
    return '$label ingesteld als startscherm';
  }

  @override
  String get save_failed => 'Opslaan mislukt';

  @override
  String get label_biosagenda => 'Biosagenda';

  @override
  String get label_kinepolis => 'Kinepolis';

  @override
  String get tutorialSearchField => 'Typ hier de naam van een film of serie om te zoeken.';

  @override
  String get tutorialSearchFilter => 'Gebruik deze knop om uitgebreid te filteren op genre, jaar of beoordeling.';

  @override
  String get tutorialSearchTabs => 'Schakel hier tussen de best beoordeelde en populairste titels.';

  @override
  String get tutorialSearchScreenMain => 'Zoek scherm';

  @override
  String get tutorialSearchScreenDesc => 'Uitleg over het zoekscherm';
}
