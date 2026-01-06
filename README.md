# pre_sae3

# 1.2 Méthodologie de diagnostic des scénarios de processus anormaux

Cette section décrit la démarche méthodique utilisée pour diagnostiquer des processus présentant des comportements anormaux. Pour chaque scénario, les outils employés, les commandes utilisées et l’interprétation des résultats sont détaillés.

---

## Scénario 1 : Processus en boucle infinie (CPU élevé)

### Symptômes observés
- Ralentissement général du système
- Ventilateur actif en continu
- Consommation CPU anormalement élevée

### Démarche de diagnostic

1. **Identification du processus consommateur**
```bash
top
```
- Repérage d’un processus utilisant une part excessive du CPU  
- Observation de l’état du processus (`R` : running)

2. **Confirmation via `ps`**
```bash
ps -eo pid,ppid,cmd,%cpu,%mem,state --sort=-%cpu | head
```
- Identification du PID et du processus parent  
- Vérification de la commande exécutée

3. **Analyse de l’arbre des processus**
```bash
pstree -p <PID>
```
- Mise en évidence de la hiérarchie parent/enfant  
- Identification de l’origine du processus

4. **Analyse des appels système**
```bash
strace -p <PID>
```
- Détection de répétitions excessives d’appels système  
- Mise en évidence d’une boucle sans condition de sortie

5. **Inspection via `/proc`**
```bash
cat /proc/<PID>/status
```
- Vérification de l’état, du temps CPU et du nombre de threads

### Conclusion
Le processus est bloqué dans une boucle infinie sans mécanisme de temporisation ou de sortie, entraînant une saturation du CPU.

---

## Scénario 2 : Fuite mémoire (consommation RAM progressive)

### Symptômes observés
- Augmentation continue de la mémoire utilisée  
- Risque de déclenchement du swap ou de l’OOM Killer

### Démarche de diagnostic

1. **Observation globale**
```bash
top
```
- Augmentation progressive de la mémoire résidente (`RES`)

2. **Analyse ciblée**
```bash
ps -p <PID> -o pid,cmd,%mem,rss,vsz
```
- RSS et VSZ en croissance continue

3. **Suivi temporel**
```bash
watch -n 2 "ps -p <PID> -o pid,%mem,rss"
```
- Confirmation de la fuite mémoire dans le temps

4. **Analyse des fichiers ouverts**
```bash
lsof -p <PID>
```
- Détection de fichiers ou sockets non libérés

5. **Analyse mémoire avancée**
```bash
cat /proc/<PID>/smaps
```
- Identification des segments mémoire anormalement volumineux

### Conclusion
Le processus alloue de la mémoire sans la libérer correctement, ce qui correspond à un cas typique de fuite mémoire applicative.

---

## Scénario 3 : Blocage I/O (processus en état `D`)

### Symptômes observés
- Processus figé  
- Insensible aux signaux classiques (`SIGTERM`)  
- Ralentissements liés aux entrées/sorties disque

### Démarche de diagnostic

1. **Identification de l’état bloqué**
```bash
ps -eo pid,cmd,state | grep D
```
- Détection de processus en état `D` (uninterruptible sleep)

2. **Analyse de l’activité disque**
```bash
iotop
```
- Mise en évidence d’une activité I/O bloquante

3. **Inspection des fichiers ouverts**
```bash
lsof -p <PID>
```
- Identification du fichier ou du périphérique concerné

4. **Analyse des appels système**
```bash
strace -p <PID>
```
- Blocage sur un appel `read()` ou `write()`

5. **Consultation des logs noyau**
```bash
dmesg | tail
```
- Détection d’erreurs matérielles ou d’E/S

### Conclusion
Le processus est bloqué sur une opération d’entrée/sortie, généralement causée par un périphérique défaillant ou un système de fichiers indisponible.

---

## Synthèse de la méthodologie

La démarche de diagnostic suivie repose sur les étapes suivantes :

1. Observation globale du système (`top`, `ps`)  
2. Identification ciblée du processus problématique  
3. Analyse de son état et de sa consommation de ressources  
4. Inspection fine via `strace`, `lsof` et le système de fichiers `/proc`  
5. Corrélation des informations avec le contexte système

Cette méthodologie permet d’identifier efficacement les causes profondes de comportements anormaux des processus sous Linux.
