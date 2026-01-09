# Dockerfile pour SAE 3 - Analyse et Diagnostic
# Base image : Ruby officiel (léger)
FROM ruby:3.2-slim

# Métadonnées
LABEL maintainer="Aminobela"
LABEL description="Conteneur pour le projet SAE 3 (Analyse, Réseau, Forensique)"

# Installation des dépendances système nécessaires aux scripts
# - procps : pour ps, top, vmstat, free
# - iproute2 : pour ip, ss
# - sysstat : pour iostat, mpstat, pidstat
# - net-tools : outils réseau classiques (netstat, ifconfig) - optionnel mais utile
# - iotop : pour l'analyse I/O (nécessite privilèges)
# - sudo : pour compatibilité (bien que root par défaut)
# - strace : pour analyse approfondie
# - lsof : pour lister les fichiers ouverts
RUN apt-get update && apt-get install -y \
    bash \
    procps \
    iproute2 \
    sysstat \
    net-tools \
    iotop \
    sudo \
    strace \
    lsof \
    && rm -rf /var/lib/apt/lists/*

# Création du répertoire de travail
WORKDIR /app

# Copie de l'ensemble du projet dans le conteneur
# Note: On suppose que le build se lance depuis la racine du projet pre_sae3
COPY . /app/

# Rendre les scripts exécutables
RUN chmod +x /app/P5_automatisation_conteneurisation/orchestrateur.rb \
    /app/P1_analyse_processeur_performance/*.rb \
    /app/P2_diagnostique_reseau/*.rb \
    /app/P4_diagnostic_système_avancés/*.sh \
    /app/P3_diagnostic_log/*.sh

# Declare a volume for retrieving reports
VOLUME ["/app/P5_automatisation_conteneurisation/rapports_automatises"]

# Définition de l'entrée par défaut
# Lance l'orchestrateur au démarrage du conteneur
ENTRYPOINT ["ruby", "/app/P5_automatisation_conteneurisation/orchestrateur.rb"]
