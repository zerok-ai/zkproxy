#! /bin/bash

newUSER='_zerok'
newControllerUSER='_zerokc'

echo "Setting up users"
################################## CREATING USER
userALreadyPresent=`dscacheutil -q user | grep -sw "name: $newUSER" || echo 'no'`
if [ "$userALreadyPresent" == 'no' ]
then
  	#Extract the last UID
	lastUID=`dscacheutil -q user | grep uid | grep -Eo '[0-9]{1,4}' | sort -g | tail -1`
	newUID=$(( lastUID+1 ))
	echo "Found UID : $lastUID and generated new UID : $newUID"

	#Create a new user
	sudo dscl . -create /Users/$newUSER UniqueID $newUID
	sudo dscl . -create /Users/$newUSER UserShell /bin/bash
	sudo dscl . -create /Users/$newUSER NFSHomeDirectory /var/$newUSER
	sudo dscl . -create /Users/$newUSER PrimaryGroupID $newUID
	sudo mkdir /var/$newUSER
	sudo chown $newUSER /var/$newUSER

	#Set the password for the new user
	sudo dscl . -passwd /Users/$newUSER 12345
else
  	echo "User $newUSER already present"
fi

################################## CREATING CONTROLLER USER
userALreadyPresent=`dscacheutil -q user | grep -sw "name: $newControllerUSER" || echo 'no'`
if [ "$userALreadyPresent" == 'no' ]
then
	#Extract the last UID
	lastUID=`dscacheutil -q user | grep uid | grep -Eo '[0-9]{1,4}' | sort -g | tail -1`
	newUID=$(( lastUID+1 ))
	echo "Found UID : $lastUID and generated new UID : $newUID"

	#Create a new user
	sudo dscl . -create /Users/$newControllerUSER UniqueID $newUID
	sudo dscl . -create /Users/$newControllerUSER UserShell /bin/bash
	sudo dscl . -create /Users/$newControllerUSER NFSHomeDirectory /var/$newControllerUSER
	sudo dscl . -create /Users/$newControllerUSER PrimaryGroupID $newUID
	sudo mkdir /var/$newControllerUSER
	sudo mkdir /var/$newControllerUSER/replays
	sudo cp ./replays/* /var/$newControllerUSER/replays/
	sudo chown $newControllerUSER /var/$newControllerUSER

	#Set the password for the new user
	sudo dscl . -passwd /Users/$newControllerUSER 12345
else
  	echo "User $newControllerUSER already present"
fi