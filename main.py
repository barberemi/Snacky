from fastapi import FastAPI
from duckduckgo_search import DDGS
from openai import OpenAI
import json
import uuid
from datetime import datetime, timezone

app = FastAPI()

# Remplace par ta clé API OpenAI
client = OpenAI(api_key="TON_API_KEY")

@app.get("/news")
def get_smart_news(topic: str, user_id: str):
    # 1. Recherche sur DuckDuckGo
    results = []
    with DDGS() as ddgs:
        for r in ddgs.news(topic, max_results=10):
            results.append({
                "title": r.get("title", ""),
                "body": r.get("body", ""),
                "url": r.get("url", ""),
                "source": r.get("source", ""),
                "image": r.get("image", None),
                "date": r.get("date", ""),
            })

    fetched_at = datetime.now(timezone.utc).isoformat()

    # 2. Prompt amélioré
    prompt = f"""
Tu es un curateur de veille technologique et culturelle expert.
On te donne une liste de résultats bruts issus d'une recherche sur le sujet : "{topic}".

Ta mission :
1. Analyse et dédoublonne les résultats (si deux articles parlent du même événement, garde le plus complet).
2. Pour chaque article retenu, synthétise les informations en français.
3. Retourne un JSON valide avec UNIQUEMENT le tableau "articles".

Contraintes strictes :
- "id" : un identifiant unique sous la forme "{topic.lower().replace(" ", "_")}_<numéro>" (ex: "batman_1")
- "title" : titre clair et synthétique en français (max 80 caractères)
- "source" : nom du site source (ex: "Le Monde", "TechCrunch"), extrait de l'URL si absent
- "time" : temps écoulé depuis la publication en français (ex: "2h", "1j", "3j") — déduis-le depuis le champ "date"
- "description" : résumé neutre et informatif en 2-3 phrases en français
- "url" : URL originale de l'article, non modifiée
- "image" : URL de l'image si disponible, sinon null
- "tags" : liste de tags pertinents parmi ceux fournis (inclure "{topic}" obligatoirement)
- "fetchedAt" : utilise exactement cette valeur ISO 8601 : "{fetched_at}"

Format de sortie attendu (JSON strict, aucun texte en dehors) :
{{
  "articles": [
    {{
      "id": "string",
      "title": "string",
      "source": "string",
      "time": "string",
      "description": "string",
      "url": "string",
      "image": "string ou null",
      "tags": ["string"],
      "fetchedAt": "string"
    }}
  ]
}}

Données brutes à analyser :
{json.dumps(results, ensure_ascii=False, indent=2)}
"""

    # 3. Appel à l'IA
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": prompt}],
        response_format={"type": "json_object"},
        temperature=0.3,  # Moins créatif, plus factuel
    )

    return json.loads(response.choices[0].message.content)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)