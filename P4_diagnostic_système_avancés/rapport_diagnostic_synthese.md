# Rapport - Diagnostic système avancé (Partie 4)

### 1. Tableau de bord système (`tableau_de_bord.sh`)

**Fonctionnalités :**
- **Double format de sortie** : Génère par défaut un rapport HTML stylisé, lisible dans n'importe quel navigateur, mais peut aussi produire un rapport texte brut pour les terminaux.
- **Vérification des dépendances** : S'assure que les paquets nécessaires (`sysstat`, `iotop`) sont installés avant de se lancer.
- **Données collectées** :
    - **CPU** : Utilisation par cœur via `mpstat`.
    - **Mémoire** : Usage RAM et Swap via `vmstat`.
    - **Disque** : Statistiques d'I/O (débit/latence) via `iostat` et top processus consommateurs via `iotop`.
    - **Historique** : Charge système et mémoire récente via `sar`.
    - **Noyau** : Dernières alertes critiques via `dmesg`.
    - **Démarrage** : Temps de boot via `systemd-analyze`.

**Utilisation :**
```bash
sudo ./tableau_de_bord.sh          # Génère un dashboard HTML
sudo ./tableau_de_bord.sh --text   # Génère un rapport texte
```

### 2. Simulation de charge (`simulation_charge.sh`)

**Fonctionnement :**
- **CPU Stress** : Lance des calculs de hash (`sha256sum`) en parallèle sur tous les cœurs disponibles.
- **Disk Stress** : Écrit des données aléatoires sur le disque en boucle pour saturer les I/O.
- **Memory Stress** : Alloue un bloc de mémoire (via Python) pour simuler une pression RAM.

**Utilisation :**
```bash
sudo ./simulation_charge.sh
```
*Le script tourne pendant 60 secondes par défaut.*

## Exemple d'analyse

Dans un scénario typique d'investigation :
1.  Lancer `simulation_charge.sh`.
2.  Pendant la charge, exécute `tableau_de_bord.sh`.
3.  Le rapport révèle instantanément :
    - Une charge CPU proche de 100% (confirmée par `mpstat`).
    - Un débit d'écriture disque élevé (visible dans `iostat` et `iotop`).
    - Une augmentation de la charge système (`load average`).
