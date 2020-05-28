# Mettre en place Nexus pour gérer les paquet

Cet exercice a pour but de mettre en place et configurer nexus.
Puis d'intégrer le dépôt nexus à la fois pour récupérer des paquets comme proxy, mais aussi pour déposer les paquets produit par le build de gradle

## Mise en place de nexus
* Récupérer le fichier docker-compose.yml dans exercice-3-ci-nexus et placer le dans votre dossier de travail
* Lancer le docker compose (depuis le dossier de travail)
```
docker-compose up -d
```
* Vérifier que les deux conteneurs sont lancés :
```
docker-compose ps 
```
* Une fois les conteneurs lancés, nexus est accessible à l'url :
http://localhost:8081
* Se connecter (login : admin, pass : admin123)
* Quels sont les différents repositories existants ?
* Créer un repository de type Hosted Repository, qui nous servira à déposer nos builds

## Utilisation de nexus sur un projet PHP
* Nous allons utiliser notre repository de deux façons :
* * En tant que proxy pour composer
* * Pour publier les archives de notre application

### Utilisation de Nexus en tant que proxy pour composer 
* Installer le plugin composer pour nexus :
https://github.com/sonatype-nexus-community/nexus-repository-composer
* Créer un repository proxy dans Nexus pour composer
* Définir un cron pour récupérer les paquets périodiquement depuis le dépôt officiel
```
*/5 * * * * php /apps/satis2nexus/bin/satis build --no-interaction /apps/satis2nexus/satis.json /apps/satis2nexus_build/
*/10 * * * * php /apps/satis2nexus/bin/satis purge --no-interaction /apps/satis2nexus/satis.json /apps/satis2nexus_build/
```
* Ajouter dans le fichier build.gradle les informations sur le repository (adapter l'url à votre repository)
```
apply plugin: 'maven'

repositories {
    maven {
          url "http://localhost:8081/nexus/content/groups/public"
    }
}
```
* Le repository a été ajouté, il ne reste plus qu'à relancer le build
```
gradle tarball
```

### Déposer l'archive zip dans Nexus
* Créer un fichier gradle.properties à la racine du projet, il contient les informations de connexion
```
# Maven repository for publishing artifacts
nexusRepo=http://privatenexus/content/repositories/releases
nexusUsername=admin_user
nexusPassword=admin_password
```
* Dans le build.gradle ajouter la publication dans nexus :
```
apply plugin: "maven-publish"
[...]
publishing {
    publications {
        mavenJava(MavenPublication) {
            artifact source: tarball, extension: 'zip'
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
* Lancer la publication
```
gradle publishing
```

## Utilisation de nexus sur votre propre projet
* Créer les repository (hosted et proxy) ainsi qu'un groupe pour votre propre projet dans nexus
* Paramètrer le repository en ajoutant si nécessaire un ou plusieurs plugins
* Adapter le build.gradle pour utiliser le repository proxy pour récupérer vos dépendances
* Publier votre artifact dans nexus depuis gradle