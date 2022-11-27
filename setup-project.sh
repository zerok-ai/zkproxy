#! /bin/bash

newUSER='_zerok'
newControllerUSER='_zerokc'
PROJECT_PATH="$PWD/EchoRelayApp"
echo $PROJECT_PATH

echo "Setting up project"
################################## SETUP PROJECT
userALreadyPresent=`dscacheutil -q user | grep -sw "name: $newUSER" || echo 'no'`
if [ "$userALreadyPresent" == 'no' ]
then
	echo "User $newUSER doesn't exists"
else
	echo "Copying project ..."
  	sudo mkdir /var/$newUSER/projects/
	BASENAME=`basename $PROJECT_PATH`
	sudo rm -rf /var/$newUSER/projects/$BASENAME
	sudo mkdir /var/$newUSER/projects/$BASENAME
	sudo cp -R $PROJECT_PATH/* /var/$newUSER/projects/$BASENAME/
	sudo chown -R $newUSER /var/$newUSER
	su $newUSER -c "cd /var/$newUSER/projects/$BASENAME/ && npm install"
fi