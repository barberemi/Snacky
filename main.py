from fastapi import FastAPI
from duckduckgo_search import DDGS
from openai import OpenAI
import json
from datetime import datetime, timezone
from urllib.parse import urlparse

app = FastAPI()

client = OpenAI(api_key="TON_API_KEY")

# ─── Liste statique de fiabilité des sources ─────────────────────────────────
# Score de base : HIGH (source reconnue), MEDIUM (blog/communauté), LOW (inconnu)
TRUSTED_SOURCES = {
    # Presse tech internationale
    "techcrunch.com": "high", "theverge.com": "high", "wired.com": "high",
    "arstechnica.com": "high", "zdnet.com": "high", "venturebeat.com": "high",
    # Presse française
    "lemonde.fr": "high", "lefigaro.fr": "high", "liberation.fr": "high",
    "20minutes.fr": "high", "leparisien.fr": "high",
    "numerama.com": "high", "01net.com": "high", "presse-citron.net": "medium",
    # Dev / Tech
    "github.com": "high", "stackoverflow.com": "high",
    "flutter.dev": "high", "dart.dev": "high", "php.net": "high",
    "rust-lang.org": "high", "python.org": "high", "mozilla.org": "high",
    "dev.to": "medium", "medium.com": "medium", "hashnode.com": "medium",
    # Jeux / Culture
    "gamekult.com": "high", "jeuxvideo.com": "high", "ign.com": "high",
    "allocine.fr": "medium", "dccomics.com": "high", "marvel.com": "high",
}

def get_domain_score(url: str) -> str:
    """Retourne le score de base selon le domaine de l'URL."""
    try:
        domain = urlparse(url).netloc.replace("www.", "")
        return TRUSTED_SOURCES.get(domain, "unknown")
    except Exception:
        return "unknown"


@app.get("/news")
def get_smart_news(topic: str, user_id: str):
    # 1. Recherche DuckDuckGo
    results = []
    with DDGS() as ddgs:
        for r in ddgs.news(topic, max_results=10):
            url = r.get("url", "")
            results.append({
                "title": r.get("title", ""),
                "body": r.get("body", ""),
                "url": url,
                "source": r.get("source", ""),
                "image": r.get("image", None),
                "date": r.get("date", ""),
                # Score de domaine pré-calculé, envoyé à l'IA pour l'aider
                "domain_trust": get_domain_score(url),
            })

    fetched_at = datetime.now(timezone.utc).isoformat()
    topic_slug = topic.lower().replace(" ", "_")

    # 2. Prompt avec calcul de confiance
    prompt = f"""
Tu es un curateur de veille expert et un fact-checker rigoureux.
On te donne des résultats bruts d'une recherche sur : "{topic}".

Chaque résultat contient un champ "domain_trust" (high/medium/unknown) qui indique
la réputation connue du domaine source. Utilise-le comme point de départ.

Ta mission :
1. Dédoublonne (si plusieurs articles couvrent le même événement, garde le plus complet
   et note combien de sources concordantes tu as trouvé).
2. Pour chaque article retenu, synthétise en français et calcule un score de confiance.

Calcul du score "confidence" (retourne "high", "medium" ou "low") :
- Commence depuis domain_trust (high=70pts, medium=40pts, unknown=20pts)
- +15 pts si plusieurs sources différentes couvrent le même fait
- +10 pts si l'article est factuel (dates, chiffres, citations directes)
- -20 pts si le ton est sensationnaliste (titres en majuscules, "CHOC", "INCROYABLE"...)
- -15 pts si c'est une opinion/editorial sans faits vérifiables
- -10 pts si source unique sans recoupement possible
- HIGH si score >= 70, MEDIUM si 40-69, LOW si < 40

"confidenceReason" : 1 phrase courte expliquant le score (ex: "Source officielle, recoupé par 3 médias")

Contraintes des champs :
- "id" : "{topic_slug}_<numéro>" (ex: "{topic_slug}_1")
- "title" : titre synthétique en français (max 80 caractères)
- "source" : nom lisible du site (ex: "TechCrunch", "Le Monde")
- "time" : temps écoulé en français depuis "date" (ex: "2h", "1j", "3j")
- "description" : résumé factuel en 2-3 phrases en français
- "url" : URL originale non modifiée
- "image" : URL image ou null
- "tags" : inclure "{topic}" obligatoirement + tags pertinents
- "fetchedAt" : "{fetched_at}" (valeur exacte, ne pas modifier)
- "confidence" : "high" | "medium" | "low"
- "confidenceReason" : string court (max 80 caractères)

Format JSON strict (aucun texte en dehors) :
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
      "fetchedAt": "string",
      "confidence": "high|medium|low",
      "confidenceReason": "string"
    }}
  ]
}}

Données brutes :
{json.dumps(results, ensure_ascii=False, indent=2)}
"""

    # 3. Appel IA
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": prompt}],
        response_format={"type": "json_object"},
        temperature=0.2,
    )

    return json.loads(response.choices[0].message.content)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)