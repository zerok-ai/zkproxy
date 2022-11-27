#! /bin/bash

newUSER='_zerok'
newControllerUSER='_zerokc'
INSTALL_MITM=0
USER_ACTION=0
PROJECT_FROM_GIT=0
DELETE_PROJECT_DIR=''
CONTROLLER_USER_ACTION=0
PROJECT_PATH=''
SERVER_REPLY=0
TRANSPARENT_MODE=0
REVERSE_MODE=0
SERVER_REPLY_FILE=''
CLIENT_REPLY=0
CLIENT_REPLY_FILE=''
APPLICATION=0
VCODE_APPLICATION=0

helpFunction()
{
   echo ""
   #-g git-repo-url \t\t\t//clones a git repo and uses that as a project
   echo "Usage: $0 [options]
         Options are listed below:
         -m \t\t\t\t\t//installs the mitmproxy if not already present
         -u \t\t\t\t\t//creates a user $newUSER
         -cu \t\t\t\t\t//creates a user $newControllerUSER
         -p project-path \t\t\t//copies the project from passed project-path to $newUSER's home directory
         -t \t\t\t\t\t//starts the mitmproxy (@8080) in transparent mode
         -r \t\t\t\t\t//starts the mitmproxy (@8081) in reverse proxy mode
         -sr
         -cr
         -s [start|stop] -sf {file-path} \t//starts the mitmproxy (@8080) in server-replay mode using the file passed against -sf
         -c [start|stop] -cf {file-path} \t//starts the mitmproxy (@8081) in client-replay mode using the file passed against -cf
         -a [start|stop] \t\t\t//starts the application
         -va \t\t\t\t\t//opens the project in VS Code from $newUSER user"

   exit 1 # Exit script after printing help
}

newtabi(){
     whitespace="[[:space:]]"
     COMMAND_TO_RUN=''
     for i in "$@"
     do
         if [[ $i =~ $whitespace ]]
         then
             i=\'$i\'
         fi
         COMMAND_TO_RUN="$COMMAND_TO_RUN $i"
     done
     echo $COMMAND_TO_RUN
     osascript \
     -e 'tell application "iTerm2" to tell current window to set newWindow to (create tab with default profile)'\
     -e "tell application \"iTerm2\" to tell current session of newWindow to write text \"${COMMAND_TO_RUN}\""
}


while [ $# -ne 0 ]; do
    case "$1" in
        -m)
		   INSTALL_MITM=1
             shift;
             ;;
        -va)
             VCODE_APPLICATION=1
             shift;
             ;;
        -u)
             USER_ACTION=1
             shift;
             ;;
        -cu)
             CONTROLLER_USER_ACTION=1
             shift;
             ;;
        -p)
             PROJECT_PATH=$2
             shift; shift
             ;;
        -g)
             PROJECT_FROM_GIT=$2
             shift; shift
             ;;
        -s)
             SERVER_REPLY=$2
             shift; shift
             ;;
        -sf)
             SERVER_REPLY_FILE=$2
             shift; shift
             ;;
        -c)
             CLIENT_REPLY=$2
             shift; shift
             ;;
        -cf)
             CLIENT_REPLY_FILE=$2
             shift; shift
             ;;
        -a)
             APPLICATION=1
             shift;
             ;;
        -t)
             TRANSPARENT_MODE=1
             shift;
             ;;
        -r)
             REVERSE_MODE=1
             shift;
             ;;
        -sr)
             SERVER_REPLY=1
             shift;
             ;;
        -cr)
             CLIENT_REPLY=1
             shift;
             ;;
        -h)
             helpFunction
             exit 2

             ;;
        -*)
             echo "Unknown option: $1" >&2
             helpFunction
             exit 2
             ;;
        *)
             break
             ;;
    esac
done

################################## INSTALLING PROXY
if [ $INSTALL_MITM == 1 ]
then
     #Check and Install mitmproxy
     brew list mitmproxy || brew install mitmproxy
fi

################################## CREATING USER
if [ $USER_ACTION == 1 ]
then
	
     userALreadyPresent=`dscacheutil -q user | grep -sw "name: $newUSER" || echo 'no'`
     if [ $USER_ACTION == 'no' ]
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
else
     echo "Skipping user setup"
fi

################################## CREATING CONTROLLER USER
if [ $CONTROLLER_USER_ACTION == 1 ]
then
     userALreadyPresent=`dscacheutil -q user | grep -sw "name: $newControllerUSER" || echo 'no'`
     if [ $USER_ACTION == 'no' ]
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
     	sudo chown $newControllerUSER /var/$newControllerUSER

     	#Set the password for the new user
     	sudo dscl . -passwd /Users/$newControllerUSER 12345
     else
          echo "User $newControllerUSER already present"
     fi
else
     echo "Skipping controller user setup"
fi


################################## PROJECT FROM GIT
# if [ -z "$PROJECT_FROM_GIT" ]
# then
#      echo 'Project not from git'
# else
#      rm -rf .zktmp
#      mkdir .zktmp
#      cd .zktmp
#      echo "Cloning $PROJECT_FROM_GIT"
#      git clone $PROJECT_FROM_GIT app
#      cd app
#      PROJECT_PATH=`pwd`
#      DELETE_PROJECT_DIR=1
#      cd ../..
# fi

################################## COPYING PROJECT
if [ -z "$PROJECT_PATH" ]
then
	echo "Skipping project setup"
else
	sudo mkdir /var/$newUSER/projects/
	BASENAME=`basename $PROJECT_PATH`
     sudo rm -rf /var/$newUSER/projects/$BASENAME
	sudo mkdir /var/$newUSER/projects/$BASENAME
	sudo cp -R $PROJECT_PATH/* /var/$newUSER/projects/$BASENAME/
	sudo chown -R $newUSER /var/$newUSER

     # if [ $DELETE_PROJECT_DIR == 1 ]
     # then
     #      rm -rf $PROJECT_PATH
     # fi
fi

################################## START SERVER REPLAY
# newtabi su $newControllerUSER -c 'mitmproxy --mode reverse:http://localhost:3000@8081'
#https://askubuntu.com/a/881237/1648426
#Next to try
#https://groups.google.com/g/mitmproxy/c/C5ZGSqqkIE4
# if [ -z "$SERVER_REPLY_FILE" ]
# then
#      echo 'Skipping Server replay'
# else
#      echo 'Starting in server replay mode'
#      newtabi su $newControllerUSER -c 'mitmdump --mode transparent --showhost -S $SERVER_REPLY_FILE'
# fi
if [ "$SERVER_REPLY" == 1 ]
then
     echo 'Starting in server replay mode'
     newtabi su $newControllerUSER -c 'mitmdump --mode transparent --showhost -S /var/_zerokc/outputs/zkproxy-demo-server.flow'
fi

################################## START TRANSPARENT MODE
if [ $TRANSPARENT_MODE == 1 ]
then
     echo 'Starting in transparent mode'
     newtabi su $newControllerUSER -c 'mitmdump --mode transparent'
fi

################################## START REVERSE PROXY MODE
if [ $REVERSE_MODE == 1 ]
then
     echo 'Starting in reverse mode'
     newtabi su $newControllerUSER -c 'mitmproxy --mode reverse:http://localhost:9091@8081'
fi

################################## START CLIENT REPLAY
# if [ -z "$CLIENT_REPLY_FILE" ]
# then
#      echo 'Skipping Client replay'
# else
#      echo 'Starting in client replay mode'
#      newtabi su $newControllerUSER -c 'mitmdump -nC $CLIENT_REPLY_FILE'
# fi
if [ "$CLIENT_REPLY" == 1 ]
then
     echo 'Starting in client replay mode'
     newtabi su $newControllerUSER -c 'mitmdump -nC /var/_zerokc/outputs/zkproxy-demo-client.flow'
fi

################################## START APPLICATOIN
if [ $APPLICATION == 1 ]
then
     echo 'Starting application'
     newtabi su $newUSER -c "cd /var/$newUSER/projects/$BASENAME/ && npm install && CONF_FILE=./configuration/service1-definition.yaml npm start"
fi

################################## START APPLICATION IN VCODE
if [ $VCODE_APPLICATION == 1 ]
then
     echo 'Starting VS Code'
     newtabi su $newUSER -c "cd /var/$newUSER/projects/$BASENAME/ && npm install && npm install prom-client && /Applications/Visual[[:space:]]Studio[[:space:]]Code.app/Contents/MacOS/Electron ."
     # newtabi su $newUSER -c "\"/Applications/Visual\ Studio\ Code.app/Contents/MacOS/Electron\""
fi


#CONF_FILE=./configuration/service1-definition.yaml && npm start






