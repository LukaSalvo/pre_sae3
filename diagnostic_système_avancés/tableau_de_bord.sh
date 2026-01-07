#!/bin/bash



# --- 1. VARIABLES DE CONFIGURATION ---
DATE_JOUR=$(date +%Y-%m-%d_%Hh%M)
FICHIER_RAPPORT="diagnostic_systeme_${DATE_JOUR}.txt"

# --- 2. FONCTIONS UTILITAIRES ---

# Fonction pour créer des en-têtes visibles dans le rapport
function ajouter_titre() {
    local titre="$1"
    echo "" >> "$FICHIER_RAPPORT"
    echo "############################################################" >> "$FICHIER_RAPPORT"
    echo ">>> $titre" >> "$FICHIER_RAPPORT"
    echo "############################################################" >> "$FICHIER_RAPPORT"
    echo "" >> "$FICHIER_RAPPORT"
    echo "Traitement de : $titre..."
}

# Vérification des droits root (nécessaire pour iotop et dmesg complet)
if [ "$EUID" -ne 0 ]; then
  echo "ERREUR : Ce script doit être lancé en tant que root (sudo)."
  echo "Raison : iotop et dmesg nécessitent des privilèges élevés."
  exit 1
fi

# --- 3. DÉBUT DU TRAITEMENT ---

echo "--- Démarrage du diagnostic système ---"
echo "Le rapport sera enregistré dans : $FICHIER_RAPPORT"
echo "Date du diagnostic : $(date)" > "$FICHIER_RAPPORT"

# ---------------------------------------------------------
# A. ANALYSE DU DÉMARRAGE (Systemd)
# ---------------------------------------------------------
ajouter_titre "TEMPS DE DÉMARRAGE (systemd-analyze)"
echo "Temps total de boot :" >> "$FICHIER_RAPPORT"
systemd-analyze time >> "$FICHIER_RAPPORT"

echo -e "\n--- Top 10 des services les plus lents (blame) ---" >> "$FICHIER_RAPPORT"
systemd-analyze blame | head -n 10 >> "$FICHIER_RAPPORT"

# ---------------------------------------------------------
# B. STATISTIQUES GLOBALES (vmstat)
# ---------------------------------------------------------
ajouter_titre "MÉMOIRE & ACTIVITÉ GLOBALE (vmstat)"
# Explication des flags :
# 1 5 : Affiche 5 échantillons espacés de 1 seconde (pour voir une tendance)
# -w : Wide mode (meilleur formatage pour les grands écrans)
echo "Légende : si/so = Swap In/Out | bi/bo = Blocks In/Out (Disque) | wa = CPU Wait (Attente I/O)" >> "$FICHIER_RAPPORT"
vmstat -w 1 5 >> "$FICHIER_RAPPORT"

# ---------------------------------------------------------
# C. STATISTIQUES PROCESSEUR DÉTAILLÉES (mpstat)
# ---------------------------------------------------------
ajouter_titre "UTILISATION CPU PAR CŒUR (mpstat)"
# -P ALL : Affiche les stats pour chaque cœur individuellement
mpstat -P ALL 1 1 >> "$FICHIER_RAPPORT"

# ---------------------------------------------------------
# D. ENTRÉES/SORTIES DISQUE (iostat)
# ---------------------------------------------------------
ajouter_titre "PERFORMANCE DISQUE (iostat)"
# -x : Statistiques étendues (indispensable pour voir %util et await)
# -z : Cache les partitions inactives pour alléger la lecture
iostat -xz 1 3 >> "$FICHIER_RAPPORT"

# ---------------------------------------------------------
# E. PROCESSUS GOURMANDS EN I/O (iotop)
# ---------------------------------------------------------
ajouter_titre "TOP PROCESSUS I/O (iotop)"
# -b : Mode Batch (non interactif, format texte)
# -n 3 : Prend 3 échantillons
# -o : Only (montre seulement les processus qui font réellement de l'I/O)
iotop -b -n 3 -o | head -n 15 >> "$FICHIER_RAPPORT"

# ---------------------------------------------------------
# F. HISTORIQUE DE CHARGE (sar)
# ---------------------------------------------------------
ajouter_titre "HISTORIQUE RECENT (sar)"
# -q : Queue length et load averages
echo "--- Charge système (Load Average) ---" >> "$FICHIER_RAPPORT"
sar -q | tail -n 10 >> "$FICHIER_RAPPORT"

# -r : Utilisation Mémoire
echo -e "\n--- Utilisation Mémoire ---" >> "$FICHIER_RAPPORT"
sar -r | tail -n 10 >> "$FICHIER_RAPPORT"

# ---------------------------------------------------------
# G. JOURNAUX NOYAU (dmesg)
# ---------------------------------------------------------
ajouter_titre "MESSAGES NOYAU & ERREURS (dmesg)"
echo "--- 10 Derniers messages ---" >> "$FICHIER_RAPPORT"
dmesg | tail -n 10 >> "$FICHIER_RAPPORT"

echo -e "\n--- Recherche d'erreurs potentielles (Hardware/Driver) ---" >> "$FICHIER_RAPPORT"
# grep -iE : Recherche insensible à la casse (i) avec regex étendue (E)
dmesg | grep -iE "error|fail|warn|critical" | tail -n 10 >> "$FICHIER_RAPPORT"

# --- FIN ---
echo "--- Diagnostic terminé avec succès ---"
echo "Vous pouvez lire le rapport avec la commande : less $FICHIER_RAPPORT"
