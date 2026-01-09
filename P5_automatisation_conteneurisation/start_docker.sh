#!/bin/bash
# Script de lancement simplifié pour le conteneur SAE 3
# Peut être lancé depuis n'importe où, il se replacera à la racine du projet.

# Détermine la racine du projet (le dossier parent de P5_automatisation_conteneurisation)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Se placer à la racine pour le build Docker
cd "$PROJECT_ROOT" || { echo "Erreur: Impossible d'accéder à la racine du projet"; exit 1; }

IMAGE_NAME="sae3-diagnostic"
# On enregistre les rapports directement dans le dossier du script P5
REPORT_DIR="$SCRIPT_DIR/rapports_automatises"

# Création du dossier de rapports local s'il n'existe pas
mkdir -p "$REPORT_DIR"

echo "Construction de l'image Docker..."
docker build -t "$IMAGE_NAME" -f P5_automatisation_conteneurisation/Dockerfile .

echo "Lancement du conteneur..."
echo "Les rapports seront sauvegardés dans : $REPORT_DIR"

# Lancement avec tous les flags nécessaires
docker run -it --rm \
  --privileged \
  --pid=host \
  --net=host \
  -v "$REPORT_DIR":/app/P5_automatisation_conteneurisation/rapports_automatises \
  "$IMAGE_NAME"
