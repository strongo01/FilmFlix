import json
import os

langs = {
  "nl": { "tutorialMovieDetailResetToast": "Ga naar een willekeurige film of serie om de tutorial te bekijken!" },
  "en": { "tutorialMovieDetailResetToast": "Navigate to any movie or series to view the tutorial!" },
  "de": { "tutorialMovieDetailResetToast": "Navigieren Sie zu einem beliebigen Film oder einer Serie, um das Tutorial anzusehen!" },
  "es": { "tutorialMovieDetailResetToast": "¡Navegue a cualquier película o serie para ver el tutorial!" },
  "fr": { "tutorialMovieDetailResetToast": "Naviguez vers n'importe quel film ou série pour voir le tutoriel !" },
  "it": { "tutorialMovieDetailResetToast": "Naviga su qualsiasi film o serie per visualizzare il tutorial!" },
  "tr": { "tutorialMovieDetailResetToast": "Öğreticiyi görüntülemek için herhangi bir filme veya diziye gidin!" }
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
