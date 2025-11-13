#!/bin/bash

WTTR_URL="wttr.in"
VILLE_DEFAUT="Toulouse"
DATE=$(date +"%Y-%m-%d")
HEURE=$(date +"%H:%M")
FICHIER_HISTO="meteo_$(date +"%Y%m%d").json"

if [ -z "$1" ]; then
    VILLE="$VILLE_DEFAUT"
    echo "Aucune ville fournie, utilisation de la ville par défaut : $VILLE"
else
    VILLE="$1"
fi

if ! command -v jq &> /dev/null; then
    echo "Erreur : jq n'est pas installé."
    exit 1
fi

curl -s "$WTTR_URL/$VILLE?format=j1" > temp_local.json

TEMP_ACTUELLE=$(jq -r '.current_condition[0].temp_C' temp_local.json)
[ -z "$TEMP_ACTUELLE" ] && TEMP_ACTUELLE="Non disponible"
TEMP_ACTUELLE="${TEMP_ACTUELLE}°C"

TEMP_DEMAIN=$(jq -r '.weather[1].avgtempC' temp_local.json)
[ -z "$TEMP_DEMAIN" ] && TEMP_DEMAIN="Non disponible"
TEMP_DEMAIN="${TEMP_DEMAIN}°C"

PREVISION=$(jq -r '.current_condition[0].weatherDesc[0].value' temp_local.json)
[ -z "$PREVISION" ] && PREVISION="Non disponible"

VENT=$(jq -r '.current_condition[0].windspeedKmph' temp_local.json)
[ -z "$VENT" ] && VENT="Non disponible"
VENT="${VENT} km/h"

HUMIDITE=$(jq -r '.current_condition[0].humidity' temp_local.json)
[ -z "$HUMIDITE" ] && HUMIDITE="Non disponible"
HUMIDITE="${HUMIDITE}%"

VISIBILITE=$(jq -r '.current_condition[0].visibility' temp_local.json)
[ -z "$VISIBILITE" ] && VISIBILITE="Non disponible"
VISIBILITE="${VISIBILITE} km"

NOUVELLE_ENTREE=$(jq -n \
  --arg date "$DATE" \
  --arg heure "$HEURE" \
  --arg ville "$VILLE" \
  --arg temperature "$TEMP_ACTUELLE" \
  --arg prevision "$PREVISION" \
  --arg vent "$VENT" \
  --arg humidite "$HUMIDITE" \
  --arg visibilite "$VISIBILITE" \
  '{date: $date, heure: $heure, ville: $ville, temperature: $temperature, prevision: $prevision, vent: $vent, humidite: $humidite, visibilite: $visibilite}')

if [ -f "$FICHIER_HISTO" ]; then
    jq ". += [$NOUVELLE_ENTREE]" "$FICHIER_HISTO" > temp.json && mv temp.json "$FICHIER_HISTO"
else
    echo "[$NOUVELLE_ENTREE]" > "$FICHIER_HISTO"
fi

echo "Données JSON enregistrées dans $FICHIER_HISTO"

rm -f temp_local.json
exit 0
