import os
import json

locales = {
  'nl': {
    "tutorialWatchlistTabs": "Hier wissel je tussen je opgeslagen films/series en de series die je nu aan het kijken bent.",
    "tutorialWatchlistLogin": "Log hier in of maak een account aan om je films en series op te kunnen slaan.",
    "tutorialWatchlistContent": "Hier beheer je alles wat je hebt opgeslagen of waar je gebleven was met kijken.",
    "tutorialWatchlistScreenMain": "Mijn lijst",
    "tutorialWatchlistScreenDesc": "Uitleg over de volglijst en bewaarde films"
  },
  'en': {
    "tutorialWatchlistTabs": "Switch between your saved movies/series and what you're currently watching here.",
    "tutorialWatchlistLogin": "Log in or create an account here to save your movies and series.",
    "tutorialWatchlistContent": "Manage everything you've saved or continue watching from where you left off.",
    "tutorialWatchlistScreenMain": "My list",
    "tutorialWatchlistScreenDesc": "Explanation of the watchlist and saved movies"
  },
  'de': {
    "tutorialWatchlistTabs": "Wechseln Sie hier zwischen Ihren gespeicherten Filmen/Serien und dem, was Sie gerade sehen.",
    "tutorialWatchlistLogin": "Melden Sie sich hier an oder erstellen Sie ein Konto, um Ihre Filme und Serien zu speichern.",
    "tutorialWatchlistContent": "Verwalten Sie alles, was Sie gespeichert haben, oder setzen Sie die Wiedergabe fort.",
    "tutorialWatchlistScreenMain": "Meine Liste",
    "tutorialWatchlistScreenDesc": "Erklärung der Merkliste und der gespeicherten Filme"
  },
  'es': {
    "tutorialWatchlistTabs": "Cambia entre tus películas/series guardadas y lo que estás viendo actualmente aquí.",
    "tutorialWatchlistLogin": "Inicia sesión o crea una cuenta aquí para guardar tus películas y series.",
    "tutorialWatchlistContent": "Administra todo lo que has guardado o continúa viendo desde donde lo dejaste.",
    "tutorialWatchlistScreenMain": "Mi lista",
    "tutorialWatchlistScreenDesc": "Explicación de la lista de seguimiento y las películas guardadas"
  },
  'fr': {
    "tutorialWatchlistTabs": "Basculez ici entre vos films/séries enregistrés et ce que vous regardez actuellement.",
    "tutorialWatchlistLogin": "Connectez-vous ou créez un compte ici pour enregistrer vos films et séries.",
    "tutorialWatchlistContent": "Gérez tout ce que vous avez enregistré ou reprenez la lecture là où vous vous étiez arrêté.",
    "tutorialWatchlistScreenMain": "Ma liste",
    "tutorialWatchlistScreenDesc": "Explication de la liste de suivi et des films enregistrés"
  },
  'tr': {
    "tutorialWatchlistTabs": "Burada kaydedilmiş filmleriniz/dizileriniz ile şu anda izledikleriniz arasında geçiş yapın.",
    "tutorialWatchlistLogin": "Filmlerinizi ve dizilerinizi kaydetmek için buradan giriş yapın veya hesap oluşturun.",
    "tutorialWatchlistContent": "Kaydettiğiniz her şeyi yönetin veya kaldığınız yerden izlemeye devam edin.",
    "tutorialWatchlistScreenMain": "Listem",
    "tutorialWatchlistScreenDesc": "İzleme listesi ve kaydedilen filmlerin açıklaması"
  }
}

dir_path = 'filmflix/lib/l10n'
for lang, keys in locales.items():
    file_path = os.path.join(dir_path, f'app_{lang}.arb')
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        data.update({k: v for k, v in keys.items() if k not in data})
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write('\n')