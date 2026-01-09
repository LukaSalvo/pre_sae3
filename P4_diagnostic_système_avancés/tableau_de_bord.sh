#!/bin/bash

# Configuration
DATE_JOUR=$(date +%Y-%m-%d_%Hh%M)
OUTPUT_DIR="."
# mkdir -p "$OUTPUT_DIR" # Inutile si on est dans .

# Mode par défaut : HTML
FORMAT="HTML"
FICHIER_RAPPORT="$OUTPUT_DIR/dashboard_${DATE_JOUR}.html"

# Fonction d'aide
usage() {
    echo "Usage: $0 [--text]"
    echo "  --text : Génère un rapport texte (par défaut : HTML)"
    exit 1
}

# Gestion des arguments
if [[ "$1" == "--text" ]]; then
    FORMAT="TEXT"
    FICHIER_RAPPORT="$OUTPUT_DIR/dashboard_${DATE_JOUR}.txt"
fi

# Vérification root
if [ "$EUID" -ne 0 ]; then
  echo "ERREUR : Ce script doit être lancé en tant que root (sudo)."
  exit 1
fi

# Vérification des dépendances
DEPENDENCIES=("vmstat" "mpstat" "iostat" "iotop" "sar" "pidstat")
MISSING_DEPS=()

for cmd in "${DEPENDENCIES[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        MISSING_DEPS+=("$cmd")
    fi
done

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo "ERREUR : Des outils manquants sont nécessaires."
    echo "Veuillez installer sysstat et iotop :"
    echo "  sudo apt-get update && sudo apt-get install -y sysstat iotop"
    echo "Outils manquants : ${MISSING_DEPS[*]}"
    exit 1
fi

# --- FONCTIONS DE GÉNÉRATION ---

start_report() {
    if [[ "$FORMAT" == "HTML" ]]; then
        cat <<EOF > "$FICHIER_RAPPORT"
<html>
<head>
<title>Dashboard diagnostic système</title>
</head>
<body>
<h1>Tableau de bord diagnostic système</h1>
<p>Généré le : $(date) sur $(hostname)<br>
Kernel : $(uname -r) | Uptime : $(uptime -p)</p>
<hr>
EOF
    else
        echo "=== RAPPORT DIAGNOSTIC SYSTÈME ===" > "$FICHIER_RAPPORT"
        echo "Date : $(date)" >> "$FICHIER_RAPPORT"
        echo "Machine : $(hostname)" >> "$FICHIER_RAPPORT"
        echo "==================================" >> "$FICHIER_RAPPORT"
    fi
}

add_section() {
    local title="$1"
    local command_output="$2"
    
    echo "Traitement : $title"

    if [[ "$FORMAT" == "HTML" ]]; then
        echo "<h2>$title</h2>" >> "$FICHIER_RAPPORT"
        echo "<pre>" >> "$FICHIER_RAPPORT"
        echo "$command_output" >> "$FICHIER_RAPPORT"
        echo "</pre>" >> "$FICHIER_RAPPORT"
    else
        echo -e "\n\n>>> $title" >> "$FICHIER_RAPPORT"
        echo "$command_output" >> "$FICHIER_RAPPORT"
    fi
}

finish_report() {
    if [[ "$FORMAT" == "HTML" ]]; then
        echo "</body></html>" >> "$FICHIER_RAPPORT"
        echo "Rapport HTML généré : $FICHIER_RAPPORT"
    else
        echo "Rapport Texte généré : $FICHIER_RAPPORT"
    fi
}

get_sar_data() {
    local type="$1"
    local output
    
    # Tentative de lire l'historique du jour (peut être vide si sysstat vient d'être installé)
    output=$(sar "$type" 2>/dev/null)
    
    # Si vide ou erreur, on capture des données en direct (5 échantillons de 1s)
    if [ -z "$output" ] || [[ "$output" == *"End of system activity file unexpected"* ]]; then
        output=$(echo "Historique indisponible. Capture de données en temps réel (5 sec)..." && sar "$type" 1 5)
    fi
    echo "$output"
}

# --- EXECUTION ---

start_report

# 1. CPU Load
DATA=$(mpstat -P ALL 1 1)
add_section "Utilisation CPU (mpstat)" "$DATA"

# 2. Memory
DATA=$(vmstat -w -S M 1 5)
add_section "Activité mémoire & swap (vmstat)" "$DATA"

# 3. Disk I/O Stats
DATA=$(iostat -xz 1 3)
add_section "Statistiques E/S disque (iostat)" "$DATA"

# 4. Top I/O Processes
DATA=$(iotop -b -n 3 -o | head -n 15)
add_section "Top processus consommateurs d'I/O (iotop)" "$DATA"

# 5. System Load History
# Utilisation de la fonction helper pour gérer l'absence d'historique
DATA_LOAD=$(get_sar_data "-q")
DATA_MEM=$(get_sar_data "-r")
add_section "Historique charge système (sar -q)" "$DATA_LOAD"
add_section "Historique mémoire (sar -r)" "$DATA_MEM"

# 6. Kernel Errors
DATA=$(dmesg | grep -iE "error|fail|warn|critical" | tail -n 20)
if [ -z "$DATA" ]; then
    DATA="Aucune erreur critique récente détectée dans les logs noyau."
fi
add_section "Alertes noyau (dmesg)" "$DATA"

# 7. Boot Analysis
DATA=$(systemd-analyze time; echo ""; systemd-analyze blame | head -n 10)
add_section "Analyse du démarrage (systemd-analyze)" "$DATA"

finish_report
