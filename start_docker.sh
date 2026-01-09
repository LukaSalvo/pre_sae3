#!/bin/bash
# Script de lancement simplifié pour le conteneur SAE 3

# Nom de l'image
IMAGE_NAME="sae3-diagnostic"

# Création du dossier de rapports local s'il n'existe pas
mkdir -p ./rapports

echo "Construction de l'image Docker..."
docker build -t "$IMAGE_NAME" -f P5_automatisation_conteneurisation/Dockerfile .

echo "Lancement du conteneur..."
echo "Les rapports seront sauvegardés dans : $(pwd)/rapports"

# Lancement avec tous les flags nécessaires
# --privileged : accès total au matériel
# --pid=host : voir les processus de l'hôte
# --net=host : voir le réseau de l'hôte
# -v ... : montage du volume pour récupérer les rapports
docker run -it --rm \
  --privileged \
  --pid=host \
  --net=host \
  -v "$(pwd)/rapports":/app/P5_automatisation_conteneurisation/rapports_automatises \
  "$IMAGE_NAME"
