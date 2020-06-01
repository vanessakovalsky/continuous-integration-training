# Mise en place du job sur le serveur d'intégration continue

Cet exercice a pour objectif :
* De créer un job sur jenkins qui va permettre:
* * de récupérer le code sur le dépôt Git
* * de lancer l'installation des dépendances et les tests
* * de construire un paquet et de le déployer sur Nexus

## Pré-requis 
* un serveur jenkins a été créé pour la formation et est accessible à l'adresse : XXX
* il est également possible de lancer un jenkins en local à l'aide du docker compose du dossier exercice-5-ci-jenkins avec la commande :
```
docker-compose up -d
```
* Un serveur jenkins et un serveur nexus sont alors lancés sur deux conteneurs
* Il est nécessaire de configurer jenkins
* Pour cela aller à l'adresse : http//localhost:8098 
* Récupérer le mot de passe initial de l'admin à l'aide du chemin fourni
* Configurer les plugins (vous pouvez laisser les plugins recommandés)
* Configurer votre compte admin
* Vous êtes prêt à utiliser votre jenkins :) 

## Configurer le premier job 
* Une fois connecter Jenkins vous propose de créer un job (si des jobs existent, utiliser le menu Add new item) 
* Cliquer sur freestyle project, puis sur suivant
* Dans la rubrique Source code management, choisir Git et rentrer l'URL du projet :
https://github.com/vanessakovalsky/laravel-kingoludo.git
* Dans credentials, laissez None (pas besoin d'identifiant pour cloner le projet)
* Cliquer sur Save 
* Vous arrivez sur la page du Job
* Vous pouvez executer le job en cliquant sur Build now
* Le job se lance, cliquez dessus pour avoir des informations
* En allant dans Console Output, que voyez vous ? 
```
Started by user Vanessa
Running as SYSTEM
Building in workspace /var/lib/jenkins/workspace/Test-PHP
No credentials specified
Cloning the remote Git repository
Cloning repository https://github.com/vanessakovalsky/laravel-kingoludo.git
 > git init /var/lib/jenkins/workspace/Test-PHP # timeout=10
Fetching upstream changes from https://github.com/vanessakovalsky/laravel-kingoludo.git
 > git --version # timeout=10
 > git fetch --tags --progress -- https://github.com/vanessakovalsky/laravel-kingoludo.git +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git config remote.origin.url https://github.com/vanessakovalsky/laravel-kingoludo.git # timeout=10
 > git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git config remote.origin.url https://github.com/vanessakovalsky/laravel-kingoludo.git # timeout=10
Fetching upstream changes from https://github.com/vanessakovalsky/laravel-kingoludo.git
 > git fetch --tags --progress -- https://github.com/vanessakovalsky/laravel-kingoludo.git +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git rev-parse refs/remotes/origin/master^{commit} # timeout=10
 > git rev-parse refs/remotes/origin/origin/master^{commit} # timeout=10
Checking out Revision 43b04e5d53edac5d010ae78353207bce9ed145a9 (refs/remotes/origin/master)
 > git config core.sparsecheckout # timeout=10
 > git checkout -f 43b04e5d53edac5d010ae78353207bce9ed145a9 # timeout=10
Commit message: "Add vue component"
First time build. Skipping changelog.
Finished: SUCCESS
```
* Le job est maintenant prêt, félicitations, votre premier job Jenkins est configuré et opérationnel

## Ajouter le build de gradle à notre job
* Retourner dans le build
* Cliquer à gauche dans le menu sur Configure
* Dans la section Build, choisir Add step
* Choisir Invoke Gradle script
* Dans Tasks entrer la tâche gradle à executer : installDeps
* Sauvegarder et lancer un build
* En consultant la sortie Console Output, vous verrez que l'installation des dépendances a bien été effectuée
* Vous pouvez maintenant ajouter les différentes étapes du build : test et publish 
* Votre job est maintenant constitué de 3 étapes :
* * l'installation des dépendances 
* * le lancement des tests
* * la construction d'une archive zip et son déploiement dans Nexus OSS

## Un job pour votre projet
* Créer maintenant un job jenkins pour votre projet
* Ajouter la récupération du code source
* Ajouter les différentes étapes de build depuis le script gradle créé précédement (il est nécessaire que les outils que vous utilisiez soit installer sur le serveur jenkins) + pensez à modifier les paratmètres de votre gradle.properties, notamment l'adresse du depôt Nexus

## Configurer Github pour déclencher un build à chaque commit
* Vous avez besoin d'un token d'API de Jenkins pour configurer le webhook dans github
* Sur jenkins, cliquer sur votre nom en haut à droite
* Puis sur Configure dans le menu
* Dans la section API Token, cliquer sur Add new token, et copier le token généré
* Aller sur votre projet Github
* Dans les paramètres, choisir Webhook
* Cliquer sur Add webhook :
* * Dans payload URL, entrer l'adresse de Jenkins sous la forme http://[login]:[APITOKEN]@[URLduJenkins.com:8080]/github-webhook
* Enregistrer
* Côté Jenkins, aller dans le job
* Dans la rubrique Build Triggers, cochez la case : GitHub hook trigger for GITScm polling 

-> Votre job est configuré pour être lancé à chaque push sur la branche master dans votre dépôt Github

