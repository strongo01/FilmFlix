import json
import os

langs = {
  "nl": {
    "badge_adventurer_desc": "Voeg 10 avontuurlijke films of series toe om dit level te verhogen.",
    "badge_horror_desc": "Voeg 5 horror- of thrillerfilms toe aan je lijst om dit level te verhogen.",
    "badge_binge_desc": "Voeg binnen 10 minuten 2 of meer items toe. Doe dit 3 keer om dit level te verhogen.",
    "badge_early_desc": "Voeg 5 items toe tussen 00:00 en 06:00 's nachts om dit level te verhogen."
  },
  "en": {
    "badge_adventurer_desc": "Add 10 adventure movies or series to increase this level.",
    "badge_horror_desc": "Add 5 horror or thriller movies to your list to increase this level.",
    "badge_binge_desc": "Add 2 or more items within 10 minutes. Do this 3 times to increase this level.",
    "badge_early_desc": "Add 5 items between 00:00 and 06:00 at night to increase this level."
  },
  "de": {
    "badge_adventurer_desc": "Fügen Sie 10 Abenteuerfilme oder -serien hinzu, um dieses Level zu erhöhen.",
    "badge_horror_desc": "Fügen Sie Ihrer Liste 5 Horror- oder Thrillerfilme hinzu, um dieses Level zu erhöhen.",
    "badge_binge_desc": "Fügen Sie 2 oder mehr Elemente innerhalb von 10 Minuten hinzu. Tun Sie dies 3 Mal, um dieses Level zu erhöhen.",
    "badge_early_desc": "Fügen Sie 5 Elemente zwischen 00:00 und 06:00 Uhr nachts hinzu, um dieses Level zu erhöhen."
  },
  "es": {
    "badge_adventurer_desc": "Añade 10 películas o series de aventuras para aumentar este nivel.",
    "badge_horror_desc": "Añade 5 películas de terror o suspense a tu lista para aumentar este nivel.",
    "badge_binge_desc": "Añade 2 o más elementos en un intervalo de 10 minutos. Haz esto 3 veces para aumentar este nivel.",
    "badge_early_desc": "Añade 5 elementos entre las 00:00 y las 06:00 de la noche para aumentar este nivel."
  },
  "fr": {
    "badge_adventurer_desc": "Ajoutez 10 films ou séries d'aventure pour augmenter ce niveau.",
    "badge_horror_desc": "Ajoutez 5 films d'horreur ou à suspense à votre liste pour augmenter ce niveau.",
    "badge_binge_desc": "Ajoutez 2 éléments ou plus en moins de 10 minutes. Faites cela 3 fois pour augmenter ce niveau.",
    "badge_early_desc": "Ajoutez 5 éléments entre 00h00 et 06h00 de la nuit pour augmenter ce niveau."
  },
  "it": {
    "badge_adventurer_desc": "Aggiungi 10 film o serie d'avventura per aumentare questo livello.",
    "badge_horror_desc": "Aggiungi 5 film horror o thriller alla tua lista per aumentare questo livello.",
    "badge_binge_desc": "Aggiungi 2 o più elementi in 10 minuti. Fallo 3 volte per aumentare questo livello.",
    "badge_early_desc": "Aggiungi 5 elementi tra le 00:00 e le 06:00 di notte per aumentare questo livello."
  }
}

l10n_dir = "/Users/max/Desktop/filmflix/filmflix/lib/l10n"

for lang, updates in langs.items():
    file_path = os.path.join(l10n_dir, f"app_{lang}.arb")
    if os.path.exists(file_path):
        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        
        for key, val in updates.items():
            if key in data:
                data[key] = val
        
        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")
