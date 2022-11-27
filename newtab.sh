#! /bin/bash

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