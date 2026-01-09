
# SAE 3 - Analyse forensique et débogage système

## Structure globale

### P1_analyse_processeur_performance
*Focus : Compréhension des processus et de l'usage CPU/RAM.*

- **`boucle_infinie.rb`** : Script simulant une charge CPU bloquante (100% usage) pour tester les outils de monitoring (`top`, `htop`).
- **`fuite_memoire.rb`** : Script allouant de la RAM sans libération pour simuler une fuite mémoire et tester la détection OOM (Out of Memory).
- **`blocage_IO.rb`** : Script générant des écritures disques intensives pour bloquer les I/O et tester l'état de processus "D" (Disk Sleep).
- **`rapport_analyse.rb`** : Outil en Ruby qui inspecte le système (`/proc`) pour sortir un rapport détaillé sur l'état des processus.
- **`rapport_analyse_proc.md`** : Documentation méthodologique expliquant comment diagnostiquer ces anomalies manuellement.

### P2_diagnostique_reseau
*Focus : Audit et dépannage de la connectivité réseau.*

- **`audit_reseau.rb`** : Scanner automatisé qui liste les ports ouverts, détecte les connexions suspectes hors standards (Web/SSH) et affiche la config IP/Routes.
- **`latence_eleve.rb`** : Outil utilisant `tc` (Traffic Control) pour injecter artificiellement de la latence (ping élevé) sur l'interface réseau.
- **`scenario_parefeu.rb`** : Simule un blocage de port (ex: 80) via `iptables` pour tester les diagnostics de connectivité.
- **`scenario_dns_casse.rb`** : Modifie temporairement `/etc/resolv.conf` pour simuler une panne de résolution de noms.
- **`rapport_diagnostic_guide.md`** : Guide complet des commandes (`ping`, `mtr`, `ss`, `dig`) pour résoudre ces incidents.

### P3_diagnostic_log
*Focus : Investigation post-incident et analyse de logs.*

- **`scenario_intrusion_ssh.sh`** : Génère des tentatives de connexion SSH échouées en masse pour "polluer" les logs d'authentification (`auth.log`).
- **`scenario_saturation_disque.sh`** : Remplit un espace disque temporaire pour provoquer et logger des erreurs "No space left on device".
- **`analyse_log.sh`** : Script Bash utilisant `grep`, `awk` et `journalctl` pour extraire automatiquement les traces suspectes (Auth failed, erreurs noyau).
- **`rapport_investigation_forensique.md`** : Rapport type expliquant la méthodologie d'enquête sur les deux scénarios ci-dessus.

### P4_diagnostic_système_avancés
*Focus : Monitoring temps réel et charge.*

- **`tableau_de_bord.sh`** : Dashboard complet générant un rapport HTML (ou texte) avec l'état CPU, RAM, Disque, I/O et les logs noyau critiques. Vérifie ses dépendances au lancement.
- **`simulation_charge.sh`** : Outil de stress-test générant simultanément de la charge CPU, Disque et Mémoire pour valider la réactivité du tableau de bord.
- **`rapport_diagnostic_synthese.md`** : Documentation technique du tableau de bord et du stress-test.
- 
### P5_automatisation_conteneurisation
*Focus : Unification et déploiement.*

- **`orchestrateur.rb`** : Interface centrale (CLI) permettant de lancer n'importe quel outil des parties P1 à P4 depuis un menu unique. Agrège aussi les résultats.
- **`Dockerfile`** : Recette pour construire une image Docker autonome contenant tout l'environnement et les outils du projet, prête à être déployée sur n'importe quel serveur Linux.
- **`rapport_automatisation.md`** : Documentation finale sur l'architecture de l'orchestrateur et la stratégie de conteneurisation.
