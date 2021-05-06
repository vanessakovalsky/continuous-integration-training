#!/bin/bash

## On met à jour le systeme pour pouvoir insaller
    sudo apt update -y

    ## Installer le pré-requis Java 
    sudo apt -y install openjdk-11-jdk

    ## Installer la version stable de Jenkins et ses prérequis en suivant la documentation officielle : https://www.jenkins.io/doc/book/installing/linux
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
    sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
        /etc/apt/sources.list.d/jenkins.list'
    sudo apt -y update
    sudo apt -y install jenkins

## Démarrer le service Jenkins

sudo service start jenkins

sudo systemctl daemon-reload
sudo systemctl start jenkins

## Créer un utilisateur userjob avec son home sur la partition créé

sudo mkdir -p /home/userjob

sudo useradd -m userjob -d /home/userjob

## Lui donner les permissions (via le fichier sudoers) d'utiliser apt (et seulement apt pas l'ensemble des droits admin)

echo 'userjob ALL=(ALL:ALL) /usr/bin/apt' | sudo EDITOR='tee -a' visudo

## Afficher à la fin de l'execution du script le contenu du fichier /var/jenkins_home/secrets/initialAdminPassword pour permettre de récupérer le mot de passe

cat /var/jenkins_home/secrets/initialAdminPassword