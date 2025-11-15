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

FICHIER_SORTIE="meteo.txt"
FICHIER_LOCAL="local.json"


fichier=filemeteo.txt
curl -s "wttr.in/${VILLE}" > temp1
sed -r 's/\x1B\[[0-9;]*[mK]//g' temp1 > "$fichier"
if [ ! -s "$fichier" ]; then
  echo "Erreur : impossible de récupérer les données pour $ville."
  exit 1
fi
DATE=$(date +"%Y-%m-%d")
HEURE=$(date +"%H:%M")
temp_actuelle=$(grep -m1 -oE '[+-]?[0-9]+(\([0-9]+\))? *°C' filemeteo.txt)
demain=$(date -d "tomorrow" +"%a %d %b")
temp_demain=$(grep -A8 "$demain" filemeteo.txt | grep -oE '[+-]?[0-9]+ °C' | grep -oE '[+-]?[0-9]+')

somme=0
compte=0

for t in $temp_demain; do
    somme=$((somme + t))
    compte=$((compte + 1))
done

# Calculer la moyenne
if [ $compte -gt 0 ]; then
    moyenne=$((somme / compte))
    moyenne="${moyenne}°C"
else
    echo "Aucune température trouvée."
fi

if [ -z "$temp_actuelle" ]; then
  temp_actuelle="Non disponible"
fi
if [ -z "$temp_demain" ]; then
  temp_demain="Non disponible"
fi

VENT=$(curl -s wttr.in/$ville?format="%w")
HUMIDITE=$(curl -s wttr.in/$ville?format="%h")
VISIBILITE=$(curl -s "wttr.in/$ville?format=%v")

#l'historique
fichier_sortie="meteo_$(date +"%Y%m%d").txt"
echo "$DATE $HEURE - $VILLE : $temp_actuelle / $moyenne" >> "$fichier_sortie"
echo "historique sauvegardé dans le fichier : fichier_sortie"

echo "Vent : $VENT "
echo "Humidité : $HUMIDITE"
echo "Visibilité : $VISIBILITE Km "
echo "$DATE -$HEURE -$VILLE : $temp_actuelle - $moyenne " >> "$FICHIER_SORTIE"
echo "Les Données sont sauvegardées dans : $FICHIER_SORTIE"

#variante json
curl -s "$WTTR_URL/$VILLE?format=j1" > temp.json
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
  '{date: $date, heure: $heure, ville: $ville, temperature: $temperature, prevision: $prevision, vent: $vent, humidite: $humidite, visibilite: $visibilite}'
)

if [ -f "$FICHIER_HISTO" ]; then
    jq ". += [$NOUVELLE_ENTREE]" "$FICHIER_HISTO" > temp.json && mv temp.json "$FICHIER_HISTO"
else
    echo "[$NOUVELLE_ENTREE]" > "$FICHIER_HISTO"
fi

echo "Données JSON enregistrées dans $FICHIER_HISTO"

rm -f temp_local.json_
