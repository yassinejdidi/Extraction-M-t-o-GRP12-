#!/bin/bash

FICHIER_SORTIE="meteo.txt"
WTTR_URL="wttr.in"

if [ -z "$1" ]; then
    echo "Usage: $0 <Ville>"
    exit 1
fi

VILLE="$1"
DATE=$(date +"%d/%m/%Y")
HEURE=$(date +"%H:%M:%S")

if ! command -v jq &> /dev/null; then
    echo "Erreur : jq n'est pas installé."
    exit 1
fi

METEO_JSON=$(curl -s "$WTTR_URL/$VILLE?format=j1")

TEMP_ACTUELLE=$(echo "$METEO_JSON" | jq -r '.current_condition[0].temp_C')
[ -z "$TEMP_ACTUELLE" ] && TEMP_ACTUELLE="Non disponible"
TEMP_ACTUELLE="${TEMP_ACTUELLE}°C"

TEMP_DEMAIN=$(echo "$METEO_JSON" | jq -r '.weather[1].avgtempC')
[ -z "$TEMP_DEMAIN" ] && TEMP_DEMAIN="Non disponible"
TEMP_DEMAIN="${TEMP_DEMAIN}°C"

echo "Ville : $VILLE"
echo "Température actuelle : $TEMP_ACTUELLE"
echo "Température prévue pour demain : $TEMP_DEMAIN"

echo "$DATE - $HEURE - Ville : $VILLE - $TEMP_ACTUELLE - $TEMP_DEMAIN" >> "$FICHIER_SORTIE"

echo "Données enregistrées dans $FICHIER_SORTIE"
exit 0

