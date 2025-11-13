#!/bin/bash

VILLE_DEFAUT="Toulouse"
if [ -z "$1" ]; then
    VILLE="$VILLE_DEFAUT"
    echo "Vous n'avez pas mis une ville en argument , soit la ville par défaut : $VILLE"
else
    VILLE="$1"
fi

FICHIER_SORTIE="meteo.txt"
FICHIER_LOCAL="local.txt"
WTTR_URL="wttr.in"
VILLE_DEFAUT="Toulouse"


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

#l'historique
fichier_sortie="meteo_$(date +"%Y%m%d").txt"
echo "$DATE $HEURE - $VILLE : $TEMP_ACTUELLE / $TEMP_DEMAIN" >> "$fichier_sortie"

echo "$DATE -$HEURE -$VILLE : $temp_actuelle - $moyenne " >> "$FICHIER_SORTIE"
echo "MÉTÉO POUR LA VILLE : $VILLE"
echo "historique sauvegardé dans le fichier : fichier_sortie"
echo "Les Données sont sauvegardées dans : $FICHIER_SORTIE"

#variante json
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

vent=$(curl -s wttr.in/$ville?format="%w")

humidite=$(curl -s wttr.in/$ville?format="%h")

date_meteo=$(jq -r '.weather[0].date' "$FICHIER_LOCAL")

visibilite=$(head -n 17 local.txt | tail -n 1 | grep -oE "[0-9]*")
echo "Saisie JSON"
echo "Ville : $VILLE"
echo "Date: $date_meteo "
echo "Temperature actuelle : $TEMP_ACTUELLE"
echo "Vent : $vent "
echo "Humidité : $humidite"
echo "Visibilité : $visibilite Km "
echo "$DATE -$HEURE -$VILLE : $TEMP_ACTUELLE - $TEMP_DEMAIN" >> "$FICHIER_SORTIE"

echo "Données enregistrées dans $FICHIER_SORTIE"
exit 0
