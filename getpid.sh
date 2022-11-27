#! /bin/bash

PORT_TO_BE_SEARCHED=$1
FOUND_PID=`lsof -i :8080 | awk '{print $2}' | tail -1`
echo $FOUND_PID
