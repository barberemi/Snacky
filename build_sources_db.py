"""
build_sources_db.py
───────────────────
Construit un dictionnaire de fiabilité des sources en combinant :
  1. Le dataset MBFC (Media Bias / Fact Check) via le repo GitHub communautaire
  2. Le dataset OpenSources.co (sources fiables / fake / satire…)
  3. Ta liste statique TRUSTED_SOURCES (prioritaire sur tout)

Résultat : un fichier `sources_db.json` utilisé par main.py au démarrage.

Usage :
    python build_sources_db.py

À relancer périodiquement (ex: cron hebdomadaire) pour mettre à jour les données.
"""

import json
import re
import requests
from urllib.parse import urlparse

# ─── 1. Tes sources statiques (priorité maximale) ────────────────────────────
STATIC_SOURCES = {
    # Presse tech internationale
    "techcrunch.com": "high", "theverge.com": "high", "wired.com": "high",
    "arstechnica.com": "high", "zdnet.com": "high", "venturebeat.com": "high",
    # Presse française
    "lemonde.fr": "high", "lefigaro.fr": "high", "liberation.fr": "high",
    "20minutes.fr": "high", "leparisien.fr": "high", "lexpress.fr": "high",
    "lepoint.fr": "high", "nouvelobs.com": "high", "mediapart.fr": "high",
    "numerama.com": "high", "01net.com": "high", "presse-citron.net": "medium",
    "journaldugeek.com": "medium", "frandroid.com": "medium",
    # Dev / Tech
    "github.com": "high", "stackoverflow.com": "high",
    "flutter.dev": "high", "dart.dev": "high", "php.net": "high",
    "rust-lang.org": "high", "python.org": "high", "mozilla.org": "high",
    "dev.to": "medium", "medium.com": "medium", "hashnode.com": "medium",
    # Jeux / Culture
    "gamekult.com": "high", "jeuxvideo.com": "high", "ign.com": "high",
    "allocine.fr": "medium", "dccomics.com": "high", "marvel.com": "high",
    "polygon.com": "high", "kotaku.com": "medium",
    # Presse généraliste internationale
    "euronews.com": "high", "bbc.com": "high", "bbc.co.uk": "high",
    "reuters.com": "high", "apnews.com": "high", "afp.com": "high",
    "theguardian.com": "high", "nytimes.com": "high", "ft.com": "high",
    "bloomberg.com": "high", "economist.com": "high", "time.com": "high",
    "forbes.com": "medium",  # Fiable mais contenu sponsorisé fréquent
}

# ─── Mapping MBFC factualité → notre score ───────────────────────────────────
MBFC_FACTUALITY_MAP = {
    "very high": "high",
    "high": "high",
    "mostly factual": "medium",
    "mixed": "medium",
    "low": "low",
    "very low": "low",
    "false": "low",
}

# ─── Mapping OpenSources type → notre score ──────────────────────────────────
OPENSOURCES_TYPE_MAP = {
    "reliable": "high",
    "credible": "high",
    "analysis": "medium",
    "bias": "medium",
    "pro-science": "high",
    "political": "medium",
    "fake": "low",
    "conspiracy": "low",
    "satire": "low",
    "unreliable": "low",
    "hate": "low",
    "rumor": "low",
}


def normalize_domain(raw: str) -> str:
    """Extrait et normalise un domaine (supprime www., http, etc.)"""
    raw = raw.strip().lower()
    if raw.startswith("http"):
        raw = urlparse(raw).netloc
    return raw.replace("www.", "").strip("/")


def fetch_mbfc_dataset() -> dict[str, str]:
    """
    Télécharge le dataset MBFC depuis le repo GitHub communautaire
    mbedded-ninja/news-source-credibility qui maintient un CSV structuré.
    """
    print("📥 Téléchargement du dataset MBFC...")
    url = "https://raw.githubusercontent.com/mbedded-ninja/news-source-credibility/main/data/sources.csv"
    try:
        r = requests.get(url, timeout=15)
        r.raise_for_status()
    except Exception as e:
        print(f"  ⚠️  MBFC non disponible : {e}")
        return {}

    sources = {}
    lines = r.text.strip().splitlines()
    # Format attendu : name,url,factual_reporting,bias,...
    header = [h.strip().lower() for h in lines[0].split(",")]

    url_idx = next((i for i, h in enumerate(header) if "url" in h), None)
    fact_idx = next((i for i, h in enumerate(header) if "factual" in h), None)

    if url_idx is None or fact_idx is None:
        print("  ⚠️  Format CSV MBFC inattendu, colonnes non trouvées")
        return {}

    for line in lines[1:]:
        cols = line.split(",")
        if len(cols) <= max(url_idx, fact_idx):
            continue
        domain = normalize_domain(cols[url_idx])
        factuality = cols[fact_idx].strip().lower().strip('"')
        score = MBFC_FACTUALITY_MAP.get(factuality)
        if domain and score:
            sources[domain] = score

    print(f"  ✅ {len(sources)} sources MBFC chargées")
    return sources


def fetch_opensources_dataset() -> dict[str, str]:
    """
    Télécharge le dataset OpenSources.co depuis GitHub.
    """
    print("📥 Téléchargement du dataset OpenSources.co...")
    url = "https://raw.githubusercontent.com/BigMcLargeHuge/opensources/master/sources/sources.json"
    try:
        r = requests.get(url, timeout=15)
        r.raise_for_status()
        data = r.json()
    except Exception as e:
        print(f"  ⚠️  OpenSources non disponible : {e}")
        return {}

    sources = {}
    for domain, info in data.items():
        normalized = normalize_domain(domain)
        # Le champ "type" est une liste dans ce dataset
        types = info.get("type", [])
        if isinstance(types, str):
            types = [types]
        # On prend le type le plus sévère (low > medium > high)
        score = None
        for t in types:
            mapped = OPENSOURCES_TYPE_MAP.get(t.lower())
            if mapped == "low":
                score = "low"
                break
            elif mapped == "medium" and score != "low":
                score = "medium"
            elif mapped == "high" and score is None:
                score = "high"
        if normalized and score:
            sources[normalized] = score

    print(f"  ✅ {len(sources)} sources OpenSources chargées")
    return sources


def build_database() -> dict[str, str]:
    """
    Fusionne les sources dans l'ordre de priorité :
    STATIC (prioritaire) > MBFC > OpenSources
    """
    # Sources les moins prioritaires en premier (seront écrasées)
    db: dict[str, str] = {}

    opensources = fetch_opensources_dataset()
    db.update(opensources)

    mbfc = fetch_mbfc_dataset()
    db.update(mbfc)  # MBFC écrase OpenSources si conflit

    db.update(STATIC_SOURCES)  # Statiques écrasent tout

    return db


if __name__ == "__main__":
    print("\n🔨 Construction de la base de sources...\n")
    db = build_database()
    output_path = "sources_db.json"
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(db, f, ensure_ascii=False, indent=2, sort_keys=True)

    # Stats
    counts = {"high": 0, "medium": 0, "low": 0}
    for v in db.values():
        if v in counts:
            counts[v] += 1

    print(f"\n✅ Base construite : {len(db)} sources → {output_path}")
    print(f"   🟢 high   : {counts['high']}")
    print(f"   🟠 medium : {counts['medium']}")
    print(f"   🔴 low    : {counts['low']}")
