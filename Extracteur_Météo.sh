#!/bin/bash

FICHIER_METEO="filemeteo.txt"
WTTR_URL="wttr.in"
LANGUE="fr" 

if [ -z "$1" ]; then
    echo "Usage: $0 <Ville>"
    echo "Exemple: ./Extracteur_Météo.sh Toulouse"
    exit 1
fi

VILLE="$1"

echo "Recuperation des donnees meteorologiques pour $VILLE..."

curl -s "$LANGUE.$WTTR_URL/$VILLE?format=v2" > "$FICHIER_METEO"

if [ $? -ne 0 ] || [ ! -s "$FICHIER_METEO" ]; then
    echo "Erreur: Impossible de recuperer les donnees ou fichier vide."
    rm -f "$FICHIER_METEO"
    exit 1
fi

echo "Donnees sauvegardees dans $FICHIER_METEO."


TEMP_ACTUELLE_LIGNE=$(grep -E '([+-][0-9]+)' "$FICHIER_METEO" | head -n 1)

TEMP_ACTUELLE=$(echo "$TEMP_ACTUELLE_LIGNE" | grep -oE '[+-][0-9]+\(?[0-9]*\)?' | head -n 1)

if [ -z "$TEMP_ACTUELLE" ]; then
    TEMP_ACTUELLE="Non disponible"
fi

TEMP_DEMAIN_LIGNE=$(grep -A 1 'Demain' "$FICHIER_METEO" | tail -n 1)

TEMP_DEMAIN=$(echo "$TEMP_DEMAIN_LIGNE" | awk '{print $NF}' | sed 's/+//; s/±//')
if [ -z "$TEMP_DEMAIN" ]; then
    TEMP_DEMAIN="Non disponible"
fi

echo "Ville : $VILLE"
echo "Temperature actuelle : $TEMP_ACTUELLE"
echo "Temperature prevue pour demain (Max..Min) : $TEMP_DEMAIN"

exit 0
