# Bash-timer

This command will print the timetaken of each command.
You can setup it on PS1 or as PROMPT_COMMAND

# setup
```
# Add the following line in your bashrc
source PATH/TO/FILE/bash-timer.sh

# note the single quote!
export PROMPT_COMMAND='BashTimer::Prompt'
```

# Customization
You can choose between 3 differents output commands
#### PS1
To set the output inside your PS1, you will need to add this to your PS1 = $(BashTimer::PS1)

#### Basic Prompt
The basic prompt will only print the time taken on the new line, to export this:
```
export PROMPT_COMMAND='BashTimer::Prompt'
```

#### Fancy Prompt
The fancy Prompt allows you to customize the prompt and have the output to the right with some colours.

In order to use the fancy Prompt you will need to export this:
```
export PROMPT_COMMAND='BashTimer::FancyPrompt'
```

Customization:
```
# the date output format
BASHTIMER_TIME_FORMAT="%H:%M:%S"

# the output format: 
#   %r == return code 
#   %t == time taken
#   %s == start time
#   %e == end time
BASHTIMER_OUTPUT_FORMAT="[ RC %r, Taken %t | Start Time: %s , End Time: %e ]"

# define colors for the output
BASHTIMER_COLOR=(
    [ok]="\033[1;32m"
    [err]="\033[0;31m"
    [reset]="\033[0m"
)

# Ignore commands where the timer should not run
BASHTIMER_IGNORE_COMMAND+=("history" "BashTimer") 
```


![Alt text](pic/bashtimer.png?raw=true "Bashtimer Picture")
