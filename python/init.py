from googletrans import Translator
import json

arb_loc = "./lib/l10n/intl_{}.arb"

translator = Translator()
langs = ["de", "es", "pt", "fr", "id", "ja", "ko", "ar", "ru", "tr"]
files = ["de_DE", "es_ES", "pt_BR", "fr_FR", "id_ID", "ja", "ko_KR", "ar_EG", "ru_RU", "tr_TR"];

def translate(dest, text):
    try:
        return translator.translate(text, dest).text
    except:
        return text

with open(arb_loc.format("en")) as engFile:
    eng = json.load(engFile)
    for i in range(len(langs)):
        file = files[i]
        dest = langs[i]
        with open(arb_loc.format(file)) as langFile:
            langObj = json.load(langFile)
            for key in eng:
                if key not in langObj:
                    langObj[key] = translate(dest, eng[key])
                    print("{}: {} -> {}".format(dest, key, langObj[key]))
            with open(arb_loc.format(file), 'w') as jsonFile:
                 json.dump(langObj, jsonFile, indent= 4)

