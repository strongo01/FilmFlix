import os
import json

locales = {
  'nl': {
    "tutorialFoodZip": "Vul hier je postcode in om sneller eten te vinden en te bestellen bij jou in de buurt.",
    "tutorialFoodDiet": "Geef hier je dieetwensen of allergieën aan, dan filteren wij het eten voor je.",
    "tutorialFoodQuick": "Tik hier snel op wat je wil eten! Houd een favoriet vast om hem te bewerken.",
    "tutorialFoodSearch": "Zoek handmatig naar eten waar je zin in hebt en druk op zoeken.",
    "tutorialFoodScreenMain": "Food scherm",
    "tutorialFoodScreenDesc": "Uitleg over het foodscherm (eten bestellen)"
  },
  'en': {
    "tutorialFoodZip": "Enter your zipcode here to find and order food faster in your area.",
    "tutorialFoodDiet": "Specify your dietary requirements or allergies here, so we can filter the food.",
    "tutorialFoodQuick": "Tap here quickly to order! Hold a favorite to edit it.",
    "tutorialFoodSearch": "Manually search for what you are craving and press search.",
    "tutorialFoodScreenMain": "Food screen",
    "tutorialFoodScreenDesc": "Explanation of the food screen"
  },
  'de': {
    "tutorialFoodZip": "Geben Sie hier Ihre Postleitzahl ein, um Essen in Ihrer Nähe schneller zu finden.",
    "tutorialFoodDiet": "Geben Sie hier Ihre Ernährungsbedürfnisse an, damit wir das Essen filtern können.",
    "tutorialFoodQuick": "Tippen Sie schnell hier, um zu bestellen! Halten Sie einen Favoriten gedrückt, um ihn zu bearbeiten.",
    "tutorialFoodSearch": "Suchen Sie manuell nach etwas, worauf Sie Lust haben, und drücken Sie auf Suchen.",
    "tutorialFoodScreenMain": "Essen-Bildschirm",
    "tutorialFoodScreenDesc": "Erklärung des Essen-Bildschirms"
  },
  'es': {
    "tutorialFoodZip": "Ingresa tu código postal aquí para encontrar comida más rápido en tu área.",
    "tutorialFoodDiet": "Especifica tus requisitos dietéticos aquí para que podamos filtrar la comida.",
    "tutorialFoodQuick": "¡Toca aquí rápidamente para pedir! Mantén presionado un favorito para editarlo.",
    "tutorialFoodSearch": "Busca manualmente lo que te apetece y presiona buscar.",
    "tutorialFoodScreenMain": "Pantalla de comida",
    "tutorialFoodScreenDesc": "Explicación de la pantalla de comida"
  },
  'fr': {
    "tutorialFoodZip": "Entrez votre code postal ici pour trouver de la nourriture plus rapidement dans votre région.",
    "tutorialFoodDiet": "Indiquez vos besoins alimentaires ici, afin que nous puissions filtrer la nourriture.",
    "tutorialFoodQuick": "Appuyez ici rapidement pour commander ! Maintenez un favori enfoncé pour le modifier.",
    "tutorialFoodSearch": "Recherchez manuellement ce dont vous avez envie et appuyez sur rechercher.",
    "tutorialFoodScreenMain": "Écran de nourriture",
    "tutorialFoodScreenDesc": "Explication de l'écran de nourriture"
  },
  'tr': {
    "tutorialFoodZip": "Bölgenizde daha hızlı yemek bulmak için posta kodunuzu buraya girin.",
    "tutorialFoodDiet": "Yiyecekleri filtreleyebilmemiz için diyet gereksinimlerinizi buraya girin.",
    "tutorialFoodQuick": "Sipariş vermek için buraya dokunun! Bir favoriyi düzenlemek için basılı tutun.",
    "tutorialFoodSearch": "Canınızın çektiği şeyi manuel olarak arayın ve arabaya basın.",
    "tutorialFoodScreenMain": "Yemek ekranı",
    "tutorialFoodScreenDesc": "Yemek ekranı açıklaması"
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