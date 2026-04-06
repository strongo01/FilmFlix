import os
import json

locales = {
  'nl': {
    "badge_adventurer_desc": "Sla 10 avontuurlijke films of series op om dit level te verhogen.",
    "badge_horror_desc": "Voeg 10 horror- of thrillerfilms toe aan je lijst om dit level te verhogen.",
    "badge_binge_desc": "Kijk of markeer 10 items op één dag als bekeken om dit level te verhogen.",
    "badge_early_desc": "Sla 10 items op tussen 05:00 en 08:00 's ochtends om dit level te verhogen.",
    "badge_dialog_close": "Sluiten"
  },
  'en': {
    "badge_adventurer_desc": "Save 10 adventure movies or series to level up.",
    "badge_horror_desc": "Add 10 horror or thriller movies to your list to level up.",
    "badge_binge_desc": "Watch or mark 10 items in a single day to level up.",
    "badge_early_desc": "Save 10 items between 5:00 AM and 8:00 AM to level up.",
    "badge_dialog_close": "Close"
  },
  'de': {
    "badge_adventurer_desc": "Speichern Sie 10 Abenteuerfilme oder -serien, um aufzusteigen.",
    "badge_horror_desc": "Fügen Sie 10 Horror- oder Thrillerfilme zu Ihrer Liste hinzu, um aufzusteigen.",
    "badge_binge_desc": "Markieren oder sehen Sie sich 10 Titel an einem einzigen Tag an, um aufzusteigen.",
    "badge_early_desc": "Speichern Sie 10 Titel zwischen 05:00 und 08:00 Uhr morgens, um aufzusteigen.",
    "badge_dialog_close": "Schließen"
  },
  'es': {
    "badge_adventurer_desc": "Guarda 10 películas o series de aventuras para subir de nivel.",
    "badge_horror_desc": "Agrega 10 películas de terror o suspenso a tu lista para subir de nivel.",
    "badge_binge_desc": "Mira o marca 10 títulos en un solo día para subir de nivel.",
    "badge_early_desc": "Guarda 10 títulos entre las 5:00 y las 8:00 de la mañana para subir de nivel.",
    "badge_dialog_close": "Cerrar"
  },
  'fr': {
    "badge_adventurer_desc": "Enregistrez 10 films ou séries d'aventure pour passer au niveau supérieur.",
    "badge_horror_desc": "Ajoutez 10 films d'horreur ou thrillers à votre liste pour monter de niveau.",
    "badge_binge_desc": "Regardez ou marquez 10 titres en une seule journée pour monter de niveau.",
    "badge_early_desc": "Enregistrez 10 titres entre 05h00 et 08h00 du matin pour passer au niveau supérieur.",
    "badge_dialog_close": "Fermer"
  },
  'tr': {
    "badge_adventurer_desc": "Seviye atlamak için 10 macera filmi veya dizisi kaydedin.",
    "badge_horror_desc": "Seviye atlamak için listenize 10 korku veya gerilim filmi ekleyin.",
    "badge_binge_desc": "Seviye atlamak için bir günde 10 öğe izleyin veya işaretleyin.",
    "badge_early_desc": "Seviye atlamak için sabah 05:00 ile 08:00 arasında 10 öğe kaydedin.",
    "badge_dialog_close": "Kapat"
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
