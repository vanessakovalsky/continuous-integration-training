# Utilisation de gradle pour builder notre application

Cet exercice a pour but de vous faire manipuler Gradle, et notamment de créer le fichiers builds nécessaires à la construction de votre projet

## Pré-requis

* Afin d'éviter les installations trop nombreuses, nous allons utiliser docker et docker compose
* Installer docker :
https://docs.docker.com/get-docker/
* Installer docker-compose :
https://docs.docker.com/compose/install/ 

## Exemple de build avec un projet PHP
* Si ce n'est pas fait récupérer le code source de votre projet, ici :
```
git clone https://github.com/vanessakovalsky/laravel-kingoludo.git
```
* Lancement du conteneur docker:
```
docker run -d -i -t -v "$PWD":/home/gradle/project -w /home/gradle/project gradle
```
* Pour vérifier que votre conteneur fonctionne :
```
docker ls
```
* Votre conteneur utilisant gradle doit apparaitre dans la liste
* Dans votre IDE, créer à la racine du projet un fichier build.gradle contenant :
```
apply plugin: "distribution"
def majorVersion = System.getenv("MAJOR_VERSION") ?: "1"
def minorVersion = System.getenv("MINOR_VERSION") ?: "0"
version = majorVersion + "." + minorVersion 

task purge << {
  //println 'Cleaning up old files'
  delete 'vendor', 'logs', 'build', 'composer.phar'
}
task composer(type:Exec) {
  //println 'Setting up dependencies'
  executable 'sh'
  args '-c', 'php -r "readfile(\'https://getcomposer.org/installer\');" | php'
  standardOutput = new ByteArrayOutputStream()
  ext.output = { return standardOutput.toString() }
}
task vendor(type:Exec) {
  //println 'Installing dependencies'
  executable 'sh'
  args '-c', 'php composer.phar install'
  standardOutput = new ByteArrayOutputStream()
  ext.output = { return standardOutput.toString() }
}

distributions {
  application {
    baseName = 'application'
    contents {
      from ('app') { into 'app' }
      from ('bootstrap') { into 'bootstrap' }
      from ('config') { into 'config' }
      from ('database') { into 'database' }
      from ('nbproject') { into 'nbproject' }
      from ('public') { into 'public' }
      from ('resources') { into 'resources' }
      from ('storage') {
        into 'storage'
        dirMode 0775
      }
      from ('vendor') { into 'vendor' }
      from { 'server.php' }
    }
  }
}
def tarfile = "build/distributions/application-" + version
task tarball(type:Exec) {
  //println 'Compressing tar'
  executable 'sh'
  args '-c', "gzip -f < " + tarfile + ".tar > " + tarfile + ".tgz"
}
```
* Si on détaille un peu ce fichier :
* * apply plugin permet d'aller chercher le plugin de gradle qui permet de packager
* * def permet de définir des variables à utiliser (ici les numéros de version)
* * task purge : supprimer les anciens fichiers pour éviter les conflit
* * task composer : installe la dernière version de composer 
* * task vendor : utilise composer pour aller chercher les dépendances de notre projet
* * distribution permet de choisir les fichier à packager
* * task tarball permet de choisir le format et la destination de sortie
* Pour éxecuter le build, il faut se connecter sur la machine docker
* Récupérer l'id ou le nom de la machine avec 
```
docker ls
```
* Se connecter sur la machine :
```
docker exec [IDDELAMACHINE] sh
```
* Lister les taches du build
```
gradle tasks
```
* Lancer les taches
```
gradle purge
gradle composer
gradle vendor
gradle tarball
```
* Il est nécessaire de lancer les taches une par une, ce qui est un peu fastidieux
* Pour éviter ça on rajoute des dépendances entre les taches :
```
task purge << {
    [...]
}
task composer(type:Exec, dependsOn: purge) {
    [...]
}
task vendor(type:Exec, dependsOn: composer) {
    [...]
}
[...]
task tarball(type:Exec, dependsOn: vendor) {
    [...]
}
```
* Lorsque nous lançons seulement la dernière tâche, l'ensemble des autres taches se lançent également avec l'arbre de dépendance :
```
gradle tarball
```
* Pour découvrir l'ensemble des options, aller voir la documentation de gradle :
https://docs.gradle.org/current/userguide/userguide.html 

## Créer un build pour votre propre projet
* Définisser l'ensemble des actions nécessaires pour builder votre projet
* créer un build.gradle qui décrit ses taches en utilisant les plugins de gradle si nécessaire : https://plugins.gradle.org/ 

-> Pour aller plus loin d'autres exercices sont disponible ici : 
https://github.com/praqma-training/gradle-katas