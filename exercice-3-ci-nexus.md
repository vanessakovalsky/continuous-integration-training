# Mettre en place Nexus pour gérer les paquet

Cet exercice a pour but de mettre en place et configurer nexus.
Puis d'intégrer le dépôt nexus à la fois pour récupérer des paquets comme proxy, mais aussi pour déposer les paquets produit par le build de gradle

## Mise en place de nexus
Lire le paragraphe qui concerne votre environnement (Docker ou Vagrant)
### Docker
* Récupérer le fichier docker-compose.yml dans exercice-3-ci-nexus et placer le dans votre dossier de travail
* Lancer le docker compose (depuis le dossier de travail)
```
docker-compose up -d
```
* Vérifier que les deux conteneurs sont lancés :
```
docker-compose ps 
```
* Nexus prend quelque minutes à démarrer complètement, pour vérifier utiliser :
```
docker logs -f nexus
```
* Cette commande doit afficher :
```
Started Sonatype Nexus OSS 3.23.0-03
```
* Une fois les conteneurs lancés, nexus est accessible à l'url :
http://localhost:8099
* Récupérer le mot de passe (dans un terminal) :
```
docker exec -t -i nexus sh
cat nexus-data/admin.password
```
* Noter le mot de passe afficher
* Il est indispensable de récupérer l'IP du container Nexus, pour cela on utilise docker network inspect qui permet d'avoir des informations sur le réseau :
```
docker network inspect 
```

### Vagrant
* Récupérer le Vagrantfile et le fichier install.sh dans le dossier vagrant/nexus de ce dépôt
* Ouvrir un terminal et se positionner dans le dossier contenant les deux fichiers que l'on vient de récupérer puis lancer un ```vagrant up```
* Choisir votre interface réseau
* Patientez le temps que la VM démarre
* Une fois la VM démarré en dernier, vous devriez avoir le mot de passe admin affiché, si ce n'est pas le cas : 
* COnnexter vous sur la VM (vagrant ssh)
* Aller afficher le mot de passe qui se trouve dans : /opt/nexus/sonatype-work/nexus3/admin.password
* Noter le mot de passe
* Aller sur http://192.168.0.44 

## Configuration (pour tous les environnements)
* Se connecter (login : admin, pass : (récupérer à l'étape précédente))
* Suivre les 4 étapes de configuration
* Quels sont les différents repositories existants ?
* Créer un repository de type Hosted Repository, qui nous servira à déposer nos builds

## Utilisation de nexus sur un projet PHP
* Nous allons utiliser notre repository pour publier les archives de notre application

* Dans les lignes affichés, on cherche Nexus et la ligne contenant IP/V4
* Créer un fichier gradle.properties à la racine du projet, il contient les informations de connexion (adapter l'IP à votre environnement)
```
# Maven repository for publishing artifacts
nexusRepo=172.22.0.3:8081/repository/maven-releases/
```
* Dans le build.gradle ajouter la publication dans nexus :
```
apply plugin: "maven-publish"
[...]
group = 'laravel-kingoludo'

publishing {
    publications {
        maven(MavenPublication) {
            artifact source: packageDistribution, extension: 'zip'
        }
    }
    repositories {
        maven {
            credentials {
                username nexusUsername
                password nexusPassword
            }
            url nexusRepo
        }
    }
}
```
* Quelques explications sur la tache ci-dessus :
* * Pour publier il est obligatoire de donner un nom à un group de projet (le nom de votre choix ici laravel-kingoludo)
* * La partie suivante définie les options pour la publication 
* * publication définit le type de publication et la source (le fichier à déployer)
* * repositories définit la destination avec les informations de connexions et l'url (qui sont récupérés dans le gradle.properties)
* Modifier le Dockerfile pour appeler la tache publish
* Lancer la publication dans le conteneur ou la vm
```
gradle publishing
```
* Vérifier dans nexus que votre archive zip a bien été publiée :)

## Utilisation de nexus sur votre propre projet
* Créer le repository (hosted) pour votre propre projet dans nexus
* Paramètrer le repository 
* Publier votre artifact dans nexus depuis gradle

## Pour aller plus loin (si vous avez le temps ou à faire plus tard)
* Mettre en place un repository proxy sur nexus qui va récupérer vos dépendances
* Utiliser ce repository proxy pour récupérer vos dépendances dans votre script gradle
