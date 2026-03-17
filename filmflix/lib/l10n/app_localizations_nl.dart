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
}
