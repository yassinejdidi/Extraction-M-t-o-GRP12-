$(grep "°C" filemeteo.txt | head -n 1 | awk '{print $2}')#!/bin/bash

read -p "Entrez le nom de la ville : " ville
echo " Météo pour $ville " >> filemeteo.txt
curl wttr.in/$ville >> filemeteo.txt

echo "Température actuelle de la ville : $(grep "°C" filemeteo.txt | head -n 1 )"

echo "Prévision meteo pour demain : $(grep "°C" filemeteo.txt | head -n 2 | tail -n 1)"
echo "Les données météo pour $ville sont disponible vous pouvez les consulter."
