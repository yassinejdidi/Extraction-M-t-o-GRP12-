#!/bin/bash

read -p "Entrez le nom de la ville : " ville

fichier=filemeteo.txt
curl -s "wttr.in/${ville}?3" > temp1
sed -r 's/\x1B\[[0-9;]*[mK]//g' temp1 > "$fichier"

if [ ! -s "$fichier" ]; then
  echo "Erreur : impossible de récupérer les données pour $ville."
  exit 1
fi

temp_actuelle=$(grep -m1 -oE '[+-]?[0-9]+(\([0-9]+\))? *°C' filemeteo.txt)
demain=$(date -d "tomorrow" +"%a %d %b")
temp_demain=$(grep -A8 "$demain" filemeteo.txt |grep -oE '[+-]?[0-9]+(\([0-9]+\))? *°C'| paste -sd, -)


if [ -z "$temp_actuelle" ]; then
  temp_actuelle="Non disponible"
fi
if [ -z "$temp_demain" ]; then
  temp_demain="Non disponible"
fi

# 5. Afficher les résultats formatés
echo "      MÉTÉO POUR LA VILLE : $ville"
echo " Tmpérature actuelle : $temp_actuelle"
echo " Tmpérature prévue pour demain : $temp_demain"
echo "Les Données sont sauvegardées dans : $fichier"




