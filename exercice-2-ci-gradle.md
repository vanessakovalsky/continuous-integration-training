# Utilisation de gradle pour builder notre application

Cet exercice a pour but de vous faire manipuler Gradle, et notamment de créer le fichiers builds nécessaires à la construction de votre projet

## Pré-requis
Il est possible de faire ses exercices soit dans des conteneurs (voir docker ci-dessous) soit dans des VM vagrant (voir Vagrant ci-dessous) soit d'installer les outils en local (voir les sites officiels pour les procédures d'installation)

### Docker
* Afin d'éviter les installations trop nombreuses, nous allons utiliser docker et docker compose
* Installer docker :
https://docs.docker.com/get-docker/
* Installer docker-compose :
https://docs.docker.com/compose/install/ 
* Récupérer le fichier DockerFile
* Build et Lancement du conteneur docker:
```
docker build --tag my-gradle .
```

### Vagrant

* Récupérer le fichier VagrantFile et install.sh qui se trouve dans le dossier vagrant/gradle
* Installer Vagrant : https://www.vagrantup.com/ 
* Dans un terminal se positionner dans le dossier contenant les deux fichiers récupérer et lancer la commande : ```vagrant up```

## Exemple de build avec un projet PHP
* Si ce n'est pas fait récupérer le code source de votre projet, ici :
```
git clone https://github.com/vanessakovalsky/laravel-kingoludo.git project
```
* Dans votre IDE, créer à la racine du projet un fichier build.gradle contenant :
```

buildscript {
  repositories {
    gradlePluginPortal()
    maven {
      url "https://plugins.gradle.org/m2/"
    }
  }
  dependencies {
    classpath "gradle.plugin.org.swissphpfriends:php-build-plugin:0.1-SNAPSHOT"
  }
}

apply plugin: "org.hasnat.php-build-plugin"
apply plugin: "distribution"

def majorVersion = System.getenv("MAJOR_VERSION") ?: "1"
def minorVersion = System.getenv("MINOR_VERSION") ?: "0"
version = majorVersion + "." + minorVersion 

task purge(type:Delete) {
  //println 'Cleaning up old files'
  delete 'vendor', 'logs', 'build'
}

task composer(type:Exec, dependsOn: purge) {
  //println 'Setting up dependencies'
  executable 'sh'
  args '-c', 'php -r "readfile(\'https://getcomposer.org/installer\');" | php'
  standardOutput = new ByteArrayOutputStream()
  ext.output = { return standardOutput.toString() }
}
task vendor(type:Exec, dependsOn: composer) {
  //println 'Installing dependencies'
  executable 'sh'
  args '-c', 'php composer.phar install'
  standardOutput = new ByteArrayOutputStream()
  ext.output = { return standardOutput.toString() }
}


def tarfile = "application-" + version
task packageDistribution(type: Zip, dependsOn: vendor) {
    archiveFileName = tarfile + ".zip"
    destinationDirectory = file("project/build")

    from ('project/app') { into 'app' }
    from ('project/bootstrap') { into 'bootstrap' }
    from ('project/config') { into 'config' }
      from ('project/database') { into 'database' }
      from ('project/nbproject') { into 'nbproject' }
      from ('project/public') { into 'public' }
      from ('project/resources') { into 'resources' }
      from ('project/storage') {
        into 'storage'
        dirMode 0775
      }
      from ('project/vendor') { into 'vendor' }
      from { 'project/server.php' }
}
```
* Si on détaille un peu ce fichier :
* * apply plugin permet d'aller chercher le plugin de gradle qui permet de packager
* * def permet de définir des variables à utiliser (ici les numéros de version)
* * task purge : supprimer les anciens fichiers pour éviter les conflit
* * task composer : installe la dernière version de composer 
* * task vendor : utilise composer pour aller chercher les dépendances de notre projet
* * distribution permet de choisir les fichier à packager, le nom du package, c'est ce pagckage qui est appeler avec la commande gradle applicationDistTar
* * task tarball permet de choisir le format et la destination de sortie
* Pour éxecuter le build, il faut relancer le build avec la commande docker build utiliser auparavant
* Il est nécessaire de lancer les taches une par une, ce qui est un peu fastidieux
* Pour éviter ça on rajoute des dépendances entre les taches :
```
task purge (type:Delete) {
    [...]
}
task composer(type:Exec, dependsOn: purge) {
    [...]
}
task vendor(type:Exec, dependsOn: composer) {
    [...]
}
[...]
task packageDistribution(type: Zip, dependsOn: vendor) {
    [...]
}
```
*Lancer seulement la dernière tache dans votre environnement :
```
gradle packageDistribution --no-demon --info
```
* Pour découvrir l'ensemble des options, aller voir la documentation de gradle :
https://docs.gradle.org/current/userguide/userguide.html 

## Créer un build pour votre propre projet
* Définisser l'ensemble des actions nécessaires pour builder votre projet
* créer un build.gradle qui décrit ses taches en utilisant les plugins de gradle si nécessaire : https://plugins.gradle.org/ 

-> Pour aller plus loin d'autres exercices sont disponible ici : 
https://github.com/praqma-training/gradle-katas