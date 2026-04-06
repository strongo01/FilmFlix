import os
import json

locales = {
  'nl': {
    "tutorialProfileScreenMain": "Profielscherm",
    "tutorialProfileScreenDesc": "Uitleg over het profielscherm"
  },
  'en': {
    "tutorialProfileScreenMain": "Profile screen",
    "tutorialProfileScreenDesc": "Explanation of the profile screen"
  },
  'de': {
    "tutorialProfileScreenMain": "Profilbildschirm",
    "tutorialProfileScreenDesc": "Erklärung des Profilbildschirms"
  },
  'es': {
    "tutorialProfileScreenMain": "Pantalla de perfil",
    "tutorialProfileScreenDesc": "Explicación de la pantalla de perfil"
  },
  'fr': {
    "tutorialProfileScreenMain": "Écran de profil",
    "tutorialProfileScreenDesc": "Explication de l'écran de profil"
  },
  'tr': {
    "tutorialProfileScreenMain": "Profil ekranı",
    "tutorialProfileScreenDesc": "Profil ekranının açıklaması"
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
