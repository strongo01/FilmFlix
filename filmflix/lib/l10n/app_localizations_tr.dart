// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get myDashboard => 'Panelim';

  @override
  String get preferences => 'Tercihler';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get notifications_enabled => 'Bildirimler etkinleştirildi';

  @override
  String get notifications_check_system => 'Bildirimlere izin vermek için lütfen sistem ayarlarını kontrol edin.';

  @override
  String get notifications_registration_failed => 'Bildirim kaydı başarısız oldu.';

  @override
  String get language => 'Dil';

  @override
  String get english => 'İngilizce';

  @override
  String get dutch => 'Hollandaca';

  @override
  String get french => 'Fransızca';

  @override
  String get german => 'Almanca';

  @override
  String get turkish => 'Türkçe';

  @override
  String get spanish => 'İspanyolca';

  @override
  String get close => 'Kapat';

  @override
  String get nameLabel => 'Adınız';

  @override
  String get nameValidation => 'Lütfen adınızı girin';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get mustBeLoggedIn => 'Adınızı değiştirmek için giriş yapmış olmalısınız';

  @override
  String get profile_default_name => 'Kevin le Goat';

  @override
  String get profile_default_email => 'kevinlegoat@example.com';

  @override
  String get filmsDone => 'İzlenen Filmler';

  @override
  String get watchlist_label => 'İzleme Listesi';

  @override
  String get support => 'Destek';

  @override
  String get customerService_title => 'Müşteri Hizmetleri';

  @override
  String get aboutTitle => 'CineTrackr Hakkında';

  @override
  String get aboutText => 'CineTrackr\n\nFilmler ve sinema ziyaretleri için kişisel rehberiniz CineTrackr\'a hoş geldiniz.\n\nCineTrackr ile film programlarını kolayca görüntüleyebilir, kendi izleme listenizi tutabilir, sinema konumlarına ve müşteri hizmetlerine hızlıca ulaşabilirsiniz.\n\nCineTrackr\'ı kullandığınız için teşekkürler, iyi seyirler!';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get loginIn => 'Giriş Yap';

  @override
  String get nameUpdated => 'İsim güncellendi';

  @override
  String get nameUpdateFailed => 'Güncelleme başarısız';

  @override
  String get admin_title => 'Admin';

  @override
  String get tab_chats => 'Sohbetler';

  @override
  String get tab_faqs => 'SSS';

  @override
  String get not_logged_in_title => 'Giriş Yapılmadı';

  @override
  String get not_logged_in_message => 'Lütfen önce admin olarak giriş yapın ve tekrar deneyin.';

  @override
  String get no_users_doc => 'Kullanıcı belgesi bulunamadı.';

  @override
  String users_doc_role(Object role, Object uid) {
    return 'users/$uid rolü = $role';
  }

  @override
  String users_doc_no_role(Object uid) {
    return 'users/$uid mevcut ancak rol alanı yok.';
  }

  @override
  String users_doc_read_error(Object error) {
    return 'Kullanıcı belgesi okunurken hata oluştu: $error';
  }

  @override
  String get send_failed => 'Gönderim başarısız';

  @override
  String get check_permissions_title => 'Yetkileri Kontrol Et';

  @override
  String get possible_causes => 'Olası nedenler ve çözümler:';

  @override
  String get firestore_rules => '- Firestore kurallarını kontrol edin: kurallar özel talepleri (request.auth.token.role) kullanır.';

  @override
  String get custom_claims_hint => '- Özel talepler kullanıyorsanız: Admin SDK üzerinden rolü/admini ayarlayın ve adminin tekrar giriş yapmasını sağlayın.';

  @override
  String rules_temp_change(Object uid) {
    return '- Veya rolü /users/$uid üzerinden okumak için kuralları geçici olarak değiştirin.';
  }

  @override
  String get current_users_doc => 'Mevcut kullanıcı belgesi:';

  @override
  String get debug_info_title => 'Hata ayıklama bilgisi';

  @override
  String uid_label(Object uid) {
    return 'uid: $uid';
  }

  @override
  String idtoken_claims_label(Object claims) {
    return 'idToken talepleri: $claims';
  }

  @override
  String idtoken_error_label(Object error) {
    return 'idToken hatası: $error';
  }

  @override
  String users_doc_label(Object doc) {
    return 'kullanıcı belgesi: $doc';
  }

  @override
  String get ok => 'Tamam';

  @override
  String get fetch_doc_title => 'ID ile belge getir';

  @override
  String get paste_doc_id => 'Müşteri soruları belge ID\'sini buraya yapıştırın:';

  @override
  String get fetch => 'Getir';

  @override
  String get not_found_title => 'Bulunamadı';

  @override
  String document_not_found(Object id) {
    return 'Belge $id mevcut değil veya okunamaz durumda.';
  }

  @override
  String document_title(Object id) {
    return 'Belge $id';
  }

  @override
  String get empty => '<boş>';

  @override
  String get fetch_error_title => 'Hata';

  @override
  String fetch_error_message(Object error) {
    return 'Getirme hatası: $error';
  }

  @override
  String cannot_load_chats(Object error) {
    return 'Sohbetler yüklenemedi: $error';
  }

  @override
  String get no_questions_found => 'Soru bulunamadı';

  @override
  String get show_debug_info => 'Hata ayıklama bilgisini göster';

  @override
  String get delete_chat_title => 'Sohbeti sil';

  @override
  String get delete_chat_confirm => 'Bu sohbeti silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get delete => 'Sil';

  @override
  String get chat_deleted => 'Sohbet silindi';

  @override
  String get delete_failed => 'Silme işlemi başarısız';

  @override
  String get marked_unread => 'Okunmadı olarak işaretlendi';

  @override
  String get action_failed => 'İşlem başarısız';

  @override
  String get user_label_default => 'Kullanıcı';

  @override
  String get reply_hint => 'Bir cevap yazın...';

  @override
  String get send => 'Gönder';

  @override
  String get notify_title => 'Admin\'den yeni mesaj';

  @override
  String notify_body(Object text) {
    return '$text';
  }

  @override
  String get no_faq_items => 'Henüz SSS öğesi yok';

  @override
  String get edit => 'Düzenle';

  @override
  String get remove => 'Kaldır';

  @override
  String get add_new_faq => 'Yeni SSS ekle';

  @override
  String get new_faq_title => 'Yeni SSS';

  @override
  String get question_label => 'Soru/Yorum';

  @override
  String get answer_label => 'Cevap';

  @override
  String get add => 'Ekle';

  @override
  String get faq_added => 'SSS eklendi';

  @override
  String get faq_add_failed => 'Ekleme başarısız';

  @override
  String get edit_faq_title => 'SSS Düzenle';

  @override
  String get faq_updated => 'SSS güncellendi';

  @override
  String get faq_update_failed => 'Kaydetme başarısız';

  @override
  String get delete_faq_title => 'SSS Sil';

  @override
  String get delete_faq_confirm => 'Bu SSS\'yi silmek istediğinizden emin misiniz?';

  @override
  String get faq_deleted => 'SSS silindi';

  @override
  String get faq_delete_failed => 'Silme başarısız';

  @override
  String admins_label(Object names) {
    return 'Adminler: $names';
  }

  @override
  String chat_page_title_prefix(Object prefix) {
    return 'Sohbet: $prefix';
  }

  @override
  String get appTitle => 'CineTrackr';

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navWatchlist => 'Listem';

  @override
  String get navSearch => 'Ara';

  @override
  String get navFood => 'Yemek';

  @override
  String get navigationReorder => 'Gezinmeyi yeniden sırala';

  @override
  String get navProfile => 'Profil';

  @override
  String get infoTooltip => 'Bilgi';

  @override
  String get watchlistInfoTitle => 'Bilgi';

  @override
  String get watchlistInfoContent => 'Uygulama ne yazık ki yayın hizmetlerinden veri çekemiyor. İzlediğiniz bölümleri kendiniz işaretleyebilirsiniz.';

  @override
  String get tutorialHome => 'Burada en yeni film ve dizileri bulabilirsiniz.';

  @override
  String get tutorialWatchlist => 'Favori filmlerinizi daha sonra izlemek için buraya kaydedin.';

  @override
  String get tutorialSearch => 'Belirli başlıkları veya türleri arayın.';

  @override
  String get tutorialFood => 'Film geceniz için uygun atıştırmalıklara göz atın!';

  @override
  String get tutorialProfile => 'Profilinizi ve ayarlarınızı buradan yönetin.';

  @override
  String get tutorialNavBar => 'Hoş geldiniz! Buradan başlangıç ekranını değiştirebilirsiniz. Bir ekranı başlangıç ekranınız yapmak için o düğmeye uzun basın.';

  @override
  String get tutorialNavBar2 => 'Düğmeler arasındaki boşluğu basılı tutarsanız, düğmelerin sırasını değiştirebilirsiniz.';

  @override
  String get tutorialHomeExtra => 'Bu ekranda yeni çıkan filmleri görebilirsin. Bir filme dokunarak o film hakkında daha fazla bilgi alabilirsin.';

  @override
  String get tutorialMainNavigation => 'Ana gezinme';

  @override
  String get tutorialMainNavigationDesc => 'Gezinti çubuğu ve başlangıç ekranı açıklaması';

  @override
  String get tutorialHomeScreen => 'Ana ekran';

  @override
  String get tutorialHomeScreenDesc => 'Ana ekran açıklaması';

  @override
  String get tutorialResetAll => 'Hepsini sıfırla';

  @override
  String get tutorialWatchlistExtra => 'İzleme listende filmleri kaldırabilir of daha sonra izlemek üzere kaydedebilirsin.';

  @override
  String get tutorialSearchExtra => 'Başlıkları ve oyuncuları hızlıca bulmak için arama çubuğunu kullan.';

  @override
  String get tutorialFoodExtra => 'Film tercihine uygun atıştırmalıkları ve tarifleri bul.';

  @override
  String get tutorialProfileExtra => 'Profilinde ayarları, tercihleri ve hesap bilgilerini yönet.';

  @override
  String get tutorialMap => 'Yakındaki sinemaları bulmak için haritaya bakabilirsiniz!';

  @override
  String get tutorialPromptTitle => 'Tanıtım turu';

  @override
  String get tutorialPromptBody => 'Uygulamanın kısa bir turunu görmek ister misiniz?';

  @override
  String get resetTutorial => 'Eğitimi sıfırla';

  @override
  String get tutorialResetExplanation => 'Önce hangi eğitim(leri) sıfırlamak istediğinizi seçin. Eğitimler yalnızca bir seçim yaptıktan sonra sıfırlanacaktır.';

  @override
  String get tutorialResetMessage => 'Eğitim sıfırlandı, yeniden başlatılacak';

  @override
  String get map_all_cinemas_title => 'Hollanda\'daki sinemalar';

  @override
  String map_load_error(Object error) {
    return 'Sinemalar yüklenirken hata oluştu: $error';
  }

  @override
  String get map_location_service_disabled => 'Konum servisi kapalı';

  @override
  String get map_location_permission_denied => 'Konum izni reddedildi';

  @override
  String get map_location_permission_denied_forever => 'Konum izinleri kalıcı olarak reddedildi. Ayarlardan etkinleştirin.';

  @override
  String map_location_fetch_error(Object error) {
    return 'Konum alınamadı: $error';
  }

  @override
  String get map_no_website_content => 'Web sitesi mevcut değil, Sinema bulundu! 🎥';

  @override
  String get unknown => 'Bilinmiyor';

  @override
  String get food_edit_favorite => 'Favoriyi düzenle';

  @override
  String get food_name_label => 'İsim';

  @override
  String get food_only_emoji => 'Sadece Emoji';

  @override
  String get food_location => 'Konum';

  @override
  String get food_diet => 'Beslenme Tercihi';

  @override
  String get food_diet_info => 'Not: Belirli diyet seçenekleri sunan restoranların mevcudiyeti bölgeye göre değişebilir.';

  @override
  String get food_hold_to_edit => 'Düzenlemek için bir ikonun üzerine basılı tutun';

  @override
  String get food_quick_pizza => 'Pizza';

  @override
  String get food_quick_sushi => 'Suşi';

  @override
  String get food_quick_burger => 'Burger';

  @override
  String get food_quick_kapsalon => 'Kapsalon';

  @override
  String get food_search_hint => 'Bir şey ara...';

  @override
  String get food_search_button => 'THUISBEZORGD\'DA ARA';

  @override
  String get food_postcode_label => 'Posta kodu (4 haneli)';

  @override
  String get food_zip_required => 'Önce posta kodunuzun ilk 4 hanesini girin!';

  @override
  String get filter_vegetarian => 'Vejetaryen';

  @override
  String get filter_vegan => 'Vegan';

  @override
  String get filter_gluten_free => 'Glutensiz';

  @override
  String get filter_halal => 'Helal';

  @override
  String get food_what_do_you_want => 'Ne yemek istersiniz?';

  @override
  String get tutorialSkip => 'Atla';

  @override
  String get ellipsis => '...';

  @override
  String get open => 'Aç';

  @override
  String get changeNameTitle => 'Adınızı değiştirin';

  @override
  String get updateFailed => 'Güncelleme başarısız';

  @override
  String get enter_name_description => 'Uygulamayı kişiselleştirmek (örneğin selamlamalar) için adınızı kullanıyoruz.';

  @override
  String get save_and_continue => 'Kaydet ve Devam Et';

  @override
  String get contact_admin_title => 'Admin ile iletişime geç';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get contactNameLabel => 'İsim';

  @override
  String get contactQuestionLabel => 'Soru';

  @override
  String get question_validation => 'Lütfen sorunuzu girin';

  @override
  String get mustBeLoggedInToSend => 'Göndermek için giriş yapmalısınız';

  @override
  String get question_sent => 'Soru gönderildi';

  @override
  String get ai_max_reached => 'Bugün için maksimum yapay zeka soru sınırına ulaştınız. Yarın tekrar deneyin.';

  @override
  String get ask_ai_title => 'Yapay Zekaya Sor';

  @override
  String get ai_wait => 'Lütfen bekleyin, bu işlem bir dakika kadar sürebilir';

  @override
  String get ai_answer_title => 'YZ Yanıtı';

  @override
  String ai_answer_title_with_model(Object model) {
    return 'YZ Yanıtı ($model)';
  }

  @override
  String get ai_failed_all => 'Tüm modeller için YZ isteği başarısız oldu.';

  @override
  String get ai_failed => 'YZ isteği başarısız oldu.';

  @override
  String get login_required_title => 'Giriş Gerekli';

  @override
  String get login_required_message => 'Bunu yapmak için giriş yapmalısınız. Giriş ekranına gitmek ister misiniz?';

  @override
  String get goto_login => 'Giriş yap';

  @override
  String get search_faqs_hint => 'Sıkça sorulan sorularda ara';

  @override
  String get no_faq_matches => 'Eşleşen SSS bulunamadı';

  @override
  String ai_questions_used(Object max, Object used) {
    return 'YZ Soruları: $used/$max kullanıldı';
  }

  @override
  String ask_ai_with_cooldown(Object seconds) {
    return 'YZ\'ye Sor (${seconds}sn)';
  }

  @override
  String get contact_admin_button => 'Admin ile iletişime geç';

  @override
  String get my_questions => 'Sorularım';

  @override
  String get no_questions_sent => 'Henüz hiç soru göndermediniz.';

  @override
  String get message_sent => 'Mesaj gönderildi';

  @override
  String get followup_title => 'Sorunuza yanıt verin';

  @override
  String get enter_message_hint => 'Bir mesaj yazın...';

  @override
  String get faq_default_account_q => 'Nasıl hesap oluşturabilirim?';

  @override
  String get faq_default_account_a => 'Uygulamanın sağ üst köşesindeki profil ikonu üzerinden kayıt olabilirsiniz. Yeni bir hesap oluşturmak için adımları takip edin.';

  @override
  String get faq_default_watchlist_q => 'İzleme listeme nasıl film eklerim?';

  @override
  String get faq_default_watchlist_a => 'Film sayfasını açın ve filmi listenize eklemek için \"Kaydet\" (yer işareti ikonu) düğmesine tıklayın.';

  @override
  String get faq_missing_info_q => 'Neden bir bölüm veya sezon bilgisi eksik?';

  @override
  String get faq_missing_info_a => 'Verilerimiz dış sağlayıcılardan gelmektedir; bazen meta veriler eksik olabilir. Daha sonra tekrar deneyin veya Admin\'e bildirin.';

  @override
  String get faq_report_bug_q => 'Uygulamadaki bir hatayı nasıl bildirebilirim?';

  @override
  String get faq_report_bug_a => 'Açıklama ve ekran görüntüleri içeren bir e-posta göndermek için aşağıdaki \"Admin ile iletişime geç\" düğmesini kullanın.';

  @override
  String get faq_ai_q => 'Yapay zekaya soru sorabilir miyim?';

  @override
  String get faq_ai_a => 'Evet, soru sormak için \"YZ\'ye Sor\" düğmesini kullanın. Yanıtların otomatik olarak oluşturulduğunu lütfen unutmayın.';

  @override
  String get admins_no_push => 'Adminler bildirim almayabilir';

  @override
  String ai_cooldown_wait(Object seconds) {
    return 'Yapay zekayı tekrar kullanmadan önce lütfen $seconds saniye bekleyin.';
  }

  @override
  String get ai_input_hint => 'Film veya diziler hakkındaki sorunuzu buraya yazın...';

  @override
  String get user_new_message_title => 'Kullanıcıdan yeni mesaj';

  @override
  String get nowPlayingTitle => 'Vizyondaki Filmler';

  @override
  String get imdbIdUnavailable => 'Bu film için IMDb ID mevcut değil';

  @override
  String get cannot_load_now_playing => 'Vizyondaki filmler yüklenemedi.';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get no_films_found => 'Film bulunamadı';

  @override
  String get loginWelcome => 'CineTrackr\'a Hoş Geldiniz';

  @override
  String get loginCreateAccount => 'Hesap oluştur';

  @override
  String get loginName => 'İsim';

  @override
  String get loginNameRequired => 'Lütfen adınızı girin';

  @override
  String get loginEmail => 'E-posta';

  @override
  String get loginEmailRequired => 'Lütfen e-posta adresinizi girin';

  @override
  String get loginInvalidEmail => 'Geçersiz e-posta adresi';

  @override
  String get loginPassword => 'Şifre';

  @override
  String get loginPasswordRequired => 'Lütfen şifrenizi girin';

  @override
  String get loginPasswordTooShort => 'Şifre en az 6 karakter olmalıdır';

  @override
  String get loginRegister => 'Kayıt Ol';

  @override
  String get loginNoAccountRegister => 'Henüz hesabınız yok mu? Kayıt olun';

  @override
  String get loginHaveAccountLogin => 'Zaten hesabınız var mı? Giriş yapın';

  @override
  String get loginForgotPassword => 'Şifremi unuttum?';

  @override
  String get loginContinueAsGuest => 'Misafir olarak devam et';

  @override
  String get loginOrDivider => 'VEYA';

  @override
  String get loginSignInWithGoogle => 'Google ile giriş yap';

  @override
  String get loginSignInWithGitHub => 'GitHub ile giriş yap';

  @override
  String get loginSignInWithApple => 'Apple ile giriş yap';

  @override
  String get loginEnterValidEmail => 'Lütfen geçerli bir e-posta adresi girin';

  @override
  String get loginPasswordResetEmailSent => 'Şifre sıfırlama e-postası gönderildi';

  @override
  String get loginPasswordResetFailed => 'Sıfırlama e-postası gönderilemedi';

  @override
  String get loginSomethingWentWrong => 'Bir şeyler yanlış gitti';

  @override
  String get authenticationFailed => 'Kimlik doğrulama başarısız';

  @override
  String get loginGithubFailed => 'GitHub girişi başarısız';

  @override
  String get googleIdTokenError => 'Google ID token alınırken hata oluştu';

  @override
  String get googleSignInCancelled => 'Google girişi iptal edildi';

  @override
  String get loginErrorCredentialMalformed => 'Sağlanan kimlik bilgisi hatalı veya süresi dolmuş.';

  @override
  String get loginErrorUserDisabled => 'Bu kullanıcı hesabı devre dışı bırakıldı.';

  @override
  String get loginErrorTooManyRequests => 'Sıra dışı etkinlik nedeniyle bu cihazdan gelen tüm istekleri engelledik. Daha sonra tekrar deneyin.';

  @override
  String get loginErrorInvalidEmail => 'E-posta adresi kötü biçimlendirilmiş.';

  @override
  String get loginErrorWrongPassword => 'Yanlış şifre.';

  @override
  String get loginErrorUserNotFound => 'Bu e-postaya sahip bir kullanıcı bulunamadı.';

  @override
  String get loginErrorAccountExists => 'Aynı e-posta adresiyle ancak farklı oturum açma bilgileriyle zaten bir hesap var.';

  @override
  String get details => 'Detaylar';

  @override
  String get translate => 'Çevir';

  @override
  String get seen => 'İzlendi';

  @override
  String age_rating(Object rated) {
    return 'Yaş Sınırı: $rated';
  }

  @override
  String get producers_creators => 'Yapımcılar / Yaratıcılar';

  @override
  String get actors => 'Oyuncular';

  @override
  String seasons(Object count) {
    return 'Sezon Sayısı: $count';
  }

  @override
  String episodes(Object count) {
    return 'Bölüm Sayısı: $count';
  }

  @override
  String get streaming => 'Platformlar';

  @override
  String seasons_episodes_title(Object count) {
    return 'Sezonlar ve Bölümler ($count)';
  }

  @override
  String get no_seasons_found => 'Sezon bulunamadı';

  @override
  String get no_episodes_found => 'Bölüm bulunamadı';

  @override
  String get warning_title => '!! Uyarı !!';

  @override
  String get warning_bioscoop_content => 'Programı görmeden önce lütfen web sitesindeki reklamları/açılır pencereleri kapatın.';

  @override
  String get continue_label => 'Devam Et';

  @override
  String get mark_previous_episodes_title => 'Önceki bölümler işaretlensin mi?';

  @override
  String mark_previous_episodes_message(Object count, Object season, Object title) {
    return '\"$title\" bölümünü izlendi olarak işaretliyorsunuz. Ayrıca $season. sezondaki önceki $count bölümü de izlendi olarak işaretlemek ister misiniz?';
  }

  @override
  String episodes_marked_seen(Object count) {
    return '$count bölüm izlendi olarak işaretlendi';
  }

  @override
  String get watchlist_update_failed => 'İzleme listesi güncellenemedi.';

  @override
  String get episode_status_update_failed => 'Bölüm durumu güncellenemedi.';

  @override
  String get movie_seen_update_failed => '\"İzlendi\" durumu güncellenemedi.';

  @override
  String get included_with_subscription => 'Aboneliğe Dahil';

  @override
  String get buy => 'Satın Al';

  @override
  String buy_with_price(Object price) {
    return 'Satın Al • $price';
  }

  @override
  String get rent => 'Kirala';

  @override
  String rent_with_price(Object price) {
    return 'Kirala • $price';
  }

  @override
  String get addon => 'Ek Paket';

  @override
  String addon_with_price(Object price) {
    return 'Ek Paket • $price';
  }

  @override
  String get details_streaming_warning => 'Yayın bağlantısını açmak için tıklayın';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get stars => 'yıldız';

  @override
  String get appleSignInNoIdentityToken => 'Apple girişi başarısız: kimlik tokenı alınamadı';

  @override
  String get googleSignInFailed => 'Google ile giriş başarısız';

  @override
  String get loginErrorWeakPassword => 'Parola çok zayıf.';

  @override
  String get loginErrorNetworkFailed => 'Ağ hatası. Lütfen bağlantınızı kontrol edin.';

  @override
  String get loginErrorRequiresRecentLogin => 'Devam etmek için lütfen tekrar giriş yapın (yakın zamanda kimlik doğrulaması gerekli).';

  @override
  String get avatar_login_prompt => 'Profil fotoğrafınızı değiştirmek için giriş yapın';

  @override
  String get invalid_input => 'Geçersiz giriş';

  @override
  String get only_emoji_error => 'Lütfen sadece emoji girin';

  @override
  String get use => 'Kullan';

  @override
  String get emoji_input_hint => 'Bir emoji yapıştırın veya yazın (isteğe bağlı)';

  @override
  String get edit_avatar_title => 'Profil resmini düzenle';

  @override
  String get choose_color => 'Renk seç';

  @override
  String get choose_emoji_optional => 'Emoji seç (isteğe bağlı)';

  @override
  String get your_badges => 'ROZETLERİNİZ';

  @override
  String get account_section => 'HESAP';

  @override
  String get edit_profile => 'Profili Düzenle';

  @override
  String get films => 'Filmler';

  @override
  String get badge_level_prefix => 'Sv';

  @override
  String get badge_adventurer => 'Maceracı';

  @override
  String get badge_horror_king => 'Korku Kralı';

  @override
  String get badge_binge_watcher => 'Dizi Kurdu';

  @override
  String get badge_early_bird => 'Erkenci Kuş';

  @override
  String get appVersion => 'CineTrackr v1.0.4';

  @override
  String get search_hint => 'Dizi/film ara...';

  @override
  String get clear_tooltip => 'Temizle';

  @override
  String get filter_tooltip => 'Filtrele';

  @override
  String get filter_refine_title => 'Filtreleri Daralt';

  @override
  String get filter_type_label => 'TÜR';

  @override
  String get filter_all => 'Hepsi';

  @override
  String get filter_movies => 'Filmler';

  @override
  String get filter_series => 'Diziler';

  @override
  String get filter_keyword_label => 'ANAHTAR KELİME';

  @override
  String get filter_keyword_hint => 'Örn. Batman, Marvel...';

  @override
  String get filter_genres_label => 'TÜRLER';

  @override
  String get filter_year_from_label => 'YIL (BAŞLANGIÇ)';

  @override
  String get filter_year_to_label => 'YIL (BİTİŞ)';

  @override
  String get filter_min_rating_label => 'MİNİMUM PUAN (0-100)';

  @override
  String get apply_filters => 'Filtreleri Uygula';

  @override
  String get tmdb_movie_fetch_failed => 'Film detayları alınamadı';

  @override
  String get no_imdb_for_movie => 'Bu film için IMDb ID bulunamadı';

  @override
  String get tmdb_movie_fetch_error => 'Film detayları alınırken hata oluştu';

  @override
  String get tmdb_series_fetch_failed => 'Dizi detayları alınamadı';

  @override
  String get no_imdb_for_series => 'Bu dizi için IMDb ID bulunamadı';

  @override
  String get tmdb_series_fetch_error => 'Dizi detayları alınırken hata oluştu';

  @override
  String get load_more_results => 'Daha fazla sonuç yükle';

  @override
  String get best_rated => 'En yüksek puanlı';

  @override
  String get popular => 'Popüler';

  @override
  String get genre_action => 'Aksiyon';

  @override
  String get genre_adventure => 'Macera';

  @override
  String get genre_animation => 'Animasyon';

  @override
  String get genre_comedy => 'Komedi';

  @override
  String get genre_crime => 'Polisiye';

  @override
  String get genre_documentary => 'Belgesel';

  @override
  String get genre_drama => 'Dram';

  @override
  String get genre_family => 'Aile';

  @override
  String get genre_fantasy => 'Fantastik';

  @override
  String get genre_history => 'Tarih';

  @override
  String get genre_horror => 'Korku';

  @override
  String get genre_music => 'Müzik';

  @override
  String get genre_mystery => 'Gizem';

  @override
  String get genre_news => 'Haber';

  @override
  String get genre_reality => 'Reality';

  @override
  String get genre_romance => 'Romantik';

  @override
  String get genre_scifi => 'Bilim Kurgu';

  @override
  String get genre_talk => 'Talk Show';

  @override
  String get genre_thriller => 'Gerilim';

  @override
  String get genre_war => 'Savaş';

  @override
  String get genre_western => 'Vahşi Batı';

  @override
  String get login_progress_save_snack => 'İlerlemenizi kaydetmek için giriş yapın';

  @override
  String get progress_update_failed => 'İlerleme güncellenemedi';

  @override
  String get open_details => 'Detayları aç';

  @override
  String get label_series => 'Dizi';

  @override
  String seen_count(Object count) {
    return 'İzlendi: $count';
  }

  @override
  String get remove_from_watchlist_tooltip => 'İzleme listesinden kaldır';

  @override
  String get login_manage_watchlist_snack => 'İzleme listesini yönetmek için giriş yapın';

  @override
  String get item_removed_watchlist => 'Öğe izleme listesinden kaldırıldı';

  @override
  String get remove_item_failed => 'Öğe kaldırılamadı';

  @override
  String get remove_from_watchlist_title => 'İzleme listesinden kaldır';

  @override
  String get remove_from_watchlist_confirm => 'Bu öğeyi izleme listenizden çıkarmak istediğinizden emin misiniz?';

  @override
  String get tab_saved => 'Kaydedilenler';

  @override
  String get tab_watching => 'İzlenenler';

  @override
  String get watchlist_not_logged_in => 'Henüz giriş yapmadınız.';

  @override
  String get watchlist_login_tap_message => 'Giriş yapmak ve izleme listenizi görmek için buraya dokunun.';

  @override
  String error_loading(Object error) {
    return 'Yükleme hatası: $error';
  }

  @override
  String get no_items => 'Öğe yok';

  @override
  String season_label(Object number) {
    return 'Sezon $number';
  }

  @override
  String season_short(Object num) {
    return 'S$num';
  }

  @override
  String seen_x_of_y(Object seen, Object total) {
    return '$seen/$total izlendi';
  }

  @override
  String title_wait(Object title) {
    return '$title: lütfen bekleyin...';
  }

  @override
  String get no_progress_for_films => 'Filmler için henüz ilerleme yok';

  @override
  String get episode => 'Bölüm';

  @override
  String seen_episodes_label(Object count) {
    return 'İzlenen bölümler: $count';
  }

  @override
  String get disclaimerTitle => 'Feragatname';

  @override
  String get disclaimerHeading => 'Üçüncü taraf hizmetleri ve veri kaynakları';

  @override
  String get disclaimerText => 'Bu uygulama birden fazla üçüncü taraf kaynaktan veri kullanır:\n\n* Brian Fritz tarafından sağlanan API (OMDb API)\n CC BY-NC 4.0 lisansı altında lisanslanmıştır\n Bu hizmet IMDb.com tarafından onaylanmamış veya onunla bağlantılı değildir\n\n* Bu uygulama TMDB ve TMDB API’lerini kullanır ancak TMDB tarafından onaylanmamış, sertifikalandırılmamış veya başka bir şekilde desteklenmemektedir\n\n* Bazı veriler IMDb’den alınmıştır\n\n* Yayın (streaming) bilgileri ve çeviri hizmetleri RapidAPI üzerinden sağlanmaktadır\n\n* Fragmanlar YouTube tarafından sağlanmaktadır\n\nHarita verileri © OpenStreetMap katkıda bulunanlar\n\nTüm ticari markalar, logolar ve telif hakları ilgili sahiplerine aittir.';

  @override
  String get playbackDisabledByVideoOwner => 'Oynatma, videonun sahibi tarafından devre dışı bırakıldı.';

  @override
  String get disclaimerNote => 'Tüm üçüncü taraf ticari markaları, logoları ve veriler ilgili sahiplerine aittir; ayrıntılar için lütfen hizmetlerin kullanım koşullarını ve gizlilik politikalarını inceleyin.';

  @override
  String get add_series_button => 'Dizi ekle';

  @override
  String get add_series_title => 'Dizi ekle';

  @override
  String get add_series_use_dates => 'Yinelenen günleri kullan';

  @override
  String get add_series_until_date => 'Tarihine kadar';

  @override
  String get until_label => 'Kadar';

  @override
  String get select => 'Seç';

  @override
  String get imdb_id_label => 'ID (örn. tt1234567)';

  @override
  String get title_label => 'Başlık';

  @override
  String get number_of_seasons => 'Sezon sayısı';

  @override
  String get number_of_episodes => 'Bölüm sayısı';

  @override
  String episodes_in_season(Object season) {
    return 'Sezon $season içindeki bölümler';
  }

  @override
  String get episodes_per_season_hint => 'Sezon başına bölüm sayısı (virgülle ayrılmış, örn. 10,8,12)';

  @override
  String get invalid_series_input => 'Geçersiz giriş';

  @override
  String get series_added => 'Dizi eklendi';

  @override
  String get add_series_failed => 'Dizi eklenemedi';

  @override
  String set_as_start_screen(Object label) {
    return '$label başlangıç ekranı olarak ayarlandı';
  }

  @override
  String get save_failed => 'Kaydetme başarısız';

  @override
  String get label_biosagenda => 'Biosagenda';

  @override
  String get label_kinepolis => 'Kinepolis';

  @override
  String get tutorialSearchField => 'Aramak için buraya bir film veya dizi adı yazın.';

  @override
  String get tutorialSearchFilter => 'Tür, yıl veya puana göre detaylı filtrelemek için bu düğmeyi kullanın.';

  @override
  String get tutorialSearchTabs => 'En iyi puan alan ve popüler başlıklar arasında buradan geçiş yapın.';

  @override
  String get tutorialSearchScreenMain => 'Arama ekranı';

  @override
  String get tutorialSearchScreenDesc => 'Arama ekranının açıklaması';

  @override
  String get tutorialFoodZip => 'Bölgenizde daha hızlı yemek bulmak için posta kodunuzu buraya girin.';

  @override
  String get tutorialFoodDiet => 'Yiyecekleri filtreleyebilmemiz için diyet gereksinimlerinizi buraya girin.';

  @override
  String get tutorialFoodQuick => 'Sipariş vermek için buraya dokunun! Bir favoriyi düzenlemek için basılı tutun.';

  @override
  String get tutorialFoodSearch => 'Canınızın çektiği şeyi manuel olarak arayın ve arabaya basın.';

  @override
  String get tutorialFoodScreenMain => 'Yemek ekranı';

  @override
  String get tutorialFoodScreenDesc => 'Yemek ekranı açıklaması';

  @override
  String get tutorialWatchlistTabs => 'Burada kaydedilmiş filmleriniz/dizileriniz ile şu anda izledikleriniz arasında geçiş yapın.';

  @override
  String get tutorialWatchlistLogin => 'Filmlerinizi ve dizilerinizi kaydetmek için buradan giriş yapın veya hesap oluşturun.';

  @override
  String get tutorialWatchlistContent => 'Kaydettiğiniz her şeyi yönetin veya kaldığınız yerden izlemeye devam edin.';

  @override
  String get tutorialWatchlistScreenMain => 'Listem';

  @override
  String get tutorialWatchlistScreenDesc => 'İzleme listesi ve kaydedilen filmlerin açıklaması';

  @override
  String get tutorialProfileAvatar => 'Avatarınızı ve görünen adınızı değiştirmek için buraya dokunun.';

  @override
  String get tutorialProfileStats => 'Kaç film izlediğinizi ve kaydettiğinizi bir bakışta görün.';

  @override
  String get tutorialProfileBadges => 'Uygulamayı kullanarak rozet kazanın. Detayları görmek için dokunun!';

  @override
  String get tutorialProfileSettings => 'Bildirimler veya tema gibi tüm uygulama ayarlarını burada bulabilirsiniz.';

  @override
  String get tutorialProfileScreenMain => 'Profil ekranı';

  @override
  String get tutorialProfileScreenDesc => 'Profil ekranının açıklaması';

  @override
  String get badge_adventurer_desc => 'Seviye atlamak için 10 macera filmi veya dizisi kaydedin.';

  @override
  String get badge_horror_desc => 'Seviye atlamak için listenize 10 korku veya gerilim filmi ekleyin.';

  @override
  String get badge_binge_desc => 'Seviye atlamak için bir günde 10 öğe izleyin veya işaretleyin.';

  @override
  String get badge_early_desc => 'Seviye atlamak için sabah 05:00 ile 08:00 arasında 10 öğe kaydedin.';

  @override
  String get badge_dialog_close => 'Kapat';

  @override
  String get tutorialMovieDetailInfo => 'Burada açıklama (çevirebileceğiniz) dâhil olmak üzere film veya dizi hakkında en önemli bilgileri görürsünüz.';

  @override
  String get tutorialMovieDetailWatchlist => 'Tıkla düğmesiyle bu filmi kolayca izlendi olarak işaretleyin veya izleme listenize ekleyin!';

  @override
  String get tutorialMovieDetailStreaming => 'Bu dizinin abonelikleriniz dâhilinde izlenebileceğini veya kiralayıp satın alabileceğiniz yerleri buradan bulun.';

  @override
  String get tutorialMovieDetailSeasons => 'Bu başlık bir dizi olduğundan, diziyi izlemeye devam edebilmeniz için tüm sezon bilgilerini burada bulabilirsiniz.';

  @override
  String get tutorialMovieDetailMain => 'Film/Dizi Ayrıntıları';

  @override
  String get tutorialMovieDetailDesc => 'Detaylar, ekleme işlemleri ve akış seçenekleri hakkında bilgi ekranı';

  @override
  String get tutorialMovieDetailResetToast => 'Öğreticiyi görüntülemek için herhangi bir filme veya diziye gidin!';
}
