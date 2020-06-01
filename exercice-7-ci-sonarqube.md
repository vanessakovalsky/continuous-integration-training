# Intégration des resultats de Jenkins dans Sonar

Cet exercice a pour objectif :
* d'intégrer les résultats obtenus lors des builds construits dans les exercices précédents à SonarQube


## Pré-requis

* Avoir un sonarqube installé (possible de le faire en local avec le docker-compose)

## Installation et configuration du plugin pour Sonar dans Jenkins
* Aller dans Manage Jenkins > Manage plugin
* Dans Available, chercher le plugin SonarQube Scanner	
* Cocher la case devant le plugin
* Cliquer sur install without restart
* Le plugin est maintenant installé
* Dans Manage Jenkins > Configure system, chercher la section SonarQube servers :
* * Cocher la case : Enable ....
* * Name : Le nom de votre serveur
* * URL : adresse de votre serveur 
* Sonar et Jenkins sont maintenant configurés

## Ajouter les résultats du build dans Sonar
* Ajoutons une dépendance à un plugin sonarqube dans notre script gradle :
```
buildscript {
  repositories {
    maven {
      url "https://plugins.gradle.org/m2/"
    }
  }
  dependencies {
    classpath "gradle.plugin.org.swissphpfriends:php-build-plugin:0.1-SNAPSHOT"
    classpath "org.sonarsource.scanner.gradle:sonarqube-gradle-plugin:2.8"
  }
}

apply plugin: "org.hasnat.php-build-plugin"
apply plugin: "distribution"
apply plugin: "maven-publish"
apply plugin: "org.sonarqube"
```
* A la fin du build.gradle, on ajoute la configuration de sonarqube
```
sonarqube {
    properties {
        property "sonar.sources", "app"
        property "sonar.php.tests.reportPath", "build/reports/unitreport.xml"
    }
}
```
* Dans la configuration du job de notre projet
* Dans build environment cocher la case :
Prepare SonarQube Scanner environment 
* Ajouter une étape de build de type Gradle
* La tache a appelé est alors : sonarqube
* Vous pouvez lancer le build
* A la fin du build un lien vers votre sonarqube apparait, ainsi qu'un badge pour dire que les tests de sonar sont passé.

-> L'ensemble des exercices est terminé, à vous de jouer pour adapter à vos projets, et à ce que vous souhaitez faire.
