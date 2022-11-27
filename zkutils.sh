#! /bin/bash

newUSER='_zerok'
newControllerUSER='_zerokc'
PROJECT_PATH=''
APPLICATION=0
VCODE_APPLICATION=0

helpFunction()
{
   echo ""
   echo "Usage: $0 [options]
         Options are listed below:
         -a [start|stop] \t\t\t//starts the application
         -va \t\t\t\t\t//opens the project in VS Code from $newUSER user"

   exit 1 # Exit script after printing help
}

while [ $# -ne 0 ]; do
    case "$1" in
        -va)
             VCODE_APPLICATION=1
             shift;
             ;;
        -p)
             PROJECT_PATH=$2
             shift; shift
             ;;
        -a)
             APPLICATION=1
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

sh ./setup-users.sh
sh ./setup-transparent-proxy.sh
sh ./setup-project.sh

BASENAME='EchoRelayApp'
# ################################## COPYING PROJECT
# if [ -z "$PROJECT_PATH" ]
# then
# 	BASENAME='EchoRelayApp'
# else
# 	sudo mkdir /var/$newUSER/projects/
# 	BASENAME=`basename $PROJECT_PATH`
# 	sudo rm -rf /var/$newUSER/projects/$BASENAME
# 	sudo mkdir /var/$newUSER/projects/$BASENAME
# 	sudo cp -R $PROJECT_PATH/* /var/$newUSER/projects/$BASENAME/
# 	sudo chown -R $newUSER /var/$newUSER
# fi

################################## START APPLICATION IN VCODE
if [ $VCODE_APPLICATION == 1 ]
then
     echo 'Starting VS Code'
     sh ./newtab.sh su $newUSER -c "cd /var/$newUSER/projects/$BASENAME/ && npm install && /Applications/Visual[[:space:]]Studio[[:space:]]Code.app/Contents/MacOS/Electron ."
fi

################################## START APPLICATOIN
if [ $APPLICATION == 1 ]
then
     echo 'Starting application'
     sh ./newtab.sh su $newUSER -c "cd /var/$newUSER/projects/$BASENAME/ && npm install && CONF_FILE=./configuration/service1-definition.yaml npm start"
fi








