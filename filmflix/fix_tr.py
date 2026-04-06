import json
import os

langs = {
  "tr": {
    "tutorialMovieDetailInfo": "Burada açıklama (çevirebileceğiniz) dâhil olmak üzere film veya dizi hakkında en önemli bilgileri görürsünüz.",
    "tutorialMovieDetailWatchlist": "Tıkla düğmesiyle bu filmi kolayca izlendi olarak işaretleyin veya izleme listenize ekleyin!",
    "tutorialMovieDetailStreaming": "Bu dizinin abonelikleriniz dâhilinde izlenebileceğini veya kiralayıp satın alabileceğiniz yerleri buradan bulun.",
    "tutorialMovieDetailSeasons": "Bu başlık bir dizi olduğundan, diziyi izlemeye devam edebilmeniz için tüm sezon bilgilerini burada bulabilirsiniz.",
    "tutorialMovieDetailMain": "Film/Dizi Ayrıntıları",
    "tutorialMovieDetailDesc": "Detaylar, ekleme işlemleri ve akış seçenekleri hakkında bilgi ekranı"
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
