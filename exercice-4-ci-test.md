# Ajouter des tests à notre projets et les faire tourner de manière automatisés
Cet exercice va permettre d'executer les tests de manières automatisés avant la construction de l'archive

## Ajout de test et lancement sur le projet en PHP
* Des tests existent dans l'application
* POur les lancers nous utilisons PHPUnit
* Pour cela on ajoute une tache dans le build.gradle qui va se charger de lancer les tests
```
task test(type:Exec, dependsOn: installDeps) {
  //println 'Executing tests'
  executable 'sh'
  args '-c', "php \
    './project/vendor/phpunit/phpunit/phpunit' \
    --configuration='./project/phpunit.xml' \
    --log-junit='./logs/unitreport.xml'\
    ./project/tests"
}
```
* Pour lancer les tests, on se connecte au conteneur 
```
docker run -it my-gradle bash
```

* Puis on lance les tests avec la tache gradle 
```
gradle test
```
* Vous obtenez alors le résultat de l'éxecution des tests : 
```
RRORS!
Tests: 20, Assertions: 3, Errors: 18.

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':test'.
> Process 'command 'sh'' finished with non-zero exit value 2

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.

* Get more help at https://help.gradle.org

BUILD FAILED in 40s
4 actionable tasks: 3 executed, 1 up-to-date
```
* Certains tests ont échoués car il s'agit de test d'integration, qui nécessite une connexion à la base de donnée, notre application dans le conteneur n'est pas correctement configuré pour utiliser la base de données

* On peut alors : 
  * Soit corrigé l'environnement pour que les tests puissent tourner (et corriger le code si nécessaire), cela est généralement fait en collaboration avec les développeurs car nécessite des compétences dans le langage de programmation de l'application
  * Soit dire à gradle d'ignorer le résultat du test et de continuer le build 

* Pour la deuxième solution, sur une tâche de type exec on ajoute la propriété (la propriété est différente selon le type de tâche): 
```
ignoreExitValue true
```

* Nous pouvons alors remettre la dépendance à notre tache de tests et lancer la tâche de package et d'envoi sur nexus :

```
gradle up
```

## Ajout de test et lancement sur votre projet
* Ecrivez quelques tests (unitaire ou fonctionnel) pour votre projet
* Dans votre build.gradle ajouter une tache pour faire tourner ces tests 
* Rendre la tache de création de l'archive dépendante de vos tests
