#!/bin/bash

FICHIER_SORTIE="meteo.txt"
FICHIER_LOCAL="local.txt"
WTTR_URL="wttr.in"
VILLE_DEFAUT="Toulouse"

if [ -z "$1" ]; then
    VILLE="$VILLE_DEFAUT"
    echo "Vous n'avez pas mis une ville en argument , soit la ville par défaut : $VILLE"
else
    VILLE="$1"
fi

DATE=$(date +"%Y-%m-%d")
HEURE=$(date +"%H:%M")

curl -s "$WTTR_URL/$VILLE?format=j1" > "$FICHIER_LOCAL"

if ! command -v jq &> /dev/null; then
    echo "Erreur : jq n'est pas installé."
    exit 1
fi

TEMP_ACTUELLE=$(jq -r '.current_condition[0].temp_C' "$FICHIER_LOCAL")
[ -z "$TEMP_ACTUELLE" ] && TEMP_ACTUELLE="Non disponible"
TEMP_ACTUELLE="${TEMP_ACTUELLE}°C"

TEMP_DEMAIN=$(jq -r '.weather[1].avgtempC' "$FICHIER_LOCAL")
[ -z "$TEMP_DEMAIN" ] && TEMP_DEMAIN="Non disponible"
TEMP_DEMAIN="${TEMP_DEMAIN}°C"

echo "Ville : $VILLE"
echo "Temperature actuelle : $TEMP_ACTUELLE"
echo "Temperature prevue pour demain : $TEMP_DEMAIN"

echo "$DATE -$HEURE -$VILLE : $TEMP_ACTUELLE - $TEMP_DEMAIN" >> "$FICHIER_SORTIE"

echo "Données enregistrées dans $FICHIER_SORTIE"
exit 0
