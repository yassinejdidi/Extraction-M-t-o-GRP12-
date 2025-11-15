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

# Récupération météo texte
fichier="filemeteo.txt"
curl -s "$WTTR_URL/$VILLE" > temp1
sed -r 's/\x1B\[[0-9;]*[mK]//g' temp1 > "$fichier"
if [ ! -s "$fichier" ]; then
  echo "Erreur : impossible de récupérer les données pour $VILLE."
  exit 1
fi

temp_actuelle=$(grep -m1 -oE '[+-]?[0-9]+(\([0-9]+\))? *°C' "$fichier")
demain=$(date -d "tomorrow" +"%a %d %b")
temp_demain=$(grep -A8 "$demain" "$fichier" | grep -oE '[+-]?[0-9]+ °C' | grep -oE '[+-]?[0-9]+')

# Calcul moyenne temp demain
somme=0
compte=0
for t in $temp_demain; do
    somme=$((somme + t))
    compte=$((compte + 1))
done
if [ $compte -gt 0 ]; then
    moyenne=$((somme / compte))
    moyenne="${moyenne}°C"
else
    moyenne="Non disponible"
fi

[ -z "$temp_actuelle" ] && temp_actuelle="Non disponible"

# Autres infos
VENT=$(curl -s wttr.in/$VILLE?format="%w")
HUMIDITE=$(curl -s wttr.in/$VILLE?format="%h")
VISIBILITE=$(curl -s wttr.in/$VILLE?format="%v")

# Historique texte
fichier_sortie="meteo_$(date +"%Y%m%d").txt"
echo "$DATE $HEURE - $VILLE : $temp_actuelle / $moyenne" >> "$fichier_sortie"
echo "$DATE -$HEURE -$VILLE : $temp_actuelle - $moyenne " >> "$FICHIER_SORTIE"

# Récupération JSON
curl -s "$WTTR_URL/$VILLE?format=j1" > temp.json

if ! command -v jq &> /dev/null; then
    echo "Erreur : jq n'est pas installé."
    exit 1
fi

# Extraction des champs JSON
TEMP_ACTUELLE=$(jq -r '.current_condition[0].temp_C // "Non disponible"' temp.json)
TEMP_ACTUELLE="${TEMP_ACTUELLE}°C"
TEMP_DEMAIN=$(jq -r '.weather[1].avgtempC // "Non disponible"' temp.json)
TEMP_DEMAIN="${TEMP_DEMAIN}°C"
PREVISION=$(jq -r '.current_condition[0].weatherDesc[0].value // "Non disponible"' temp.json)
VENT=$(jq -r '.current_condition[0].windspeedKmph // "Non disponible"' temp.json)
VENT="${VENT} km/h"
HUMIDITE=$(jq -r '.current_condition[0].humidity // "Non disponible"' temp.json)
HUMIDITE="${HUMIDITE}%"
VISIBILITE=$(jq -r '.current_condition[0].visibility // "Non disponible"' temp.json)
VISIBILITE="${VISIBILITE} km"

# Création entrée JSON
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

# Ajout dans fichier JSON historique
if [ -f "$FICHIER_HISTO" ]; then
    jq ". += [$NOUVELLE_ENTREE]" "$FICHIER_HISTO" > "$FICHIER_HISTO.tmp" && mv "$FICHIER_HISTO.tmp" "$FICHIER_HISTO"
else
    echo "[$NOUVELLE_ENTREE]" > "$FICHIER_HISTO"
fi

echo "Données JSON enregistrées dans $FICHIER_HISTO"

# Nettoyage
rm -f temp.json temp1 "$fichier"
