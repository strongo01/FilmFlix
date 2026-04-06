// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get myDashboard => 'Mi Panel';

  @override
  String get preferences => 'Preferencias';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notifications_enabled => 'Notificaciones activadas';

  @override
  String get notifications_check_system => 'Consulta los ajustes del sistema para permitir las notificaciones.';

  @override
  String get notifications_registration_failed => 'Error al registrarse para las notificaciones.';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get dutch => 'Neerlandés';

  @override
  String get french => 'Francés';

  @override
  String get german => 'Alemán';

  @override
  String get turkish => 'Turco';

  @override
  String get spanish => 'Español';

  @override
  String get close => 'Cerrar';

  @override
  String get nameLabel => 'Tu nombre';

  @override
  String get nameValidation => 'Introduce tu nombre';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get mustBeLoggedIn => 'Debes iniciar sesión para cambiar tu nombre';

  @override
  String get profile_default_name => 'Kevin le Goat';

  @override
  String get profile_default_email => 'kevinlegoat@example.com';

  @override
  String get filmsDone => 'Películas terminadas';

  @override
  String get watchlist_label => 'Lista de seguimiento';

  @override
  String get support => 'Soporte';

  @override
  String get customerService_title => 'Atención al cliente';

  @override
  String get aboutTitle => 'Acerca de CineTrackr';

  @override
  String get aboutText => 'CineTrackr\n\nBienvenido a CineTrackr, tu guía personal para películas y visitas al cine.\n\nCon CineTrackr puedes consultar fácilmente la cartelera, mantener tu propia lista de seguimiento y acceder rápidamente a ubicaciones de cines y atención al cliente.\n\n¡Gracias por usar CineTrackr — disfruta de la función!';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get loginIn => 'Iniciar sesión';

  @override
  String get nameUpdated => 'Nombre actualizado';

  @override
  String get nameUpdateFailed => 'Error al actualizar';

  @override
  String get admin_title => 'Admin';

  @override
  String get tab_chats => 'Chats';

  @override
  String get tab_faqs => 'Preguntas frecuentes';

  @override
  String get not_logged_in_title => 'Sesión no iniciada';

  @override
  String get not_logged_in_message => 'Primero inicia sesión como administrador e inténtalo de nuevo.';

  @override
  String get no_users_doc => 'No se encontró el documento de usuario.';

  @override
  String users_doc_role(Object role, Object uid) {
    return 'users/$uid rol = $role';
  }

  @override
  String users_doc_no_role(Object uid) {
    return 'users/$uid existe, pero no tiene campo de rol.';
  }

  @override
  String users_doc_read_error(Object error) {
    return 'Error al leer el documento de usuario: $error';
  }

  @override
  String get send_failed => 'Error al enviar';

  @override
  String get check_permissions_title => 'Comprobar permisos';

  @override
  String get possible_causes => 'Posibles causas y soluciones:';

  @override
  String get firestore_rules => '- Comprobar reglas de Firestore: las reglas usan claims personalizados (request.auth.token.role).';

  @override
  String get custom_claims_hint => '- Si usas claims personalizados: establece el rol/admin mediante Admin SDK y pide al administrador que vuelva a iniciar sesión.';

  @override
  String rules_temp_change(Object uid) {
    return '- O cambia temporalmente las reglas para leer el rol desde /users/$uid.';
  }

  @override
  String get current_users_doc => 'Documento de usuario actual:';

  @override
  String get debug_info_title => 'Información de depuración';

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
    return 'Error de idToken: $error';
  }

  @override
  String users_doc_label(Object doc) {
    return 'doc de usuario: $doc';
  }

  @override
  String get ok => 'OK';

  @override
  String get fetch_doc_title => 'Obtener documento por ID';

  @override
  String get paste_doc_id => 'Pega aquí el ID del documento de customerquestions:';

  @override
  String get fetch => 'Obtener';

  @override
  String get not_found_title => 'No encontrado';

  @override
  String document_not_found(Object id) {
    return 'El documento $id no existe o no se puede leer.';
  }

  @override
  String document_title(Object id) {
    return 'Documento $id';
  }

  @override
  String get empty => '<vacío>';

  @override
  String get fetch_error_title => 'Error';

  @override
  String fetch_error_message(Object error) {
    return 'Error al obtener: $error';
  }

  @override
  String cannot_load_chats(Object error) {
    return 'No se pueden cargar los chats: $error';
  }

  @override
  String get no_questions_found => 'No se encontraron preguntas';

  @override
  String get show_debug_info => 'Mostrar info de depuración';

  @override
  String get delete_chat_title => 'Eliminar chat';

  @override
  String get delete_chat_confirm => '¿Estás seguro de que quieres eliminar este chat? Esta acción no se puede deshacer.';

  @override
  String get delete => 'Eliminar';

  @override
  String get chat_deleted => 'Chat eliminado';

  @override
  String get delete_failed => 'Error al eliminar';

  @override
  String get marked_unread => 'Marcado como no leído';

  @override
  String get action_failed => 'Acción fallida';

  @override
  String get user_label_default => 'Usuario';

  @override
  String get reply_hint => 'Escribe una respuesta...';

  @override
  String get send => 'Enviar';

  @override
  String get notify_title => 'Nuevo mensaje del administrador';

  @override
  String notify_body(Object text) {
    return '$text';
  }

  @override
  String get no_faq_items => 'Aún no hay elementos en preguntas frecuentes';

  @override
  String get edit => 'Editar';

  @override
  String get remove => 'Eliminar';

  @override
  String get add_new_faq => 'Añadir nueva pregunta frecuente';

  @override
  String get new_faq_title => 'Nueva pregunta frecuente';

  @override
  String get question_label => 'Pregunta/Comentario';

  @override
  String get answer_label => 'Respuesta';

  @override
  String get add => 'Añadir';

  @override
  String get faq_added => 'Pregunta añadida';

  @override
  String get faq_add_failed => 'Error al añadir';

  @override
  String get edit_faq_title => 'Editar pregunta frecuente';

  @override
  String get faq_updated => 'Pregunta actualizada';

  @override
  String get faq_update_failed => 'Error al guardar';

  @override
  String get delete_faq_title => 'Eliminar pregunta frecuente';

  @override
  String get delete_faq_confirm => '¿Estás seguro de que quieres eliminar esta pregunta frecuente?';

  @override
  String get faq_deleted => 'Pregunta eliminada';

  @override
  String get faq_delete_failed => 'Error al eliminar';

  @override
  String admins_label(Object names) {
    return 'Administradores: $names';
  }

  @override
  String chat_page_title_prefix(Object prefix) {
    return 'Chat: $prefix';
  }

  @override
  String get appTitle => 'CineTrackr';

  @override
  String get navHome => 'Inicio';

  @override
  String get navWatchlist => 'Lista';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navFood => 'Comida';

  @override
  String get navigationReorder => 'Reordenar navegación';

  @override
  String get navProfile => 'Perfil';

  @override
  String get infoTooltip => 'Info';

  @override
  String get watchlistInfoTitle => 'Info';

  @override
  String get watchlistInfoContent => 'La aplicación no puede obtener datos de los servicios de streaming. Puedes marcar manualmente los episodios que has visto.';

  @override
  String get tutorialHome => '¡Bienvenido! Aquí encontrarás las últimas películas y series.';

  @override
  String get tutorialWatchlist => 'Guarda aquí tus películas favoritas para verlas más tarde.';

  @override
  String get tutorialSearch => 'Busca títulos o géneros específicos.';

  @override
  String get tutorialFood => '¡Echa un vistazo a los aperitivos para tu noche de cine!';

  @override
  String get tutorialProfile => 'Gestiona aquí tu perfil y ajustes.';

  @override
  String get tutorialNavBar => 'Aquí puedes cambiar de pantalla. Mantén pulsado un botón para reordenar las páginas.';

  @override
  String get tutorialHomeExtra => 'En la pantalla de inicio ves los últimos estrenos y recomendaciones.';

  @override
  String get tutorialWatchlistExtra => 'En tu Watchlist puedes eliminar películas o guardarlas para ver más tarde.';

  @override
  String get tutorialSearchExtra => 'Usa la barra de búsqueda para encontrar títulos y actores rápidamente.';

  @override
  String get tutorialFoodExtra => 'Encuentra snacks y recetas que encajen con tu película.';

  @override
  String get tutorialProfileExtra => 'Gestiona ajustes, preferencias y datos de cuenta en tu perfil.';

  @override
  String get tutorialMap => '¡Aquí puedes ver el mapa para encontrar cines cercanos!';

  @override
  String get map_all_cinemas_title => 'Cines en los Países Bajos';

  @override
  String map_load_error(Object error) {
    return 'Error al cargar los cines: $error';
  }

  @override
  String get map_location_service_disabled => 'El servicio de ubicación está desactivado';

  @override
  String get map_location_permission_denied => 'Acceso a la ubicación denegado';

  @override
  String get map_location_permission_denied_forever => 'Permisos de ubicación denegados permanentemente. Actívalos en ajustes.';

  @override
  String map_location_fetch_error(Object error) {
    return 'No se pudo obtener la ubicación: $error';
  }

  @override
  String get map_no_website_content => 'Sitio web no disponible — ¡Cine encontrado! 🎥';

  @override
  String get unknown => 'Desconocido';

  @override
  String get food_edit_favorite => 'Editar favorito';

  @override
  String get food_name_label => 'Nombre';

  @override
  String get food_only_emoji => 'Solo Emoji';

  @override
  String get food_location => 'Ubicación';

  @override
  String get food_diet => 'Preferencia de dieta';

  @override
  String get food_diet_info => 'Nota: La oferta de restaurantes con opciones dietéticas específicas puede variar según la región.';

  @override
  String get food_hold_to_edit => 'Mantén presionado un icono para editarlo';

  @override
  String get food_quick_pizza => 'Pizza';

  @override
  String get food_quick_sushi => 'Sushi';

  @override
  String get food_quick_burger => 'Hamburguesa';

  @override
  String get food_quick_kapsalon => 'Kapsalon';

  @override
  String get food_search_hint => 'Buscar algo...';

  @override
  String get food_search_button => 'BUSCAR EN THUISBEZORGD';

  @override
  String get food_postcode_label => 'Código postal (4 dígitos)';

  @override
  String get food_zip_required => '¡Introduce primero los 4 dígitos de tu código postal!';

  @override
  String get filter_vegetarian => 'Vegetariano';

  @override
  String get filter_vegan => 'Vegano';

  @override
  String get filter_gluten_free => 'Sin gluten';

  @override
  String get filter_halal => 'Halal';

  @override
  String get food_what_do_you_want => '¿Qué quieres comer?';

  @override
  String get tutorialSkip => 'Omitir';

  @override
  String get ellipsis => '...';

  @override
  String get open => 'Abrir';

  @override
  String get changeNameTitle => 'Cambia tu nombre';

  @override
  String get updateFailed => 'Error al actualizar';

  @override
  String get enter_name_description => 'Usamos tu nombre para personalizar la aplicación, por ejemplo, para los saludos.';

  @override
  String get save_and_continue => 'Guardar y continuar';

  @override
  String get contact_admin_title => 'Contactar con admin';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get contactNameLabel => 'Nombre';

  @override
  String get contactQuestionLabel => 'Pregunta';

  @override
  String get question_validation => 'Escribe tu pregunta';

  @override
  String get mustBeLoggedInToSend => 'Debes iniciar sesión para enviar';

  @override
  String get question_sent => 'Pregunta enviada';

  @override
  String get ai_max_reached => 'Has alcanzado el límite máximo de preguntas de IA por hoy. Inténtalo de nuevo mañana.';

  @override
  String get ask_ai_title => 'Preguntar a la IA';

  @override
  String get ai_wait => 'Un momento, por favor, esto puede tardar hasta un minuto';

  @override
  String get ai_answer_title => 'Respuesta de la IA';

  @override
  String ai_answer_title_with_model(Object model) {
    return 'Respuesta de la IA ($model)';
  }

  @override
  String get ai_failed_all => 'La solicitud de IA falló para todos los modelos.';

  @override
  String get ai_failed => 'La solicitud de IA falló.';

  @override
  String get login_required_title => 'Inicio de sesión requerido';

  @override
  String get login_required_message => 'Debes iniciar sesión para hacer esto. ¿Quieres ir a la pantalla de login?';

  @override
  String get goto_login => 'Ir a login';

  @override
  String get search_faqs_hint => 'Buscar en preguntas frecuentes';

  @override
  String get no_faq_matches => 'No hay coincidencias en preguntas frecuentes';

  @override
  String ai_questions_used(Object max, Object used) {
    return 'Preguntas de IA: $used/$max usadas';
  }

  @override
  String ask_ai_with_cooldown(Object seconds) {
    return 'Preguntar a IA ($seconds)';
  }

  @override
  String get contact_admin_button => 'Contactar con admin';

  @override
  String get my_questions => 'Mis preguntas';

  @override
  String get no_questions_sent => 'Aún no has enviado ninguna pregunta.';

  @override
  String get message_sent => 'Mensaje enviado';

  @override
  String get followup_title => 'Responder a tu pregunta';

  @override
  String get enter_message_hint => 'Escribe un mensaje...';

  @override
  String get faq_default_account_q => '¿Cómo creo una cuenta?';

  @override
  String get faq_default_account_a => 'Puedes registrarte a través del icono de perfil en la parte superior derecha de la aplicación. Sigue los pasos para crear una nueva cuenta.';

  @override
  String get faq_default_watchlist_q => '¿Cómo añado una película a mi lista?';

  @override
  String get faq_default_watchlist_a => 'Abre la página de la película y haz clic en el botón \"Guardar\" (icono de marcador) para añadirla a tu lista.';

  @override
  String get faq_missing_info_q => '¿Por qué falta información de un episodio o temporada?';

  @override
  String get faq_missing_info_a => 'Nuestros datos provienen de proveedores externos; a veces faltan metadatos. Inténtalo de nuevo más tarde o repórtalo en Contactar con admin.';

  @override
  String get faq_report_bug_q => '¿Cómo puedo reportar un error en la aplicación?';

  @override
  String get faq_report_bug_a => 'Usa el botón \"Contactar con admin\" de abajo para enviar un correo con una descripción y capturas de pantalla.';

  @override
  String get faq_ai_q => '¿Puedo hacer preguntas a una IA?';

  @override
  String get faq_ai_a => 'Sí — usa el botón \"Preguntar a la IA\" para formular una pregunta. Ten en cuenta que las respuestas se generan automáticamente.';

  @override
  String get admins_no_push => 'Es posible que los administradores no reciban notificaciones push';

  @override
  String ai_cooldown_wait(Object seconds) {
    return 'Espera $seconds segundos antes de volver a usar la IA.';
  }

  @override
  String get ai_input_hint => 'Escribe aquí tu pregunta sobre películas o series...';

  @override
  String get user_new_message_title => 'Nuevo mensaje de usuario';

  @override
  String get nowPlayingTitle => 'Películas actuales';

  @override
  String get imdbIdUnavailable => 'ID de IMDb no disponible para esta película';

  @override
  String get cannot_load_now_playing => 'No se pudieron cargar las películas actuales.';

  @override
  String get retry => 'Reintentar';

  @override
  String get no_films_found => 'No se encontraron películas';

  @override
  String get loginWelcome => 'Bienvenido a CineTrackr';

  @override
  String get loginCreateAccount => 'Crear una cuenta';

  @override
  String get loginName => 'Nombre';

  @override
  String get loginNameRequired => 'Introduce tu nombre';

  @override
  String get loginEmail => 'E-mail';

  @override
  String get loginEmailRequired => 'Introduce tu e-mail';

  @override
  String get loginInvalidEmail => 'E-mail no válido';

  @override
  String get loginPassword => 'Contraseña';

  @override
  String get loginPasswordRequired => 'Introduce tu contraseña';

  @override
  String get loginPasswordTooShort => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get loginRegister => 'Registrarse';

  @override
  String get loginNoAccountRegister => '¿Aún no tienes cuenta? Regístrate';

  @override
  String get loginHaveAccountLogin => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get loginForgotPassword => '¿Has olvidado tu contraseña?';

  @override
  String get loginContinueAsGuest => 'Continuar como invitado';

  @override
  String get loginOrDivider => 'O';

  @override
  String get loginSignInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get loginSignInWithGitHub => 'Iniciar sesión con GitHub';

  @override
  String get loginSignInWithApple => 'Iniciar sesión con Apple';

  @override
  String get loginEnterValidEmail => 'Introduce un e-mail válido';

  @override
  String get loginPasswordResetEmailSent => 'Correo de restablecimiento de contraseña enviado';

  @override
  String get loginPasswordResetFailed => 'No se pudo enviar el correo de restablecimiento';

  @override
  String get loginSomethingWentWrong => 'Algo ha salido mal';

  @override
  String get authenticationFailed => 'Error de autenticación';

  @override
  String get loginGithubFailed => 'Error al iniciar sesión con GitHub';

  @override
  String get googleIdTokenError => 'Error al obtener el token de ID de Google';

  @override
  String get googleSignInCancelled => 'Inicio de sesión con Google cancelado';

  @override
  String get loginErrorCredentialMalformed => 'La credencial suministrada no es válida o ha caducado.';

  @override
  String get loginErrorUserDisabled => 'Esta cuenta de usuario ha sido inhabilitada.';

  @override
  String get loginErrorTooManyRequests => 'Hemos bloqueado todas las solicitudes de este dispositivo debido a una actividad inusual. Inténtalo de nuevo más tarde.';

  @override
  String get loginErrorInvalidEmail => 'La dirección de correo electrónico no es válida.';

  @override
  String get loginErrorWrongPassword => 'Contraseña incorrecta.';

  @override
  String get loginErrorUserNotFound => 'No se encontró ningún usuario con este correo electrónico.';

  @override
  String get loginErrorAccountExists => 'Ya existe una cuenta con la misma dirección de correo electrónico pero con diferentes credenciales de inicio de sesión.';

  @override
  String get details => 'Detalles';

  @override
  String get translate => 'Traducir';

  @override
  String get seen => 'Visto';

  @override
  String age_rating(Object rated) {
    return 'Clasificación por edad: $rated';
  }

  @override
  String get producers_creators => 'Productores / Creadores';

  @override
  String get actors => 'Actores';

  @override
  String seasons(Object count) {
    return 'Temporadas: $count';
  }

  @override
  String episodes(Object count) {
    return 'Episodios: $count';
  }

  @override
  String get streaming => 'Streaming';

  @override
  String seasons_episodes_title(Object count) {
    return 'Temporadas y Episodios ($count)';
  }

  @override
  String get no_seasons_found => 'No se encontraron temporadas';

  @override
  String get no_episodes_found => 'No se encontraron episodios';

  @override
  String get warning_title => '!!Advertencia!!';

  @override
  String get warning_bioscoop_content => 'Primero cierra cualquier publicidad o ventana emergente en el sitio web antes de consultar la cartelera.';

  @override
  String get continue_label => 'Continuar';

  @override
  String get mark_previous_episodes_title => '¿Marcar episodios anteriores?';

  @override
  String mark_previous_episodes_message(Object count, Object season, Object title) {
    return 'Estás marcando \"$title\" como visto. ¿Quieres marcar también $count episodio(s) anteriores de la temporada $season como vistos?';
  }

  @override
  String episodes_marked_seen(Object count) {
    return '$count episodios marcados como vistos';
  }

  @override
  String get watchlist_update_failed => 'No se pudo actualizar la lista.';

  @override
  String get episode_status_update_failed => 'No se pudo actualizar el estado del episodio.';

  @override
  String get movie_seen_update_failed => 'No se pudo actualizar el estado \"Visto\".';

  @override
  String get included_with_subscription => 'Incluido';

  @override
  String get buy => 'Comprar';

  @override
  String buy_with_price(Object price) {
    return 'Comprar • $price';
  }

  @override
  String get rent => 'Alquilar';

  @override
  String rent_with_price(Object price) {
    return 'Alquilar • $price';
  }

  @override
  String get addon => 'Complemento';

  @override
  String addon_with_price(Object price) {
    return 'Complemento • $price';
  }

  @override
  String get details_streaming_warning => 'Haz clic para abrir el enlace de streaming';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get stars => 'estrellas';

  @override
  String get appleSignInNoIdentityToken => 'Fallo al iniciar sesión con Apple: no se recibió token de identidad';

  @override
  String get googleSignInFailed => 'Error al iniciar sesión con Google';

  @override
  String get loginErrorWeakPassword => 'La contraseña es demasiado débil.';

  @override
  String get loginErrorNetworkFailed => 'Error de red. Por favor verifica tu conexión.';

  @override
  String get loginErrorRequiresRecentLogin => 'Vuelve a iniciar sesión para continuar (se requiere autenticación reciente).';

  @override
  String get avatar_login_prompt => 'Inicia sesión para personalizar tu foto de perfil';

  @override
  String get invalid_input => 'Entrada no válida';

  @override
  String get only_emoji_error => 'Introduce solo emojis';

  @override
  String get use => 'Usar';

  @override
  String get emoji_input_hint => 'Pega o escribe un emoji (opcional)';

  @override
  String get edit_avatar_title => 'Editar imagen de perfil';

  @override
  String get choose_color => 'Elegir color';

  @override
  String get choose_emoji_optional => 'Elegir emoji (opcional)';

  @override
  String get your_badges => 'TUS INSIGNIAS';

  @override
  String get account_section => 'CUENTA';

  @override
  String get edit_profile => 'Editar perfil';

  @override
  String get films => 'Películas';

  @override
  String get badge_level_prefix => 'Nv';

  @override
  String get badge_adventurer => 'Aventurero';

  @override
  String get badge_horror_king => 'Rey del Terror';

  @override
  String get badge_binge_watcher => 'Espectador compulsivo';

  @override
  String get badge_early_bird => 'Madrugador';

  @override
  String get appVersion => 'CineTrackr v1.0.4';

  @override
  String get search_hint => 'Buscar serie/película...';

  @override
  String get clear_tooltip => 'Borrar';

  @override
  String get filter_tooltip => 'Filtro';

  @override
  String get filter_refine_title => 'Refinar filtros';

  @override
  String get filter_type_label => 'TIPO';

  @override
  String get filter_all => 'Todo';

  @override
  String get filter_movies => 'Películas';

  @override
  String get filter_series => 'Series';

  @override
  String get filter_keyword_label => 'PALABRA CLAVE';

  @override
  String get filter_keyword_hint => 'Ej. Batman, Marvel...';

  @override
  String get filter_genres_label => 'GÉNEROS';

  @override
  String get filter_year_from_label => 'AÑO (DESDE)';

  @override
  String get filter_year_to_label => 'AÑO (HASTA)';

  @override
  String get filter_min_rating_label => 'CALIFICACIÓN MÍNIMA (0-100)';

  @override
  String get apply_filters => 'Aplicar filtros';

  @override
  String get tmdb_movie_fetch_failed => 'No se pudieron obtener los detalles de la película';

  @override
  String get no_imdb_for_movie => 'No se encontró ID de IMDb para esta película';

  @override
  String get tmdb_movie_fetch_error => 'Error al obtener detalles de la película';

  @override
  String get tmdb_series_fetch_failed => 'No se pudieron obtener los detalles de la serie';

  @override
  String get no_imdb_for_series => 'No se encontró ID de IMDb para esta serie';

  @override
  String get tmdb_series_fetch_error => 'Error al obtener detalles de la serie';

  @override
  String get load_more_results => 'Cargar más resultados';

  @override
  String get best_rated => 'Mejor valoradas';

  @override
  String get popular => 'Popular';

  @override
  String get genre_action => 'Acción';

  @override
  String get genre_adventure => 'Aventura';

  @override
  String get genre_animation => 'Animación';

  @override
  String get genre_comedy => 'Comedia';

  @override
  String get genre_crime => 'Crimen';

  @override
  String get genre_documentary => 'Documental';

  @override
  String get genre_drama => 'Drama';

  @override
  String get genre_family => 'Familia';

  @override
  String get genre_fantasy => 'Fantasía';

  @override
  String get genre_history => 'Historia';

  @override
  String get genre_horror => 'Terror';

  @override
  String get genre_music => 'Música';

  @override
  String get genre_mystery => 'Misterio';

  @override
  String get genre_news => 'Noticias';

  @override
  String get genre_reality => 'Reality';

  @override
  String get genre_romance => 'Romance';

  @override
  String get genre_scifi => 'Ciencia ficción';

  @override
  String get genre_talk => 'Talk Show';

  @override
  String get genre_thriller => 'Suspense';

  @override
  String get genre_war => 'Bélica';

  @override
  String get genre_western => 'Western';

  @override
  String get login_progress_save_snack => 'Inicia sesión para guardar tu progreso';

  @override
  String get progress_update_failed => 'No se pudo actualizar el progreso';

  @override
  String get open_details => 'Abrir detalles';

  @override
  String get label_series => 'Series';

  @override
  String seen_count(Object count) {
    return 'Visto: $count';
  }

  @override
  String get remove_from_watchlist_tooltip => 'Eliminar de la lista';

  @override
  String get login_manage_watchlist_snack => 'Inicia sesión para gestionar la lista';

  @override
  String get item_removed_watchlist => 'Elemento eliminado de la lista';

  @override
  String get remove_item_failed => 'No se pudo eliminar el elemento';

  @override
  String get remove_from_watchlist_title => 'Eliminar de la lista';

  @override
  String get remove_from_watchlist_confirm => '¿Estás seguro de que quieres eliminar este elemento de tu lista de seguimiento?';

  @override
  String get tab_saved => 'Guardado';

  @override
  String get tab_watching => 'Viendo ahora';

  @override
  String get watchlist_not_logged_in => 'Aún no has iniciado sesión.';

  @override
  String get watchlist_login_tap_message => 'Toca aquí para iniciar sesión y ver tu lista.';

  @override
  String error_loading(Object error) {
    return 'Error al cargar: $error';
  }

  @override
  String get no_items => 'No hay elementos';

  @override
  String season_label(Object number) {
    return 'Temporada $number';
  }

  @override
  String season_short(Object num) {
    return 'T$num';
  }

  @override
  String seen_x_of_y(Object seen, Object total) {
    return '$seen/$total vistos';
  }

  @override
  String title_wait(Object title) {
    return '$title: un momento por favor...';
  }

  @override
  String get no_progress_for_films => 'Aún no hay progreso para películas';

  @override
  String get episode => 'Episodio';

  @override
  String seen_episodes_label(Object count) {
    return 'Episodios vistos: $count';
  }

  @override
  String get disclaimerTitle => 'Aviso legal';

  @override
  String get disclaimerHeading => 'Servicios de terceros y fuentes de datos';

  @override
  String get disclaimerText => 'Esta aplicación utiliza datos de múltiples fuentes de terceros:\n\n* API por Brian Fritz (OMDb API)\n Licenciado bajo CC BY-NC 4.0\n Este servicio no está respaldado ni afiliado a IMDb.com\n\n* Esta aplicación utiliza TMDB y las API de TMDB, pero no está respaldada, certificada ni aprobada de ninguna manera por TMDB\n\n* Algunos datos provienen de IMDb\n\n* La disponibilidad de streaming y los servicios de traducción se proporcionan a través de RapidAPI\n\n* Los tráilers son proporcionados por YouTube\n\nDatos de mapas © colaboradores de OpenStreetMap\n\nTodas las marcas, logotipos y derechos de autor pertenecen a sus respectivos propietarios.';

  @override
  String get playbackDisabledByVideoOwner => 'Reproducción deshabilitada por el propietario del vídeo.';

  @override
  String get disclaimerNote => 'Todas las marcas, logotipos y datos de terceros siguen siendo propiedad de sus respectivos propietarios; consulte sus términos y políticas de privacidad para más detalles.';

  @override
  String get add_series_button => 'Agregar serie';

  @override
  String get add_series_title => 'Agregar serie';

  @override
  String get add_series_use_dates => 'Usar días recurrentes';

  @override
  String get add_series_until_date => 'Hasta la fecha';

  @override
  String get until_label => 'Hasta';

  @override
  String get select => 'Seleccionar';

  @override
  String get imdb_id_label => 'ID (p.ej. tt1234567)';

  @override
  String get title_label => 'Título';

  @override
  String get number_of_seasons => 'Número de temporadas';

  @override
  String get number_of_episodes => 'Número de episodios';

  @override
  String episodes_in_season(Object season) {
    return 'Episodios en la temporada $season';
  }

  @override
  String get episodes_per_season_hint => 'Episodios por temporada (separados por comas, p.ej. 10,8,12)';

  @override
  String get invalid_series_input => 'Entrada no válida';

  @override
  String get series_added => 'Serie agregada';

  @override
  String get add_series_failed => 'No se pudo agregar la serie';
}
