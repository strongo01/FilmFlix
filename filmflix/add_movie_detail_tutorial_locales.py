import json
import os

langs = {
  "nl": {
    "tutorialMovieDetailInfo": "Hier zie je de belangrijkste informatie over de film of serie, inclusief de beschrijving (die je met 1 druk op de knop kunt vertalen).",
    "tutorialMovieDetailWatchlist": "Voeg deze titel toe aan je volglijst met het opslaan-icoon of markeer de film in één keer gemakkelijk als gezien!",
    "tutorialMovieDetailStreaming": "Kijk of deze titel gratis beschikbaar is binnen je abonnementen, of waar je hem kunt huren/kopen.",
    "tutorialMovieDetailSeasons": "Omdat deze titel een serie is, vind je hier alle informatie over de seizoenen en individuele afleveringen om je voortgang bij te houden.",
    "tutorialMovieDetailMain": "Filmdetail scherm",
    "tutorialMovieDetailDesc": "Uitleg over de informatie, het toevoegen en streamen in de filmdetailpagina"
  },
  "en": {
    "tutorialMovieDetailInfo": "Here you see the most important information about the movie or series, including the description (which you can translate).",
    "tutorialMovieDetailWatchlist": "Add this title to your watchlist with the save icon or easily mark the movie as seen!",
    "tutorialMovieDetailStreaming": "See if this title is available within your subscriptions or where you can rent/buy it.",
    "tutorialMovieDetailSeasons": "Because this title is a series, you'll find all the information about seasons and individual episodes right here to track your progress.",
    "tutorialMovieDetailMain": "Movie Details Screen",
    "tutorialMovieDetailDesc": "Explanation of the information, tracking and streaming options on the movie details page"
  },
  "de": {
    "tutorialMovieDetailInfo": "Hier sehen Sie die wichtigsten Informationen zum Film oder zur Serie, einschließlich der Beschreibung (die Sie übersetzen können).",
    "tutorialMovieDetailWatchlist": "Fügen Sie diesen Titel mit dem Speichern-Symbol zu Ihrer Merkliste hinzu oder markieren Sie ihn einfach als gesehen!",
    "tutorialMovieDetailStreaming": "Schauen Sie nach, ob dieser Titel in Ihren Abonnements enthalten ist oder wo Sie ihn mieten/kaufen können.",
    "tutorialMovieDetailSeasons": "Da dieser Titel eine Serie ist, finden Sie hier alle Informationen zu Staffeln und Episoden, um Ihren Fortschritt zu verfolgen.",
    "tutorialMovieDetailMain": "Filmdetails Bildschirm",
    "tutorialMovieDetailDesc": "Erklärung zu Informationen, Speichern und Streaming auf der Filmdetailseite"
  },
  "es": {
    "tutorialMovieDetailInfo": "Aquí ves la información más importante sobre la película o serie, incluida la descripción (que puedes traducir).",
    "tutorialMovieDetailWatchlist": "¡Añade este título a tu lista de seguimiento con el icono de guardar o simplemente marca la película como vista!",
    "tutorialMovieDetailStreaming": "Comprueba si este título está disponible en tus suscripciones o dónde puedes alquilarlo/comprarlo.",
    "tutorialMovieDetailSeasons": "Dado que este título es una serie, encontrarás toda la información sobre las temporadas y episodios para hacer un seguimiento de tu progreso.",
    "tutorialMovieDetailMain": "Pantalla de Detalles de la Película",
    "tutorialMovieDetailDesc": "Explicación de la información, opciones de guardado y transmisión en la página de detalles de la película"
  },
  "fr": {
    "tutorialMovieDetailInfo": "Ici, vous voyez les informations les plus importantes sur le film ou la série, y compris la description (que vous pouvez traduire).",
    "tutorialMovieDetailWatchlist": "Ajoutez ce titre à votre liste de suivi avec l'icône de sauvegarde ou marquez facilement le film comme vu !",
    "tutorialMovieDetailStreaming": "Regardez si ce titre est disponible dans vos abonnements ou où vous pouvez le louer/l'acheter.",
    "tutorialMovieDetailSeasons": "Comme ce titre est une série, vous trouverez toutes les informations sur les saisons et les épisodes individuels pour suivre vos progrès.",
    "tutorialMovieDetailMain": "Écran Détails du Film",
    "tutorialMovieDetailDesc": "Explication des informations, du suivi et des options de streaming sur la page des détails du film"
  },
  "it": {
    "tutorialMovieDetailInfo": "Qui vedi le informazioni più importanti sul film o sulla serie, inclusa la descrizione (che puoi tradurre).",
    "tutorialMovieDetailWatchlist": "Aggiungi questo titolo alla tua Watchlist con l'icona di salvataggio o contrassegna facilmente il film come visto!",
    "tutorialMovieDetailStreaming": "Controlla se questo titolo è disponibile all'interno dei tuoi abbonamenti o dove puoi noleggiarlo/acquistarlo.",
    "tutorialMovieDetailSeasons": "Essendo una serie, troverai tutte le informazioni sulle stagioni e i singoli episodi per monitorare i tuoi progressi.",
    "tutorialMovieDetailMain": "Schermata Dettagli Film",
    "tutorialMovieDetailDesc": "Spiegazione delle informazioni, opzioni di tracciamento e streaming nella pagina dei dettagli del film"
  }
}

l10n_dir = "/Users/max/Desktop/filmflix/filmflix/lib/l10n"

for lang, updates in langs.items():
    file_path = os.path.join(l10n_dir, f"app_{lang}.arb")
    if os.path.exists(file_path):
        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        
        for key, val in updates.items():
            if key not in data:
                data[key] = val
        
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")
