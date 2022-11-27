#! /bin/bash

newUSER='_zerok'
newControllerUSER='_zerokc'
REPLAY_ID='he63ei737ei3i7'
SERVER_REPLAY="$REPLAY_ID.egress"
CLIENT_REPLAY="$REPLAY_ID.ingress"
EGRESS=0
EGRESS_KILL=0
INGRESS_KILL=0
INGRESS=0
REPLAY_ID=''


helpFunction()
{
   echo ""
   echo "Usage: $0 [options]
         Options are listed below:
         -f {replay id} \t\t\t//egress replay id
         -i \t\t\t\t\t//start server replay
         -r \t\t\t\t\t//start client replay
         -k \t\t\t\t\t//kills the egress replay"

   exit 1 # Exit script after printing help
}

while [ $# -ne 0 ]; do
    case "$1" in
        -f)
             REPLAY_ID=$2
             SERVER_REPLAY="$REPLAY_ID.egress"
			 CLIENT_REPLAY="$REPLAY_ID.ingress"
             shift; shift
             ;;
        -i)
             EGRESS=1
             shift;
             ;;

        -k)
             EGRESS_KILL=1
             shift;
             ;;
        -r)
             INGRESS=1
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

if [ $EGRESS_KILL == 1 ]
then
	FOUND_PID=`sh ./getpid.sh 8080`
	if [ -z $FOUND_PID ]
	then
		echo 'Proxy is not running'
	else
		echo 'Stopping the egress replay'
		kill -9 $FOUND_PID
	fi
fi

if [ $EGRESS == 1 ]
then
	FOUND_PID=`sh ./getpid.sh 8080`
	if [ -z $FOUND_PID ]
	then
		echo 'Starting in server replay mode'
		su $newControllerUSER -c "mitmdump --mode transparent --showhost -S /var/_zerokc/replays/$SERVER_REPLAY &"
		# sh ./newtab.sh su $newControllerUSER -c "mitmdump --mode transparent --showhost -S /var/_zerokc/replays/$SERVER_REPLAY &"
	else
		echo "Proxy is already running at 8080 with PID $FOUND_PID"
	fi
fi

if [ $INGRESS_KILL == 1 ]
then
	FOUND_PID=`sh ./getpid.sh 8081`
	if [ -z $FOUND_PID ]
	then
		echo 'Proxy is not running'
	else
		echo 'Stopping the ingress replay'
		kill -9 $FOUND_PID
	fi
fi

if [ $INGRESS == 1 ]
then
	FOUND_PID=`sh ./getpid.sh 8081`
	if [ -z $FOUND_PID ]
	then
		echo 'Starting in client replay mode'
		su $newControllerUSER -c "mitmdump -nC /var/_zerokc/replays/$CLIENT_REPLAY &"
	else
		echo "Proxy is already running at 8081 with PID $FOUND_PID"
	fi
fi










