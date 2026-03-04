# snacky

Application de veille journalière, avec indice de confiance.

## Getting Started

1 - Générer / Mettre à jour la base des sites de confiance (à relancer periodiquement)
> python3 build_sources_db.py

2 - Lancer le serveur
> uvicorn main:app --host 0.0.0.0 --port 8000