# Documentation - Analyse de Processus et Performances

## Scénarios de test créés

### 1. Boucle infinie (CPU)
**Fichier:** `boucle_infinie.rb`

**Description:** Simule un processus qui consomme 100% d'un cœur CPU.

**Lancement:**
```bash
ruby analyse_processeur_performance/boucle_infinie.rb
```

**Diagnostic:**
```bash

ps aux | grep ruby
top -p <PID>  

htop  


pstree -p | grep ruby


sudo strace -p <PID> -c  
sudo strace -p <PID>     

cat /proc/<PID>/stat     
cat /proc/<PID>/status   
```

**Observations attendues:**
- État: R (Running)
- CPU: ~100% d'un cœur
- Pas d'I/O significatif

---

### 2. Fuite mémoire
**Fichier:** `fuite_memoire.rb`

**Description:** Alloue de la mémoire continuellement sans la libérer.

**Lancement:**
```bash
ruby analyse_processeur_performance/fuite_memoire.rb
```

**Diagnostic:**
```bash
# Surveiller la mémoire en temps réel
top -p <PID>
watch -n 1 "ps aux | grep <PID>"

# Analyse détaillée de la mémoire
cat /proc/<PID>/status | grep -E "VmSize|VmRSS|VmData"
pmap -x <PID>  # Cartographie mémoire

# Voir les allocations
sudo strace -p <PID> -e trace=brk,mmap

# Fichiers ouverts (pour vérifier pas de fuite de descripteurs)
lsof -p <PID>
ls -l /proc/<PID>/fd/
```

**Observations attendues:**
- VmRSS augmente régulièrement
- Mémoire ne se stabilise jamais
- Risque de OOM (Out Of Memory)

---

### 3. Blocage I/O
**Fichier:** `blocage_IO.rb`

**Description:** Écrit continuellement sur le disque avec fsync.

**Lancement:**
```bash
ruby analyse_processeur_performance/blocage_IO.rb
```

**Diagnostic:**
```bash
# Identifier l'activité I/O
sudo iotop  # Processus avec I/O disque élevé
iostat -x 1  # Statistiques I/O globales

# État du processus
ps aux | grep ruby
# Chercher l'état D (Disk sleep) pendant les écritures

# Fichiers ouverts
lsof -p <PID>
ls -l /proc/<PID>/fd/

# Tracer les opérations I/O
sudo strace -p <PID> -e trace=write,fsync,open,close

# Statistiques I/O du processus
cat /proc/<PID>/io
```

**Observations attendues:**
- État: S ou D pendant fsync
- I/O write élevé
- Fichier /tmp/io_test_file ouvert

---

## Script de rapport automatique

**Fichier:** `rapport_analyse.rb`

**Utilisation:**
```bash
# Rapport global (top processus)
ruby analyse_processeur_performance/rapport_analyse.rb

# Analyse d'un processus spécifique
ruby analyse_processeur_performance/rapport_analyse.rb <PID>
```

**Informations collectées:**
- PID et nom du processus
- État (R, S, D, Z, T)
- Consommation CPU (%)
- Consommation mémoire (MB)
- Nombre de threads
- Fichiers ouverts
- Appels système typiques

---

## Guide des commandes

### ps - Process Status
```bash
# Tous les processus avec détails
ps aux

# Format personnalisé
ps -eo pid,ppid,cmd,%mem,%cpu,state

# Processus d'un utilisateur
ps -u username

# Arbre hiérarchique
ps auxf
```

### top / htop
```bash
# Lancement interactif
top

# Trier par mémoire: Shift+M
# Trier par CPU: Shift+P
# Filtrer: o puis COMMAND=ruby

# htop (plus convivial)
htop
# F5: arbre, F6: trier, F9: tuer
```

### pstree
```bash
# Arbre complet
pstree

# Avec PIDs
pstree -p

# D'un processus spécifique
pstree -p <PID>
```

### lsof - List Open Files
```bash
# Fichiers d'un processus
lsof -p <PID>

# Processus utilisant un fichier
lsof /path/to/file

# Connexions réseau d'un processus
lsof -i -p <PID>

# Tous les processus sur un port
lsof -i :80
```

### strace - System Call Trace
```bash
# Tracer un nouveau programme
strace ./programme

# S'attacher à un processus existant
sudo strace -p <PID>

# Résumé des syscalls
sudo strace -p <PID> -c

# Filtrer certains appels
sudo strace -p <PID> -e trace=open,read,write

# Sauvegarder dans un fichier
sudo strace -p <PID> -o trace.log
```

### /proc filesystem
```bash
# Informations générales
cat /proc/<PID>/status

# Statistiques brutes
cat /proc/<PID>/stat

# Ligne de commande
cat /proc/<PID>/cmdline | tr '\0' ' '

# Variables d'environnement
cat /proc/<PID>/environ | tr '\0' '\n'

# Mémoire mappée
cat /proc/<PID>/maps

# Descripteurs de fichiers
ls -l /proc/<PID>/fd/

# Limites système
cat /proc/<PID>/limits

# I/O stats
cat /proc/<PID>/io
```

---

## Méthodologie de diagnostic

### Problème de performance CPU

1. **Identifier** le processus:
   ```bash
   top
   ps aux --sort=-%cpu | head
   ```

2. **Analyser** son comportement:
   ```bash
   sudo strace -c -p <PID>  # Quels syscalls?
   cat /proc/<PID>/stack    # Où est le kernel?
   ```

3. **Vérifier** s'il est légitime ou malveillant:
   ```bash
   ls -l /proc/<PID>/exe    # Quel binaire?
   cat /proc/<PID>/cmdline  # Arguments?
   ```

### Problème de mémoire

1. **Détecter** la fuite:
   ```bash
   watch -n 1 "ps aux | grep <PID>"
   ```

2. **Analyser** les allocations:
   ```bash
   pmap -x <PID>
   cat /proc/<PID>/smaps
   ```

3. **Investiguer**:
   ```bash
   sudo strace -e trace=brk,mmap -p <PID>
   ```

### Problème I/O

1. **Identifier** les processus I/O:
   ```bash
   sudo iotop -o
   ```

2. **Analyser** les opérations:
   ```bash
   sudo strace -e trace=read,write,open,fsync -p <PID>
   lsof -p <PID>
   ```

3. **Vérifier** le système de fichiers:
   ```bash
   df -h
   iostat -x 1
   ```

---

## États des processus

- **R (Running)**: En cours d'exécution ou prêt
- **S (Sleeping)**: En attente interruptible (peut être réveillé)
- **D (Disk sleep)**: En attente non-interruptible (I/O)
- **Z (Zombie)**: Terminé mais pas encore nettoyé par le parent
- **T (Stopped)**: Arrêté (SIGSTOP, SIGTSTP)
- **t (Tracing stop)**: Arrêté par le debugger

---

## Bonnes pratiques

1. **Toujours** vérifier les permissions (sudo si nécessaire)
2. **Documenter** les PIDs et timestamps
3. **Sauvegarder** les traces pour analyse ultérieure
4. **Corréler** plusieurs sources d'information
5. **Être prudent** avec strace en production (overhead)