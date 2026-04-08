// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get myDashboard => 'Mon Tableau de bord';

  @override
  String get preferences => 'Préférences';

  @override
  String get notifications => 'Notifications';

  @override
  String get notifications_enabled => 'Notifications activées';

  @override
  String get notifications_check_system => 'Vérifiez les paramètres système pour autoriser les notifications.';

  @override
  String get notifications_registration_failed => 'Échec de l\'enregistrement aux notifications.';

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get dutch => 'Néerlandais';

  @override
  String get french => 'Français';

  @override
  String get german => 'Allemand';

  @override
  String get turkish => 'Turc';

  @override
  String get spanish => 'Espagnol';

  @override
  String get close => 'Fermer';

  @override
  String get nameLabel => 'Votre nom';

  @override
  String get nameValidation => 'Veuillez entrer votre nom';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get mustBeLoggedIn => 'Vous devez être connecté pour modifier votre nom';

  @override
  String get profile_default_name => 'Kevin le Goat';

  @override
  String get profile_default_email => 'kevinlegoat@example.com';

  @override
  String get filmsDone => 'Films terminés';

  @override
  String get watchlist_label => 'Watchlist';

  @override
  String get support => 'Support';

  @override
  String get customerService_title => 'Service client';

  @override
  String get aboutTitle => 'À propos de CineTrackr';

  @override
  String get aboutText => 'CineTrackr\n\nBienvenue sur CineTrackr, votre guide personnel pour les films et vos sorties au cinéma.\n\nAvec CineTrackr, vous pouvez facilement consulter les programmes, gérer votre liste de favoris et accéder rapidement aux cinémas locaux ainsi qu\'au service client.\n\nMerci d\'utiliser CineTrackr, bon visionnage !';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get logout => 'Déconnexion';

  @override
  String get loginIn => 'Connexion';

  @override
  String get nameUpdated => 'Nom mis à jour';

  @override
  String get nameUpdateFailed => 'Échec de la mise à jour';

  @override
  String get admin_title => 'Admin';

  @override
  String get tab_chats => 'Chats';

  @override
  String get tab_faqs => 'FAQs';

  @override
  String get not_logged_in_title => 'Non connecté';

  @override
  String get not_logged_in_message => 'Veuillez vous connecter en tant qu\'admin et réessayer.';

  @override
  String get no_users_doc => 'Aucun document utilisateur trouvé.';

  @override
  String users_doc_role(Object role, Object uid) {
    return 'users/$uid rôle = $role';
  }

  @override
  String users_doc_no_role(Object uid) {
    return 'users/$uid existe, mais n\'a pas de champ rôle.';
  }

  @override
  String users_doc_read_error(Object error) {
    return 'Erreur lors de la lecture du document utilisateur : $error';
  }

  @override
  String get send_failed => 'Échec de l\'envoi';

  @override
  String get check_permissions_title => 'Vérifier les permissions';

  @override
  String get possible_causes => 'Causes possibles et solutions :';

  @override
  String get firestore_rules => '- Vérifier les règles Firestore : les règles utilisent des \'custom claims\' (request.auth.token.role).';

  @override
  String get custom_claims_hint => '- Si vous utilisez des claims personnalisés : définissez rôle/admin via l\'Admin SDK et demandez à l\'admin de se reconnecter.';

  @override
  String rules_temp_change(Object uid) {
    return '- Ou modifiez temporairement les règles pour lire le rôle depuis /users/$uid.';
  }

  @override
  String get current_users_doc => 'Document utilisateur actuel :';

  @override
  String get debug_info_title => 'Infos de débogage';

  @override
  String uid_label(Object uid) {
    return 'uid : $uid';
  }

  @override
  String idtoken_claims_label(Object claims) {
    return 'Claims idToken : $claims';
  }

  @override
  String idtoken_error_label(Object error) {
    return 'Erreur idToken : $error';
  }

  @override
  String users_doc_label(Object doc) {
    return 'Doc utilisateur : $doc';
  }

  @override
  String get ok => 'OK';

  @override
  String get fetch_doc_title => 'Récupérer le document par ID';

  @override
  String get paste_doc_id => 'Collez ici l\'ID du document de customerquestions :';

  @override
  String get fetch => 'Récupérer';

  @override
  String get not_found_title => 'Non trouvé';

  @override
  String document_not_found(Object id) {
    return 'Le document $id n\'existe pas ou est illisible.';
  }

  @override
  String document_title(Object id) {
    return 'Document $id';
  }

  @override
  String get empty => '<vide>';

  @override
  String get fetch_error_title => 'Erreur';

  @override
  String fetch_error_message(Object error) {
    return 'Erreur de récupération : $error';
  }

  @override
  String cannot_load_chats(Object error) {
    return 'Impossible de charger les chats : $error';
  }

  @override
  String get no_questions_found => 'Aucune question trouvée';

  @override
  String get show_debug_info => 'Afficher les infos de débogage';

  @override
  String get delete_chat_title => 'Supprimer le chat';

  @override
  String get delete_chat_confirm => 'Êtes-vous sûr de vouloir supprimer ce chat ? Cette action est irréversible.';

  @override
  String get delete => 'Supprimer';

  @override
  String get chat_deleted => 'Chat supprimé';

  @override
  String get delete_failed => 'Échec de la suppression';

  @override
  String get marked_unread => 'Marqué comme non lu';

  @override
  String get action_failed => 'Action échouée';

  @override
  String get user_label_default => 'Utilisateur';

  @override
  String get reply_hint => 'Tapez une réponse...';

  @override
  String get send => 'Envoyer';

  @override
  String get notify_title => 'Nouveau message de l\'admin';

  @override
  String notify_body(Object text) {
    return '$text';
  }

  @override
  String get no_faq_items => 'Aucun élément de FAQ pour le moment';

  @override
  String get edit => 'Modifier';

  @override
  String get remove => 'Supprimer';

  @override
  String get add_new_faq => 'Ajouter une nouvelle FAQ';

  @override
  String get new_faq_title => 'Nouvelle FAQ';

  @override
  String get question_label => 'Question/Commentaire';

  @override
  String get answer_label => 'Réponse';

  @override
  String get add => 'Ajouter';

  @override
  String get faq_added => 'FAQ ajoutée';

  @override
  String get faq_add_failed => 'Échec de l\'ajout';

  @override
  String get edit_faq_title => 'Modifier la FAQ';

  @override
  String get faq_updated => 'FAQ mise à jour';

  @override
  String get faq_update_failed => 'Échec de l\'enregistrement';

  @override
  String get delete_faq_title => 'Supprimer la FAQ';

  @override
  String get delete_faq_confirm => 'Êtes-vous sûr de vouloir supprimer cette FAQ ?';

  @override
  String get faq_deleted => 'FAQ supprimée';

  @override
  String get faq_delete_failed => 'Échec de la suppression';

  @override
  String admins_label(Object names) {
    return 'Admins : $names';
  }

  @override
  String chat_page_title_prefix(Object prefix) {
    return 'Chat : $prefix';
  }

  @override
  String get appTitle => 'CineTrackr';

  @override
  String get navHome => 'Accueil';

  @override
  String get navWatchlist => 'Watchlist';

  @override
  String get navSearch => 'Recherche';

  @override
  String get navFood => 'Food';

  @override
  String get navigationReorder => 'Réorganiser la navigation';

  @override
  String get navProfile => 'Profil';

  @override
  String get infoTooltip => 'Info';

  @override
  String get watchlistInfoTitle => 'Info';

  @override
  String get watchlistInfoContent => 'L\'application ne peut malheureusement pas récupérer les données des services de streaming. Vous pouvez marquer manuellement les épisodes que vous avez regardés.';

  @override
  String get tutorialHome => 'Retrouvez ici les derniers films et séries.';

  @override
  String get tutorialWatchlist => 'Enregistrez ici vos films préférés pour plus tard.';

  @override
  String get tutorialSearch => 'Recherchez des titres ou des genres spécifiques.';

  @override
  String get tutorialFood => 'Découvrez des snacks pour votre soirée cinéma !';

  @override
  String get tutorialProfile => 'Gérez ici votre profil et vos paramètres.';

  @override
  String get tutorialNavBar => 'Bienvenue ! Ici, vous pouvez changer l\'écran de démarrage. Appuyez longuement sur un bouton pour définir cet écran comme écran d\'accueil.';

  @override
  String get tutorialNavBar2 => 'Si vous maintenez l\'espace entre les boutons, vous pouvez changer l\'ordre des boutons.';

  @override
  String get tutorialHomeExtra => 'Sur cet écran, vous pouvez voir les films qui viennent de sortir. En appuyant op un film, vous verrez plus d\'informations sur ce film.';

  @override
  String get tutorialMainNavigation => 'Navigation principale';

  @override
  String get tutorialMainNavigationDesc => 'Explication de la barre et de l\'écran de démarrage';

  @override
  String get tutorialHomeScreen => 'Écran d\'accueil';

  @override
  String get tutorialHomeScreenDesc => 'Explication de l\'écran principal';

  @override
  String get tutorialResetAll => 'Tout réinitialiser';

  @override
  String get tutorialWatchlistExtra => 'Dans votre Watchlist, vous pouvez supprimer des films ou les sauvegarder pour plus tard.';

  @override
  String get tutorialSearchExtra => 'Utilisez la barre de recherche pour trouver rapidement titres et acteurs.';

  @override
  String get tutorialFoodExtra => 'Trouvez des snacks et recettes adaptés à votre film.';

  @override
  String get tutorialProfileExtra => 'Gérez vos paramètres, préférences et compte dans votre profil.';

  @override
  String get tutorialMap => 'Consultez la carte pour trouver les cinémas à proximité !';

  @override
  String get tutorialPromptTitle => 'Visite guidée';

  @override
  String get tutorialPromptBody => 'Souhaitez-vous une brève présentation de l\'application ?';

  @override
  String get resetTutorial => 'Réinitialiser le tutoriel';

  @override
  String get tutorialResetExplanation => 'Choisissez d\'abord le(s) tutoriel(s) que vous souhaitez réinitialiser. Les tutoriels ne seront réinitialisés qu\'après votre sélection.';

  @override
  String get tutorialResetMessage => 'Tutoriel réinitialisé, redémarrage';

  @override
  String get map_all_cinemas_title => 'Cinémas aux Pays-Bas';

  @override
  String map_load_error(Object error) {
    return 'Erreur lors du chargement des cinémas : $error';
  }

  @override
  String get map_location_service_disabled => 'Le service de localisation est désactivé';

  @override
  String get map_location_permission_denied => 'Accès à la localisation refusé';

  @override
  String get map_location_permission_denied_forever => 'Permissions de localisation refusées de façon permanente. Activez-les dans les paramètres.';

  @override
  String map_location_fetch_error(Object error) {
    return 'Impossible de récupérer la position : $error';
  }

  @override
  String get map_no_website_content => 'Aucun site disponible, Cinéma trouvé ! 🎥';

  @override
  String get unknown => 'Inconnu';

  @override
  String get food_edit_favorite => 'Modifier le favori';

  @override
  String get food_name_label => 'Nom';

  @override
  String get food_only_emoji => 'Emoji uniquement';

  @override
  String get food_location => 'Localisation';

  @override
  String get food_diet => 'Régime alimentaire';

  @override
  String get food_diet_info => 'Note : L\'offre de restaurants avec des options spécifiques peut varier selon la région.';

  @override
  String get food_hold_to_edit => 'Maintenez une icône pour la modifier';

  @override
  String get food_quick_pizza => 'Pizza';

  @override
  String get food_quick_sushi => 'Sushi';

  @override
  String get food_quick_burger => 'Burger';

  @override
  String get food_quick_kapsalon => 'Kapsalon';

  @override
  String get food_search_hint => 'Chercher quelque chose...';

  @override
  String get food_search_button => 'CHERCHER SUR THUISBEZORGD';

  @override
  String get food_postcode_label => 'Code postal (4 chiffres)';

  @override
  String get food_zip_required => 'Veuillez d\'abord entrer les 4 chiffres de votre code postal !';

  @override
  String get filter_vegetarian => 'Végétarien';

  @override
  String get filter_vegan => 'Végan';

  @override
  String get filter_gluten_free => 'Sans gluten';

  @override
  String get filter_halal => 'Halal';

  @override
  String get food_what_do_you_want => 'Que voulez-vous manger ?';

  @override
  String get tutorialSkip => 'Passer';

  @override
  String get ellipsis => '...';

  @override
  String get open => 'Ouvrir';

  @override
  String get changeNameTitle => 'Modifier votre nom';

  @override
  String get updateFailed => 'Échec de la mise à jour';

  @override
  String get enter_name_description => 'Nous utilisons votre nom pour personnaliser l\'application, par exemple pour les salutations.';

  @override
  String get save_and_continue => 'Enregistrer et continuer';

  @override
  String get contact_admin_title => 'Contacter l\'admin';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get contactNameLabel => 'Nom';

  @override
  String get contactQuestionLabel => 'Question';

  @override
  String get question_validation => 'Veuillez entrer votre question';

  @override
  String get mustBeLoggedInToSend => 'Vous devez être connecté pour envoyer';

  @override
  String get question_sent => 'Question envoyée';

  @override
  String get ai_max_reached => 'Vous avez atteint le nombre maximum de questions IA pour aujourd\'hui. Réessayez demain.';

  @override
  String get ask_ai_title => 'Demander à l\'IA';

  @override
  String get ai_wait => 'Un instant, cela peut prendre jusqu\'à une minute';

  @override
  String get ai_answer_title => 'Réponse de l\'IA';

  @override
  String ai_answer_title_with_model(Object model) {
    return 'Réponse de l\'IA ($model)';
  }

  @override
  String get ai_failed_all => 'La requête IA a échoué pour tous les modèles.';

  @override
  String get ai_failed => 'La requête IA a échoué.';

  @override
  String get login_required_title => 'Connexion requise';

  @override
  String get login_required_message => 'Vous devez être connecté pour faire cela. Voulez-vous aller à l\'écran de connexion ?';

  @override
  String get goto_login => 'Se connecter';

  @override
  String get search_faqs_hint => 'Rechercher dans les FAQ';

  @override
  String get no_faq_matches => 'Aucune FAQ correspondante';

  @override
  String ai_questions_used(Object max, Object used) {
    return 'Questions IA : $used/$max utilisées';
  }

  @override
  String ask_ai_with_cooldown(Object seconds) {
    return 'Demander à l\'IA (${seconds}s)';
  }

  @override
  String get contact_admin_button => 'Contacter l\'admin';

  @override
  String get my_questions => 'Mes questions';

  @override
  String get no_questions_sent => 'Vous n\'avez pas encore envoyé de questions.';

  @override
  String get message_sent => 'Message envoyé';

  @override
  String get followup_title => 'Répondre à votre question';

  @override
  String get enter_message_hint => 'Tapez un message...';

  @override
  String get faq_default_account_q => 'Comment créer un compte ?';

  @override
  String get faq_default_account_a => 'Vous pouvez vous inscrire via l\'icône de profil en haut à droite. Suivez les étapes pour créer un nouveau compte.';

  @override
  String get faq_default_watchlist_q => 'Comment ajouter un film à ma watchlist ?';

  @override
  String get faq_default_watchlist_a => 'Ouvrez la page du film et cliquez sur le bouton \'Enregistrer\' (icône signet).';

  @override
  String get faq_missing_info_q => 'Pourquoi manque-t-il des infos sur un épisode ?';

  @override
  String get faq_missing_info_a => 'Nos données proviennent de fournisseurs externes ; il manque parfois des métadonnées. Réessayez plus tard.';

  @override
  String get faq_report_bug_q => 'Comment signaler un bug ?';

  @override
  String get faq_report_bug_a => 'Utilisez le bouton \'Contacter l\'admin\' ci-dessous pour envoyer un e-mail avec une description.';

  @override
  String get faq_ai_q => 'Puis-je poser des questions à une IA ?';

  @override
  String get faq_ai_a => 'Oui, utilisez le bouton \'Demander à l\'IA\'. Les réponses sont générées automatiquement.';

  @override
  String get admins_no_push => 'Les admins pourraient ne pas recevoir de notifications push';

  @override
  String ai_cooldown_wait(Object seconds) {
    return 'Veuillez patienter $seconds secondes avant de réutiliser l\'IA.';
  }

  @override
  String get ai_input_hint => 'Posez votre question sur les films ou séries ici...';

  @override
  String get user_new_message_title => 'Nouveau message d\'un utilisateur';

  @override
  String get nowPlayingTitle => 'Films à l\'affiche';

  @override
  String get imdbIdUnavailable => 'ID IMDb non disponible pour ce film';

  @override
  String get cannot_load_now_playing => 'Impossible de charger les films à l\'affiche.';

  @override
  String get retry => 'Réessayer';

  @override
  String get no_films_found => 'Aucun film trouvé';

  @override
  String get loginWelcome => 'Bienvenue sur CineTrackr';

  @override
  String get loginCreateAccount => 'Créer un compte';

  @override
  String get loginName => 'Nom';

  @override
  String get loginNameRequired => 'Veuillez entrer votre nom';

  @override
  String get loginEmail => 'E-mail';

  @override
  String get loginEmailRequired => 'Veuillez entrer votre e-mail';

  @override
  String get loginInvalidEmail => 'E-mail invalide';

  @override
  String get loginPassword => 'Mot de passe';

  @override
  String get loginPasswordRequired => 'Veuillez entrer votre mot de passe';

  @override
  String get loginPasswordTooShort => 'Le mot de passe doit faire au moins 6 caractères';

  @override
  String get loginRegister => 'S\'inscrire';

  @override
  String get loginNoAccountRegister => 'Pas encore de compte ? S\'inscrire';

  @override
  String get loginHaveAccountLogin => 'Déjà un compte ? Se connecter';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginContinueAsGuest => 'Continuer en tant qu\'invité';

  @override
  String get loginOrDivider => 'OU';

  @override
  String get loginSignInWithGoogle => 'Se connecter avec Google';

  @override
  String get loginSignInWithGitHub => 'Se connecter avec GitHub';

  @override
  String get loginSignInWithApple => 'Se connecter avec Apple';

  @override
  String get loginEnterValidEmail => 'Entrez un e-mail valide';

  @override
  String get loginPasswordResetEmailSent => 'E-mail de réinitialisation envoyé';

  @override
  String get loginPasswordResetFailed => 'Échec de l\'envoi de l\'e-mail de réinitialisation';

  @override
  String get loginSomethingWentWrong => 'Une erreur est survenue';

  @override
  String get authenticationFailed => 'Échec de l\'authentification';

  @override
  String get loginGithubFailed => 'Échec de la connexion GitHub';

  @override
  String get googleIdTokenError => 'Erreur lors de la récupération du token ID Google';

  @override
  String get googleSignInCancelled => 'Connexion Google annulée';

  @override
  String get loginErrorCredentialMalformed => 'L\'identifiant fourni est malformé ou a expiré.';

  @override
  String get loginErrorUserDisabled => 'Ce compte utilisateur a été désactivé.';

  @override
  String get loginErrorTooManyRequests => 'Nous avons bloqué toutes les demandes de cet appareil en raison d\'une activité inhabituelle. Réessayez plus tard.';

  @override
  String get loginErrorInvalidEmail => 'L\'adresse e-mail est mal formatée.';

  @override
  String get loginErrorWrongPassword => 'Mot de passe incorrect.';

  @override
  String get loginErrorUserNotFound => 'Aucun utilisateur trouvé avec cet e-mail.';

  @override
  String get loginErrorAccountExists => 'Un compte existe déjà avec la même adresse e-mail mais des identifiants de connexion différents.';

  @override
  String get details => 'Détails';

  @override
  String get translate => 'Traduire';

  @override
  String get seen => 'Vu';

  @override
  String age_rating(Object rated) {
    return 'Classification : $rated';
  }

  @override
  String get producers_creators => 'Producteurs / Créateurs';

  @override
  String get actors => 'Acteurs';

  @override
  String seasons(Object count) {
    return 'Saisons : $count';
  }

  @override
  String episodes(Object count) {
    return 'Épisodes : $count';
  }

  @override
  String get streaming => 'Streaming';

  @override
  String seasons_episodes_title(Object count) {
    return 'Saisons & Épisodes ($count)';
  }

  @override
  String get no_seasons_found => 'Aucune saison trouvée';

  @override
  String get no_episodes_found => 'Aucun épisode trouvé';

  @override
  String get warning_title => '!! Attention !!';

  @override
  String get warning_bioscoop_content => 'Fermez les éventuelles publicités ou fenêtres contextuelles avant de consulter l\'agenda.';

  @override
  String get continue_label => 'Continuer';

  @override
  String get mark_previous_episodes_title => 'Marquer les épisodes précédents ?';

  @override
  String mark_previous_episodes_message(Object count, Object season, Object title) {
    return 'Vous marquez \'$title\' comme vu. Voulez-vous aussi marquer les $count épisode(s) précédent(s) de la saison $season ?';
  }

  @override
  String episodes_marked_seen(Object count) {
    return '$count épisodes marqués comme vus';
  }

  @override
  String get watchlist_update_failed => 'Échec de la mise à jour de la watchlist.';

  @override
  String get episode_status_update_failed => 'Échec de la mise à jour du statut de l\'épisode.';

  @override
  String get movie_seen_update_failed => 'Échec de la mise à jour du statut \'Vu\'.';

  @override
  String get included_with_subscription => 'Inclus';

  @override
  String get buy => 'Acheter';

  @override
  String buy_with_price(Object price) {
    return 'Acheter • $price';
  }

  @override
  String get rent => 'Louer';

  @override
  String rent_with_price(Object price) {
    return 'Louer • $price';
  }

  @override
  String get addon => 'Extension';

  @override
  String addon_with_price(Object price) {
    return 'Extension • $price';
  }

  @override
  String get details_streaming_warning => 'Cliquez pour ouvrir le lien de streaming';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get stars => 'étoiles';

  @override
  String get appleSignInNoIdentityToken => 'Échec Apple : aucun token d\'identité reçu';

  @override
  String get googleSignInFailed => 'La connexion Google a échoué';

  @override
  String get loginErrorWeakPassword => 'Le mot de passe est trop faible.';

  @override
  String get loginErrorNetworkFailed => 'Erreur réseau. Vérifiez votre connexion.';

  @override
  String get loginErrorRequiresRecentLogin => 'Veuillez vous reconnecter pour continuer (authentification récente requise).';

  @override
  String get avatar_login_prompt => 'Connectez-vous pour modifier votre photo';

  @override
  String get invalid_input => 'Entrée invalide';

  @override
  String get only_emoji_error => 'Entrez uniquement des emojis';

  @override
  String get use => 'Utiliser';

  @override
  String get emoji_input_hint => 'Collez ou tapez un emoji (optionnel)';

  @override
  String get edit_avatar_title => 'Modifier l\'image de profil';

  @override
  String get choose_color => 'Choisir une couleur';

  @override
  String get choose_emoji_optional => 'Choisir un emoji (optionnel)';

  @override
  String get your_badges => 'VOS BADGES';

  @override
  String get account_section => 'COMPTE';

  @override
  String get edit_profile => 'Modifier le profil';

  @override
  String get films => 'Films';

  @override
  String get badge_level_prefix => 'Nv';

  @override
  String get badge_adventurer => 'Aventurier';

  @override
  String get badge_horror_king => 'Roi de l\'Horreur';

  @override
  String get badge_binge_watcher => 'Binge Watcher';

  @override
  String get badge_early_bird => 'Lève-tôt';

  @override
  String get appVersion => 'CineTrackr v1.0.4';

  @override
  String get search_hint => 'Chercher série/film...';

  @override
  String get clear_tooltip => 'Effacer';

  @override
  String get filter_tooltip => 'Filtrer';

  @override
  String get filter_refine_title => 'Affiner les filtres';

  @override
  String get filter_type_label => 'TYPE';

  @override
  String get filter_all => 'Tout';

  @override
  String get filter_movies => 'Films';

  @override
  String get filter_series => 'Séries';

  @override
  String get filter_keyword_label => 'MOT-CLÉ';

  @override
  String get filter_keyword_hint => 'Ex: Batman, Marvel...';

  @override
  String get filter_genres_label => 'GENRES';

  @override
  String get filter_year_from_label => 'ANNÉE (DE)';

  @override
  String get filter_year_to_label => 'ANNÉE (À)';

  @override
  String get filter_min_rating_label => 'NOTE MINIMALE (0-100)';

  @override
  String get apply_filters => 'Appliquer les filtres';

  @override
  String get tmdb_movie_fetch_failed => 'Impossible de récupérer les détails du film';

  @override
  String get no_imdb_for_movie => 'Aucun ID IMDb trouvé';

  @override
  String get tmdb_movie_fetch_error => 'Erreur lors de la récupération des détails';

  @override
  String get tmdb_series_fetch_failed => 'Impossible de récupérer les détails de la série';

  @override
  String get no_imdb_for_series => 'Aucun ID IMDb trouvé';

  @override
  String get tmdb_series_fetch_error => 'Erreur lors de la récupération des détails';

  @override
  String get load_more_results => 'Charger plus de résultats';

  @override
  String get best_rated => 'Les mieux notés';

  @override
  String get popular => 'Populaires';

  @override
  String get genre_action => 'Action';

  @override
  String get genre_adventure => 'Aventure';

  @override
  String get genre_animation => 'Animation';

  @override
  String get genre_comedy => 'Comédie';

  @override
  String get genre_crime => 'Crime';

  @override
  String get genre_documentary => 'Documentaire';

  @override
  String get genre_drama => 'Drame';

  @override
  String get genre_family => 'Famille';

  @override
  String get genre_fantasy => 'Fantastique';

  @override
  String get genre_history => 'Histoire';

  @override
  String get genre_horror => 'Horreur';

  @override
  String get genre_music => 'Musique';

  @override
  String get genre_mystery => 'Mystère';

  @override
  String get genre_news => 'Actualités';

  @override
  String get genre_reality => 'Réalité';

  @override
  String get genre_romance => 'Romance';

  @override
  String get genre_scifi => 'Science-fiction';

  @override
  String get genre_talk => 'Talk-show';

  @override
  String get genre_thriller => 'Thriller';

  @override
  String get genre_war => 'Guerre';

  @override
  String get genre_western => 'Western';

  @override
  String get login_progress_save_snack => 'Connectez-vous pour sauvegarder votre progression';

  @override
  String get progress_update_failed => 'Échec de la mise à jour de la progression';

  @override
  String get open_details => 'Ouvrir les détails';

  @override
  String get label_series => 'Séries';

  @override
  String seen_count(Object count) {
    return 'Vu : $count';
  }

  @override
  String get remove_from_watchlist_tooltip => 'Retirer de la watchlist';

  @override
  String get login_manage_watchlist_snack => 'Connectez-vous pour gérer votre watchlist';

  @override
  String get item_removed_watchlist => 'Élément retiré de la watchlist';

  @override
  String get remove_item_failed => 'Impossible de retirer l\'élément';

  @override
  String get remove_from_watchlist_title => 'Retirer de la watchlist';

  @override
  String get remove_from_watchlist_confirm => 'Voulez-vous vraiment retirer cet élément ?';

  @override
  String get tab_saved => 'Enregistrés';

  @override
  String get tab_watching => 'En cours';

  @override
  String get watchlist_not_logged_in => 'Vous n\'êtes pas encore connecté.';

  @override
  String get watchlist_login_tap_message => 'Appuyez ici pour vous connecter et voir votre watchlist.';

  @override
  String error_loading(Object error) {
    return 'Erreur de chargement : $error';
  }

  @override
  String get no_items => 'Aucun élément';

  @override
  String season_label(Object number) {
    return 'Saison $number';
  }

  @override
  String season_short(Object num) {
    return 'S$num';
  }

  @override
  String seen_x_of_y(Object seen, Object total) {
    return '$seen/$total vus';
  }

  @override
  String title_wait(Object title) {
    return '$title : un instant...';
  }

  @override
  String get no_progress_for_films => 'Aucune progression pour les films';

  @override
  String get episode => 'Épisode';

  @override
  String seen_episodes_label(Object count) {
    return 'Épisodes vus : $count';
  }

  @override
  String get disclaimerTitle => 'Mentions légales';

  @override
  String get disclaimerHeading => 'Services tiers et sources de données';

  @override
  String get disclaimerText => 'Cette application utilise des données provenant de plusieurs sources tierces :\n\n* API par Brian Fritz (OMDb API)\n Sous licence CC BY-NC 4.0\n Ce service n’est ni approuvé ni affilié à IMDb.com\n\n* Cette application utilise TMDB et les API TMDB mais n’est pas approuvée, certifiée ou autrement validée par TMDB\n\n* Certaines données proviennent d’IMDb\n\n* La disponibilité en streaming et les services de traduction sont fournis via RapidAPI\n\n* Les bandes-annonces sont fournies par YouTube\n\nDonnées cartographiques © contributeurs OpenStreetMap\n\nToutes les marques, logos et droits d’auteur appartiennent à leurs propriétaires respectifs.';

  @override
  String get playbackDisabledByVideoOwner => 'Lecture désactivée par le propriétaire de la vidéo.';

  @override
  String get disclaimerNote => 'Toutes les marques, logos et données de tiers restent la propriété de leurs détenteurs respectifs ; veuillez consulter leurs conditions d\'utilisation et leurs politiques de confidentialité pour plus d\'informations.';

  @override
  String get add_series_button => 'Ajouter une série';

  @override
  String get add_series_title => 'Ajouter une série';

  @override
  String get add_series_use_dates => 'Utiliser des jours récurrents';

  @override
  String get add_series_until_date => 'Jusqu\'au';

  @override
  String get until_label => 'Jusqu\'au';

  @override
  String get select => 'Sélectionner';

  @override
  String get imdb_id_label => 'ID (ex. tt1234567)';

  @override
  String get title_label => 'Titre';

  @override
  String get number_of_seasons => 'Nombre de saisons';

  @override
  String get number_of_episodes => 'Nombre d\'épisodes';

  @override
  String episodes_in_season(Object season) {
    return 'Épisodes de la saison $season';
  }

  @override
  String get episodes_per_season_hint => 'Épisodes par saison (séparés par des virgules, ex. 10,8,12)';

  @override
  String get invalid_series_input => 'Entrée invalide';

  @override
  String get series_added => 'Série ajoutée';

  @override
  String get add_series_failed => 'Échec de l\'ajout de la série';

  @override
  String set_as_start_screen(Object label) {
    return '$label défini comme écran de démarrage';
  }

  @override
  String get save_failed => 'Échec de l\'enregistrement';

  @override
  String get label_biosagenda => 'Biosagenda';

  @override
  String get label_kinepolis => 'Kinepolis';

  @override
  String get tutorialSearchField => 'Tapez le nom d\'un film ou d\'une série ici pour rechercher.';

  @override
  String get tutorialSearchFilter => 'Utilisez ce bouton pour filtrer par genre, année ou note.';

  @override
  String get tutorialSearchTabs => 'Basculez ici entre les titres les mieux notés et populaires.';

  @override
  String get tutorialSearchScreenMain => 'Écran de recherche';

  @override
  String get tutorialSearchScreenDesc => 'Explication de l\'écran de recherche';

  @override
  String get tutorialFoodZip => 'Entrez votre code postal ici pour trouver de la nourriture plus rapidement dans votre région.';

  @override
  String get tutorialFoodDiet => 'Indiquez vos besoins alimentaires ici, afin que nous puissions filtrer la nourriture.';

  @override
  String get tutorialFoodQuick => 'Appuyez ici rapidement pour commander ! Maintenez un favori enfoncé pour le modifier.';

  @override
  String get tutorialFoodSearch => 'Recherchez manuellement ce dont vous avez envie et appuyez sur rechercher.';

  @override
  String get tutorialFoodScreenMain => 'Écran de nourriture';

  @override
  String get tutorialFoodScreenDesc => 'Explication de l\'écran de nourriture';

  @override
  String get tutorialWatchlistTabs => 'Basculez ici entre vos films/séries enregistrés et ce que vous regardez actuellement.';

  @override
  String get tutorialWatchlistLogin => 'Connectez-vous ou créez un compte ici pour enregistrer vos films et séries.';

  @override
  String get tutorialWatchlistContent => 'Gérez tout ce que vous avez enregistré ou reprenez la lecture là où vous vous étiez arrêté.';

  @override
  String get tutorialWatchlistScreenMain => 'Ma liste';

  @override
  String get tutorialWatchlistScreenDesc => 'Explication de la liste de suivi et des films enregistrés';

  @override
  String get tutorialProfileAvatar => 'Appuyez ici pour changer votre avatar et nom d\'affichage.';

  @override
  String get tutorialProfileStats => 'Voyez en un coup d\'œil combien de films vous avez regardés et enregistrés.';

  @override
  String get tutorialProfileBadges => 'Gagnez des badges en utilisant l\'application. Appuyez dessus pour voir les détails !';

  @override
  String get tutorialProfileSettings => 'Vous trouverez ici tous les paramètres de l\'application, comme les notifications ou le thème.';

  @override
  String get tutorialProfileScreenMain => 'Écran de profil';

  @override
  String get tutorialProfileScreenDesc => 'Explication de l\'écran de profil';

  @override
  String get badge_adventurer_desc => 'Ajoutez 10 films ou séries d\'aventure pour augmenter ce niveau.';

  @override
  String get badge_horror_desc => 'Ajoutez 5 films d\'horreur ou à suspense à votre liste pour augmenter ce niveau.';

  @override
  String get badge_binge_desc => 'Ajoutez 2 éléments ou plus en moins de 10 minutes. Faites cela 3 fois pour augmenter ce niveau.';

  @override
  String get badge_early_desc => 'Ajoutez 5 éléments entre 00h00 et 06h00 de la nuit pour augmenter ce niveau.';

  @override
  String get badge_dialog_close => 'Fermer';

  @override
  String get tutorialMovieDetailInfo => 'Ici, vous voyez les informations les plus importantes sur le film ou la série, y compris la description (que vous pouvez traduire).';

  @override
  String get tutorialMovieDetailWatchlist => 'Ajoutez ce titre à votre liste de suivi avec l\'icône de sauvegarde ou marquez facilement le film comme vu !';

  @override
  String get tutorialMovieDetailStreaming => 'Regardez si ce titre est disponible dans vos abonnements ou où vous pouvez le louer/l\'acheter.';

  @override
  String get tutorialMovieDetailSeasons => 'Comme ce titre est une série, vous trouverez toutes les informations sur les saisons et les épisodes individuels pour suivre vos progrès.';

  @override
  String get tutorialMovieDetailMain => 'Écran Détails du Film';

  @override
  String get tutorialMovieDetailDesc => 'Explication des informations, du suivi et des options de streaming sur la page des détails du film';

  @override
  String get tutorialMovieDetailResetToast => 'Naviguez vers n\'importe quel film ou série pour voir le tutoriel !';
}
