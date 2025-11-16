#!/bin/bash

WTTR_URL="wttr.in"
VILLE_DEFAUT="Toulouse"
DATE=$(date +"%Y-%m-%d")
HEURE=$(date +"%H:%M")
demain=$(date -d "tomorrow" +"%a %d %b")
FICHIER_HISTO="meteo_$(date +"%Y%m%d").json"
log_erreur=fichier_erreur.log
if [ -z "$1" ]; then
    VILLE="$VILLE_DEFAUT"
    echo "Aucune ville fournie, utilisation de la ville par défaut : $VILLE"
else
    VILLE="$1"
fi

FICHIER_SORTIE="meteo.txt"

# Récupération météo texte
fichier="filemeteo.txt"
if ! curl -s --fail "$WTTR_URL/$VILLE" > temp1; then
    echo "$(date '+%Y-%m-%d %H:%M:%S')  ERREUR : impossible de se connecter à wttr.in pour la ville '$VILLE'." >> "fichier_erreur.log"
    echo "Erreur : connexion impossible."
    exit 1
fi
sed -r 's/\x1B\[[0-9;]*[mK]//g' temp1 > "$fichier"

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo "${TIMESTAMP} Erreur : Impossible de récupérer la météo pour ${VILLE}" >> "fichier_erreur.log"

if [ ! -s "$fichier" ]; then
  echo "Erreur : impossible de récupérer les données pour $VILLE."
  exit 1
fi

temp_actuelle=$(grep -m1 -oE '[+-]?[0-9]+(\([0-9]+\))? *°C' "$fichier")

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
if [ -z "$VENT" ];
then
    echo " ERREUR : impossible de se connecter à wttr.in pour récuperer la valeur du vent." >> "$log_erreur"
    echo "Erreur : connexion impossible."
    exit 1
fi

HUMIDITE=$(curl -s wttr.in/$VILLE?format="%h")
if [ -z "$HUMIDITE"  ];
then
    echo " ERREUR : impossible de se connecter à wttr.in pour récuperer la valeur de l'humidité ." >> "$log_erreur"
    echo "Erreur : connexion impossible."
    exit 1
fi

VISIBILITE=$(curl -s wttr.in/$VILLE?format="%v")
if [ -z "$VISIBILITE" ]; 
then
    echo " ERREUR : impossible de se connecter à wttr.in pour récuperer la valeur de la visibilité." >> "$log_erreur"
    echo "Erreur : connexion impossible."
    exit 1
fi

# Historique texte
fichier_sortie="meteo_$(date +"%Y%m%d").txt"
echo "$DATE $HEURE - $VILLE : $temp_actuelle / $moyenne" >> "$fichier_sortie"
echo "$DATE -$HEURE -$VILLE : $temp_actuelle - $moyenne " >> "$FICHIER_SORTIE"

# Récupération json
curl -s "$WTTR_URL/$VILLE?format=j1" > temp_local.json

if ! command -v jq &> /dev/null; then
    echo "Erreur : jq n'est pas installé."
    exit 1
fi

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

# --- CREATION DE L'ENTRÉE JSON ---
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

# --- AJOUT HISTORIQUE JSON ---
if [ -f "$FICHIER_HISTO" ]; then
    jq ". += [$NOUVELLE_ENTREE]" "$FICHIER_HISTO" > "$FICHIER_HISTO.tmp" \
        && mv "$FICHIER_HISTO.tmp" "$FICHIER_HISTO"
else
    echo "[$NOUVELLE_ENTREE]" > "$FICHIER_HISTO"
fi

# Affichage clair 
echo "temperature: $TEMP_ACTUELLE"
echo "prévision demain: $TEMP_DEMAIN"
echo "Vent : $VENT"
echo "Humidité : $HUMIDITE"
echo "Visibilité : $VISIBILITE"
echo "Les Données sont sauvegardées dans : $FICHIER_SORTIE"
echo "historique sauvegardée dans le fichier : $fichier_sortie"
echo "Données JSON enregistrées dans $FICHIER_HISTO"

rm -f temp_local.json
