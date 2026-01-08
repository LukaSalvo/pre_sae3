# Analyse de logs et investigation post-incident

Ce document présente deux scénarios d’incident système simulés ainsi que leur investigation forensique.
Chaque scénario est reproductible à l’aide de scripts Bash et analysé à partir des journaux système Linux.

---

## Scénario 1 : Tentative d’intrusion SSH

### Contexte

Une tentative d’intrusion est simulée par l’envoi de multiples connexions SSH échouées vers un compte utilisateur local.
L’objectif est de générer des traces d’authentification afin de mener une analyse forensique réaliste.

Script utilisé :
```bash
scenario_intrusion_ssh.sh
```

---

### Méthodologie d’investigation

Les tentatives d’authentification sont générées localement afin de produire des traces contrôlées et reproductibles.


1. **Analyse des journaux d’authentification**
```bash
sudo grep "Failed password" /var/log/auth.log
```

2. **Analyse via systemd**
```bash
sudo journalctl -u ssh --since "10 min ago"
```

3. **Vérification des connexions utilisateurs**
```bash
last
who
w
```

4. **Extraction et corrélation des adresses IP**
```bash
sudo grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}'
```

---

### Découvertes

- Présence de nombreuses tentatives SSH échouées
- Ciblage répété du même compte utilisateur local 
- Activité clairement identifiable dans les logs système
- Aucune authentification réussie ni élévation de privilèges observée

---

### Chronologie de l’incident

| Heure approximative | Événement |
|--------------------|----------|
| T0 | Lancement du script de simulation |
| T0 + quelques secondes | Tentatives SSH échouées |
| T0 + 1 minute | Fin des tentatives |

---

### Traces laissées

- `/var/log/auth.log`
- Journaux systemd du service SSH
- Historique des connexions utilisateurs

---

### Recommandations

- Désactiver l’authentification par mot de passe
- Utiliser uniquement l’authentification par clé SSH
- Mettre en place un mécanisme de bannissement automatique (Fail2ban)
- Surveiller régulièrement les logs d’authentification

---

## Scénario 2 : Saturation disque simulée

### Contexte

Une saturation volontaire de l’espace disque est simulée afin de provoquer des erreurs d’écriture.
Ce scénario permet d’analyser les réactions du système et les traces laissées dans les journaux.

Script utilisé :
```bash
scenario_saturation_disque.sh
```

---

### Méthodologie d’investigation

Selon la taille du disque disponible, la saturation peut être partielle ou complète.


1. **Vérification de l’espace disque**
```bash
df -h
```

2. **Analyse des messages noyau**
```bash
dmesg | tail -n 50
```

3. **Analyse des journaux systemd**
```bash
sudo journalctl --since "10 min ago" | grep -i "no space"
```

4. **Analyse des fichiers générés**
```bash
ls -lh /tmp/diskfill_demo
```

---

### Découvertes

- Remplissage progressif de l’espace disque
- Tentatives d’écriture pouvant échouer en cas de saturation
- Apparition possible de messages système indiquant un manque d’espace disque
- Risque de dysfonctionnement des services applicatifs

---

### Chronologie de l’incident

| Heure approximative | Événement |
|--------------------|----------|
| T0 | Lancement du script |
| T0 + quelques secondes | Augmentation rapide de l’espace utilisé |
| T0 + 1 minute | Erreurs d’écriture détectées |
| T0 + 2 minutes | Fin de la simulation |

---

### Traces laissées

- Messages noyau (`dmesg`)
- Journaux systemd
- Fichiers temporaires volumineux

---

### Recommandations

- Mettre en place une surveillance de l’espace disque
- Configurer des alertes de seuil critique
- Nettoyer régulièrement les fichiers temporaires
- Limiter la taille des logs applicatifs

---





