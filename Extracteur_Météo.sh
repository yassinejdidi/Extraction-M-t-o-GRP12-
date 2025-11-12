#!/bin/bash

read -p "Entrez le nom de la ville : " ville
echo " Météo pour $ville " >> filemeteo.txt
curl wttr.in/$ville_url >> filemeteo.txt
#echo -e "\n\n" >> $fichier  ajoute une ligne vide entre deux villes

echo "Les données météo pour $ville ont été ajoutées."
