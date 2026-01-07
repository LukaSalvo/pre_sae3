# SAE 3 - Analyse Forensique et Débogage Système

Ce dépôt contient les ressources pour la SAE 3 "Analyse forensique et débogage système".

## Structure du Projet

- `analyse_processeur_performance/` : Partie 1 (Analyse processus et performances)
- `diagnostique_reseau/` : Partie 2 (Diagnostic réseau)

## Partie 2 : Diagnostic Réseau

Cette partie contient des outils et scénarios pour diagnostiquer des problèmes réseaux, implémentés en **Ruby**.

### Prérequis
- Ruby interactif (`irb`, `ruby`)
- Droits `sudo` pour les scénarios de panne (manipulation `iptables`, `tc`).
- Outils systèmes : `ss`, `ip`, `tc`, `iptables`.

### Outils Disponibles

Tous les scripts se trouvent dans le dossier `diagnostique_reseau/`.

1.  **Audit Automatisé**
    *   Fichier : `audit_reseau.rb`
    *   Description : Analyse les ports ouverts, les connexions suspectes et la configuration réseau.
    *   Usage : `./audit_reseau.rb`

2.  **Simulation de Latence**
    *   Fichier : `latence_eleve.rb`
    *   Description : Ajoute 500ms de latence sur l'interface réseau via `netem`.
    *   Usage : `sudo ./latence_eleve.rb start` (Activer) / `sudo ./latence_eleve.rb stop` (Désactiver)

3.  **Simulation de Pare-Feu Bloquant**
    *   Fichier : `scenario_parefeu.rb`
    *   Description : Bloque le port 80 (HTTP) via `iptables`.
    *   Usage : `sudo ./scenario_parefeu.rb start` (Bloquer) / `sudo ./scenario_parefeu.rb stop` (Débloquer)

4.  **Simulation de Panne DNS**
    *   Fichier : `scenario_dns_casse.rb`
    *   Description : Simule une panne DNS en modifiant `/etc/resolv.conf`.
    *   Usage : `sudo ./scenario_dns_casse.rb start` (Casser) / `sudo ./scenario_dns_casse.rb stop` (Réparer)

### Documentation
Voir `diagnostique_reseau/diagnostic_guide.md` pour le guide complet de diagnostic.
