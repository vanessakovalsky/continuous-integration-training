# Controler la qualité du code

Cet exercice a pour objectifs :
* d'ajouter des contrôles qualités à notre code
* de le faire tourner par le serveur d'intégration continue
* de publier des rapports d'execution sur le serveur d'intégration continue

## Ajouter des contrôle qualité à notre code
* Pour commencer il faut séléctionner les outils que nous allons utiliser :
* * phploc: fournit des informations sur le nombre de ligne de code et la complexité de celui ci
* * phpcpd : fournit des informations sur les copier coller
* * phpmd : détection de potentiel problème dans le code (bugs, complexité, paramètres et méthodes inutilisés)
* * phpdox : permet de générer de la documentation à partir des commentaires du code
* * phpcs : permet d'analyser le code et de détecter les écarts avec les normes de codage
* Nous allons donc ajouter l'appel à ces différents outils dans notre build.gradle :
```
task phploc(type: Exec, description: 'Measure project size using PHPLOC') {
	executable 'sh'
	args '-c',"/home/ubuntu/tools/phploc --count-tests \
    --log-csv='./build/reports/phploc.csv' \
    --log-xml='./build/reports/phploc.xml' \
     ./app"
}

task phpmd (type : Exec, description : "Perform project mess detection using PHPMD, and Creating a log file for the Continuous Integration Server"){
	executable 'sh'
	args '-c',"/home/ubuntu/tools/phpmd ./app \
    xml './phpmd.xml' \
    --reportfile './build/reports/phpmd.xml'\
    --ignore-violations-on-exit"
}

task phpcpd (type : Exec, description : "Find duplicate code using PHPCPD and log result in XML format."){
	executable 'sh'
	args '-c',"/home/ubuntu/tools/phpcpd \
    --log-pmd './build/reports/pmd-cpd.xml' \
    ./app"
}

task phpcs (type : Exec, description : "Find Coding Standard Violations using PHP_CodeSniffer"){
	executable 'sh'
	args '-c',"/home/ubuntu/tools/phpcs \
    --report=checkstyle \
    --report-file='./build/reports/checkstyle.xml' \
    --standard=PSR2 \
    --extensions=php \
    --ignore=autoload.php \
    --runtime-set ignore_errors_on_exit 1 \
    --runtime-set ignore_warnings_on_exit 1 \
    ./app/"
}

task phpdox (type : Exec, description : "Generating Docs enriched with pmd, checkstyle, phpcs,phpunit,phploc"){
	executable 'sh'
	args '-c',"/home/ubuntu/tools/phpdox \
    -f ./phpdox.xml"
}
```
* NB : le fichier buid.gradle a été ajouté au dépôt source laravel-kingdomino puisqu'il est lié à ce projet
* NB2 : pour executer ce script, il est nécessaire que les outils utilisés soient installés sur la machine (pour l'éxecuter en local, il faudra donc modifier l'environnement d'execution de gradle pour installer ces outils, ce n'est pas fait dans cet exemple)

## Intégrer l'analyse qualité à notre job Jenkins
* Dans le build de notre projet, ajouter les étapes correspondantes au script gradle :
* * phpcs
* * phpmd
* * phpdox
* * phpcpd
* * phploc 
* Lancer un build, puis allez voir dans le workspace du produit :
--> Les résultats de ses différentes étapes sont maintenant disponibles sous forme de fichier XML ou dans la sortie Console Output
* NB : pour pouvoir faire tourner ces taches, les outils ont été installé sur le serveur qui fait tourner Jenkins et sur les différents agents qui executent les jobs

## Afficher les résultats sous formes de rapports
* Pour afficher des rapports nous allons avoir besoin de différents plugins de Jenkins, qui permettent à partir des logs générés au format XML de créer des rapports graphiques :
* * Warnings Next Generation : récupère de nombreux logs et affiche au format graphique (CPD, MD, CS)
* * xUnit : récupère les logs des tests et affiche un rapport
* * Plot : affiche des graphiques à partirs de données au format CSV (PHPLOC)
* * HTML Publisher : pour publier la documentation généré par PHPDox
* Pour installer les plugins, rendez vous dans Manage Jenkins > Plugin Manager 
* Chercher et cocher ces 3 plugins 
* Cliquer sur Install without restart
* Il reste maintenant à ajouter les étapes de buildsp our la publication des rapports
* Retourner dans la configuration du Job
* Dans l'onglet Post Build, ajouter une action
* *  Plot Build data :
* * * Data serie file : chemin vers le fichier CSV, ici : build/reports/phploc.csv
* * * Choisir Load Data from CSV File
* * Record Compiler warning and static analysis results
* * * Static Analysis
* * * * Tools : PHP Code sniffer
* * * * Report file pattern :build/reports/checkstyle.xml
* * * Cliquer sur add tool
* * * * Tool : CPD
* * * * Report file pattern : build/reports/pmd-cpd.xml
* * * Cliquer sur add tool
* * * * Tool : PMD
* * * * Report file pattern : build/reports/phpmd.xml
* * Publish xUnit test result report
* * * Report type  : PHP Unit
* * * Patter : build/reports/unitreport.xml
* * Publish HTML Report
* * * HTML directory to archive	: reports/api

--> Votre chaine est maintenant configuré avec l'analyse qualité et la publication des rapports associés côté Jenkins, félicitations :)
