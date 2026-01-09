# Rapport - Automatisation et conteneurisation (Partie 5)

## Introduction

Cette dernière partie vise à unifier l'ensemble des outils développés dans les parties précédentes (P1 à P4) au sein d'une interface commune, et à rendre le déploiement de cette suite d'outils trivial grâce à la conteneurisation.

## Architecture

Le code source se trouve dans `P5_automatisation_conteneurisation/`.

### 1. Orchestrateur (`orchestrateur.rb`)

L'orchestrateur est un script Ruby agissant comme point d'entrée unique. Il remplace l'exécution manuelle de scripts dispersés.

**Caractéristiques principales :**
- **Menu interactif** : Propose une interface texte simple pour lancer les différents modules (Analyse processus, Audit réseau, Tableau de bord système).
- **Mode "Audit Complet"** : Capable de lancer tous les outils à la suite et d'agréger leurs sorties dans un fichier de rapport global unique.
- **Gestion des privilèges** : Détecte si l'utilisateur n'est pas root et l'avertit (car beaucoup de sondes nécessitent des droits élevés).
- **Modularité** : Le script est conçu avec des constantes de chemin, facilitant la maintenance si l'arborescence du projet change.

**Utilisation :**
```bash
sudo ruby orchestrateur.rb
```

### 2. Conteneurisation (`Dockerfile`)

Le fichier `Dockerfile` permet de construire une image "clé en main" contenant tous les scripts et leurs dépendances.

**Choix techniques :**
- **Base image** : `ruby:3.2-slim` pour sa légèreté tout en disposant de l'interpréteur Ruby natif.
- **Installation des outils** : Le Dockerfile installe automatiquement les paquets systèmes requis par les scripts Bash (`procps`, `iproute2`, `sysstat`, `iotop`, `net-tools`, etc.), résolvant ainsi le problème des dépendances manquantes sur la machine hôte.
- **Contexte** : Le conteneur copie l'intégralité du projet et rend les scripts exécutables automatiquement.
- **Point d'entrée** : Lance directement l'orchestrateur au démarrage.

**Déploiement :**
```bash
# Lancement simplifié
Il suffit d'exécuter le script `start_docker.sh` situé dans le dossier P5 :

```bash
./P5_automatisation_conteneurisation/start_docker.sh
```

Ce script s'occupe de tout (construction, volumes, privilèges).


## Conclusion du projet

L'orchestrateur et le conteneur Docker représentent l'aboutissement du projet. Ils transforment une collection de scripts de diagnostic individuels en une véritable "trousse à outils" portable, robuste et simple d'utilisation pour l'administrateur système.
