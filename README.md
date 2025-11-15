# Extraction-M-t-o-GRP12-
# Le projet : Un outil d’extraction d’information météorologique

##  Objectif du projet

Ce projet a pour but de créer un script Shell capable de récupérer automatiquement la température actuelle d’une ville
 ainsi que la prévision pour le lendemain grâce à wttr.in

Le script enregistre les informations dans un fichier texte, le notre s'appel filemeteo.txt, afin de conserver un historique
 des relevés météorologiques effectués par l'utilisateur.

Ce travail nous permet de nous familiariser avec :
- L’utilisation de Git pour la gestion des versions du script
- L'utilisation de cron pour executer automatiqement nos taches
- La collecte et la mise en forme de données météo avec curl.

### Version 1 : Script de base

Le script `Extracteur_Météo.sh` permet de :
1. Récupérer la météo  via  wttr.in pour la ville sélectionner.
2. Extraire la température actuelle et la prévision de celle du lendemain.
3. Formate les informations pour les rendre plus lisibles pour l'utilisateur.
4. Enregistrer les données dans le fichier `meteo.txt` au format :

[Date] - [Heure] - Ville : [Température actuelle] - [Prévision du lendemain]

Commandes pour l'executer : 
./Extracteur_Météo.sh Ville 

Exemple : 2024-09-24 -14:30 -Toulouse : 17°C - 19°C 

