# Analyse de logs et investigation post-incident

Ce document présente l'analyse forensique de deux incidents simulés : une tentative d'intrusion SSH et une saturation disque.

---

## Scénario 1 : Tentative d’intrusion SSH (Brute-force)

### 1. Contexte
Une série de tentatives de connexion SSH échouées a été détectée sur le serveur. L'activité semble provenir d'une simulation locale visant à tester les capacités de détection du système.
**Script utilisé :** `scenario_intrusion_ssh.sh`

### 2. Méthodologie d’investigation
L'investigation repose sur l'analyse des journaux du service SSH via `systemd`.

**Commandes utilisées :**
1.  **Recherche des échecs d'authentification :**
    ```bash
    sudo journalctl -u ssh | grep "Failed password"
    ```
2.  **Analyse temporelle (10 dernières minutes) :**
    ```bash
    sudo journalctl -u ssh --since "10 min ago"
    ```
3.  **Vérification des accès réussis (pour exclure une compromission) :**
    ```bash
    sudo journalctl -u ssh | grep "Accepted parent"
    ```

### 3. Découvertes
- **Nature de l'attaque :** Attaque par dictionnaire (brute-force) simulée.
- **Vecteur :** Connexions SSH sur le port 22.
- **Cible :** L'utilisateur courant (`aminobela` ou variable `$USER`).
- **Technique observée :** Utilisation de `SSH_ASKPASS` pour forcer l'envoi de mots de passe incorrects sans interaction utilisateur (automatisé par script).
- **Résultat :** Au moins 10 tentatives échouées consécutives. Aucune intrusion réussie détectée durant cette fenêtre.

### 4. Chronologie de l’incident

| Timestamp (Relatif) | Événement | Source |
|-------------------|-----------|--------|
| T0 | Début de l'exécution du script d'attaque | Shell |
| T0 + 1s | Première tentative connexion échouée | `sshd[PID]: Failed password for...` |
| T0 + 2s | Seconde tentative échouée | `sshd[PID]: Failed password...` |
| ... | Répétition des échecs | |
| T0 + 4s | Fin de l'attaque simulée | Shell |

### 5. Recommandations
- **Durcissement SSH :** Désactiver l'authentification par mot de passe (`PasswordAuthentication no`) au profit des clés publiques.
- **Défense active :** Installer et configurer `Fail2ban` pour bannir les IP après 3-5 échecs.
- **Surveillance :** Mettre en place une alerte centralisée sur les patterns "Failed password".

---

## Scénario 2 : Saturation disque (Déni de service)

### 1. Contexte
Le système a montré des signes d'instabilité. Une investigation est menée pour identifier une potentielle saturation des ressources de stockage.
**Script utilisé :** `scenario_saturation_disque.sh`

### 2. Méthodologie d’investigation
L'analyse se concentre sur l'espace disque et les erreurs d'écriture dans les journaux noyau et applicatifs.

**Commandes utilisées :**
1.  **Vérification de l'occupation :**
    ```bash
    df -h
    ```
2.  **Recherche d'erreurs d'I/O dans le journal système :**
    ```bash
    sudo journalctl | grep -iE "no space|disk|write error"
    ```
3.  **Inspection des messages noyau :**
    ```bash
    dmesg | tail -n 50
    ```

### 3. Découvertes
- **Source du problème :** Un fichier volumineux `fill.bin` a été créé rapidement dans `/tmp/diskfill_demo`.
- **Impact :** Le système de fichiers hôte (ou la partition `/tmp`) a atteint un seuil critique d'occupation.
- **Conséquences :** Des écritures applicatives simulées (`app.log`) ont échoué, générant des erreurs "No space left on device" ou des fichiers tronqués.

### 4. Chronologie de l’incident

| Timestamp (Relatif) | Événement | Détails |
|-------------------|-----------|---------|
| T0 | Création du répertoire temporaire | `/tmp/diskfill_demo` |
| T0 + 1s | Lancement de `dd` | Écriture de blocs de zéros (`/dev/zero`) |
| T0 + 5s | Remplissage progressif | Occupation disque en hausse rapide |
| T0 + 10s | Saturation atteinte (simulée) | Erreurs d'écriture dans les logs applicatifs |
| T0 + 15s | Fin de l'incident | Arrêt du script |

### 5. Recommandations
- **Partitionnement :** Séparer `/var` et `/tmp` sur des partitions distinctes pour éviter qu'un log ou un fichier temporaire ne sature la racine `/`.
- **Monitoring :** Configurer des alertes (Nagios/Zabbix) quand l'espace disque dépasse 90%.
- **Quotas :** Mettre en place des quotas disques pour les utilisateurs ou les services critiques.
