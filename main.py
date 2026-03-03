from fastapi import FastAPI
from duckduckgo_search import DDGS
from openai import OpenAI
import json

app = FastAPI()

# Remplace par ta clé API OpenAI
client = OpenAI(api_key="TON_API_KEY")

@app.get("/news")
def get_smart_news(topic: str):
    # 1. Recherche sur DuckDuckGo
    results = []
    with DDGS() as ddgs:
        # On récupère les 8 derniers résultats d'actualité
        for r in ddgs.news(topic, max_results=8):
            results.append({
                "title": r['title'],
                "body": r['body'],
                "url": r['url']
            })

    # 2. Préparation du Prompt pour l'IA
    prompt = f"""
    Tu es un curateur expert. Analyse ces news sur '{topic}' et organise-les.
    Regroupe les doublons et crée un JSON structuré.
    
    Format attendu :
    {{
      "news": [
        {{
          "title": "Titre synthétique",
          "summary": "Résumé en 2 phrases",
          "category": "Cinéma|Comics|Jeux Vidéo|Autre",
          "url": "Lien source"
        }}
      ]
    }}

    Données brutes : {json.dumps(results)}
    """

    # 3. Appel à l'IA pour le tri
    response = client.chat.completions.create(
        model="gpt-4o-mini", # Modèle rapide et peu coûteux
        messages=[{"role": "user", "content": prompt}],
        response_format={ "type": "json_object" }
    )

    return json.loads(response.choices[0].message.content)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)