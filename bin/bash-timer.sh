#!/bin/bash

# we need bash >=4.4.

declare BASHTIMER_TIME
declare BASHTIMER_LAST_CMD

# save time in a temporary file and remove it once it's not used anymore
BashTimer::setTime(){
    printf -v BASHTIMER_TIME '%(%s)T'
}

# we could convert function to arithmetic
BashTimer::Convert(){
	local time="$1"
 	local days=$(( time / 60 / 60 / 24 ))
 	local hours=$(( time / 60 / 60 %24 ))
 	local min=$(( time / 60 % 60 ))
 	local sec=$((time % 60))

	(( days > 0 ))	&& printf '%s d ' "$days"
	(( hours > 0 )) && printf '%s h ' "$days"
	(( min > 0 ))	&& printf '%s m ' "$min"
	printf '%s s' "$sec"
}

BashTimer::PS1(){
    local _t timetaken

    [[ -z "$BASHTIMER_LAST_CMD" ]] && {
        printf '0s'
        BashTimer::setTime
        return
    }

    printf -v _t '%(%s)T'

    ((timetaken=_t - BASHTIMER_TIME))
        
    BashTimer::Convert "$timetaken"

    BashTimer::setTime
    BASHTIMER_LAST_CMD=""
}

BashTimer::Prompt(){
    local _t timetaken

    [[ -z "$BASHTIMER_LAST_CMD" ]] && {
        BashTimer::setTime
        return
    }
    printf -v _t '%(%s)T'

    ((timetaken=_t - BASHTIMER_TIME))

    printf 'Time : %s \n' "$(BashTimer::Convert "$timetaken")"

    BashTimer::setTime
    BASHTIMER_LAST_CMD=""
}

BashTimer::Reset(){
    local _p="$BASH_COMMAND"
    case "$_p" in
        "history"*)     return  ;;
        "BashTimer"*)   return  ;;
        ""|*)           BashTimer::setTime ;;
    esac
    BASHTIMER_LAST_CMD="$_p"
}

trap 'BashTimer::Reset' DEBUG
