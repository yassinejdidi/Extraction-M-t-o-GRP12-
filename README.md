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
-

### Version 1 : Script de base

Le script `Extracteur_Météo.sh` permet de :

1. Récupérer la météo  via  wttr.in pour la ville sélectionner.

2. Extraire la température actuelle et la prévision de celle du lendemain.

3. Formate les informations pour les rendre plus lisibles pour l'utilisateur.

4. Enregistrer les données dans un fichier au format :

[Date] - [Heure] - Ville : [Température actuelle] - [Prévision du lendemain]

Commandes pour l'executer :
./Extracteur_Météo.sh Ville

Exemple de réultat : 2024-09-24 -14:30 -Toulouse : 17°C - 19°C

### Version2  : Automatisation

Objectif : Automatiser l'execution du script

Le script de la version 2  permet de :

1. Une ville va être attribuer par default si aucun argument n'est donné.

2. On a configuré une tache CRON pour executer le script automatiquement

3. La tache CRON va enregistrer les données périodiquement


### Configurer une tache CRON :

Le script permet de récupérer automatiquement les données météo de la
ville choisit.
Pour automatiser son exécution à intervalles réguliers, on utilise CRON

#### Étapes :

1.On va vérifier que le script est exécutable :


chmod +x /chemin/vers/Extracteur_Météo.sh

2. On ouvre cron :

crontab -e

3.Commande pour exécuter le script à chaque heure :

0 * * * * /chemin/vers/Extracteur_Météo.sh >> /chemin/vers/cron_meteo.log
 
### Version 3 : Gestion d'historique

L'objectif : Conservation d'un historique pour les prévisions

Le script va :

1. Crée un fichier du jour `meteo_YYYYMMDD.txt`.

2. Ajoute chaque nouveau relevé dans ce fichier.

3. Sauvegarde un résumé global dans `meteo.txt`.

4. Permet de consulter plus tard les données passées.

### Variante 1 : Informations supplémentaires

L'objectif :  Ajouter plus de détails sur la météo.

Le script va récuperer :

1. La vitesse du vent.

2. Le taux d’humidité.

3. La visibilité.

Les données vont être ajoutées dans les fichiers dans ce format :

[Date] - [Heure] - Ville : [Température] - [Prévision demain]
- Vent : [Vitesse] - Humidité : [Taux] - Visibilité : [Distance]
 

### La variante 2 : Sauvegarde en format JSON

L'objectif :  Enregistrer les données sous un format JSON donc plus structuré

Le script va:

1.créer un fichier `meteo_YYYYMMDD.json` contenant toutes les observations du jour.

2.A chaque nouvelle exécution, on ajoute une nouvelle ligne dans le fichier

3.Ce format permet d'exploiter les données plus facilement.

Par exemple :
{
"date": "2025-11-16",

"heure": "12:30",

"ville": "Toulouse",

"temperature": "18°C",

"prevision": "Ciel clair",

"vent": "12 km/h",

"humidite": "65%",

"visibilite": "9 km"
}


