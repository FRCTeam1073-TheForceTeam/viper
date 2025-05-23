#!/bin/bash

set -e

team=$1

if [[ ! "$team" =~ ^(ftc)?[0-9]+$ ]]
then
	echo "Expected team number as first argument";
	exit 1;
fi

teamNum="${team#ftc}"

if [ ! -e local.data/viper$team ]
then
	ssh source.ostermiller.org "if [ ! -e /git/viper${team}data.git ]; then cp -vr /git/viperbasedata.git /git/viper${team}data.git; fi"
	git clone source.ostermiller.org:/git/viper${team}data.git local.data/viper$team
fi

sed -i "s/TEAM/$team/g" local.data/viper$team/.*ht*
sed -i "s/TEAM/$teamNum/g" local.data/viper$team/local.css local.data/viper$team/local.js

cd local.data/viper$team
git pull
if ! grep -q admin .htpasswd
then
	echo "Enter admin password"
	htpasswd -B .htpasswd admin
fi
if ! grep -q scouter .htpasswd
then
	echo "Enter scouter password"
	htpasswd -B .htpasswd scouter
fi
if ! grep -q guest .htpasswd
then
	echo "Enter guest password"
	htpasswd -B .htpasswd guest
fi
git add .
git commit -m 'initial setup' || true
git push || true

foreachserver live "cd sites/viper/local.data; if [ ! -e $team ]; then git clone source.ostermiller.org:/git/viper${team}data.git $team; fi; cd $team; git pull; sudo cp .htsite /etc/apache2/sites-available/viper$team.conf; sudo a2ensite viper$team; sudo service apache2 reload"
ssh web1 "cd sites/viper/; ./script/db-import-site.sh local.data/$team"
cd ../..
echo "Your team's cloud hosted viper site is ready:

https://$team.viperscout.com/

You can use these user names to access the site
using the passwords you chose:

admin - Full access: create events and edit data

scouter - Can upload scouting data

guest - Read-only access"
