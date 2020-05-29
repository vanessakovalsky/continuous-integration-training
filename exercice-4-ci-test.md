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

## Ajout de test et lancement sur votre projet
* Ecrivez quelques tests (unitaire ou fonctionnel) pour votre projet
* Dans votre build.gradle ajouter une tache pour faire tourner ces tests 
* Rendre la tache de création de l'archive dépendante de vos tests