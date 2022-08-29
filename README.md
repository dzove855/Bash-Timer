# Bash-timer

This command will print the timetaken of each command.
You can setup it on PS1 or as PROMPT_COMMAND

# setup
```
# Add the following line in your bashrc
source PATH/TO/FILE/bash-timer.sh

# note the single quote!
export PROMPT_COMMAND='$(BashTimer::Prompt)'
```
