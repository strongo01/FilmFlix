import os
import json

locales = {
  'nl': {
    "tutorialSearchField": "Typ hier de naam van een film of serie om te zoeken.",
    "tutorialSearchFilter": "Gebruik deze knop om uitgebreid te filteren op genre, jaar of beoordeling.",
    "tutorialSearchTabs": "Schakel hier tussen de best beoordeelde en populairste titels.",
    "tutorialSearchScreenMain": "Zoek scherm",
    "tutorialSearchScreenDesc": "Uitleg over het zoekscherm"
  },
  'en': {
    "tutorialSearchField": "Type the name of a movie or series here to search.",
    "tutorialSearchFilter": "Use this button to filter by genre, year or rating.",
    "tutorialSearchTabs": "Switch between top rated and popular titles here.",
    "tutorialSearchScreenMain": "Search screen",
    "tutorialSearchScreenDesc": "Explanation of the search screen"
  },
  'de': {
    "tutorialSearchField": "Geben Sie hier den Namen eines Films oder einer Serie ein, um zu suchen.",
    "tutorialSearchFilter": "Verwenden Sie diese Schaltfläche, um nach Genre, Jahr oder Bewertung zu filtern.",
    "tutorialSearchTabs": "Wechseln Sie hier zwischen am besten bewerteten und beliebten Titeln.",
    "tutorialSearchScreenMain": "Suchbildschirm",
    "tutorialSearchScreenDesc": "Erklärung des Suchbildschirms"
  },
  'es': {
    "tutorialSearchField": "Escriba aquí el nombre de una película o serie para buscar.",
    "tutorialSearchFilter": "Utilice este botón para filtrar por género, año o calificación.",
    "tutorialSearchTabs": "Cambie aquí entre títulos populares y mejor valorados.",
    "tutorialSearchScreenMain": "Pantalla de búsqueda",
    "tutorialSearchScreenDesc": "Explicación de la pantalla de búsqueda"
  },
  'fr': {
    "tutorialSearchField": "Tapez le nom d'un film ou d'une série ici pour rechercher.",
    "tutorialSearchFilter": "Utilisez ce bouton pour filtrer par genre, année ou note.",
    "tutorialSearchTabs": "Basculez ici entre les titres les mieux notés et populaires.",
    "tutorialSearchScreenMain": "Écran de recherche",
    "tutorialSearchScreenDesc": "Explication de l'écran de recherche"
  },
  'tr': {
    "tutorialSearchField": "Aramak için buraya bir film veya dizi adı yazın.",
    "tutorialSearchFilter": "Tür, yıl veya puana göre detaylı filtrelemek için bu düğmeyi kullanın.",
    "tutorialSearchTabs": "En iyi puan alan ve popüler başlıklar arasında buradan geçiş yapın.",
    "tutorialSearchScreenMain": "Arama ekranı",
    "tutorialSearchScreenDesc": "Arama ekranının açıklaması"
  }
}

dir_path = 'filmflix/lib/l10n'
for lang, keys in locales.items():
    file_path = os.path.join(dir_path, f'app_{lang}.arb')
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        data.update(keys)
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write('\n')
