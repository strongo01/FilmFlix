import os
import json

locales = {
  'nl': {
    "tutorialProfileAvatar": "Klik hier om je avatar en je weergavenaam aan te passen.",
    "tutorialProfileStats": "Hier zie je in één oogopslag hoeveel films je hebt bekeken en opgeslagen.",
    "tutorialProfileBadges": "Door de app te gebruiken verdien je badgen. Tik erop om ze te bekijken!",
    "tutorialProfileSettings": "Hier vind je alle app-instellingen, zoals notificaties of thema.",
    "tutorialProfileScreenMain": "Profielscherm",
    "tutorialProfileScreenDesc": "Uitleg over het profielscherm"
  },
  'en': {
    "tutorialProfileAvatar": "Tap here to change your avatar and display name.",
    "tutorialProfileStats": "See at a glance how many movies you've watched and saved.",
    "tutorialProfileBadges": "Earn badges by using the app. Tap them to view details!",
    "tutorialProfileSettings": "Here you can find all app settings, such as notifications or theme.",
    "tutorialProfileScreenMain": "Profile screen",
    "tutorialProfileScreenDesc": "Explanation of the profile screen"
  },
  'de': {
    "tutorialProfileAvatar": "Tippen Sie hier, um Ihren Avatar und Anzeigenamen zu ändern.",
    "tutorialProfileStats": "Sehen Sie auf einen Blick, wie viele Filme Sie angesehen und gespeichert haben.",
    "tutorialProfileBadges": "Verdienen Sie Abzeichen durch Nutzung der App. Tippen Sie darauf, um sie anzusehen!",
    "tutorialProfileSettings": "Hier finden Sie alle App-Einstellungen wie Benachrichtigungen oder Design.",
    "tutorialProfileScreenMain": "Profilbildschirm",
    "tutorialProfileScreenDesc": "Erklärung des Profilbildschirms"
  },
  'es': {
    "tutorialProfileAvatar": "Toca aquí para cambiar tu avatar y nombre de visualización.",
    "tutorialProfileStats": "Mira de un vistazo cuántas películas has visto y guardado.",
    "tutorialProfileBadges": "Gana insignias usando la aplicación. ¡Toca para ver los detalles!",
    "tutorialProfileSettings": "Aquí encontrarás todas las configuraciones de la aplicación, como notificaciones o temas.",
    "tutorialProfileScreenMain": "Pantalla de perfil",
    "tutorialProfileScreenDesc": "Explicación de la pantalla de perfil"
  },
  'fr': {
    "tutorialProfileAvatar": "Appuyez ici pour changer votre avatar et nom d'affichage.",
    "tutorialProfileStats": "Voyez en un coup d'œil combien de films vous avez regardés et enregistrés.",
    "tutorialProfileBadges": "Gagnez des badges en utilisant l'application. Appuyez dessus pour voir les détails !",
    "tutorialProfileSettings": "Vous trouverez ici tous les paramètres de l'application, comme les notifications ou le thème.",
    "tutorialProfileScreenMain": "Écran de profil",
    "tutorialProfileScreenDesc": "Explication de l'écran de profil"
  },
  'tr': {
    "tutorialProfileAvatar": "Avatarınızı ve görünen adınızı değiştirmek için buraya dokunun.",
    "tutorialProfileStats": "Kaç film izlediğinizi ve kaydettiğinizi bir bakışta görün.",
    "tutorialProfileBadges": "Uygulamayı kullanarak rozet kazanın. Detayları görmek için dokunun!",
    "tutorialProfileSettings": "Bildirimler veya tema gibi tüm uygulama ayarlarını burada bulabilirsiniz.",
    "tutorialProfileScreenMain": "Profil ekranı",
    "tutorialProfileScreenDesc": "Profil ekranının açıklaması"
  }
}

dir_path = './lib/l10n'
for lang, keys in locales.items():
    file_path = os.path.join(dir_path, f'app_{lang}.arb')
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        data.update(keys)
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write('\n')
