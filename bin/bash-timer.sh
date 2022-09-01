#!/bin/bash

# we need bash >=4.4.

declare BASHTIMER_TTIME
declare BASHTIMER_TIME
declare BASHTIMER_LAST_CMD

declare -A BASHTIMER_DEFAULT_COLOR=(
    [ok]="\033[1;32m"
    [err]="\033[0;31m"
    [reset]="\033[0m"
)
declare -A BASHTIMER_COLOR

# save time in a temporary file and remove it once it's not used anymore
BashTimer::setTime(){
    printf -v BASHTIMER_TIME '%(%H:%M:%S)T'
    printf -v BASHTIMER_TTIME '%(%s)T'
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

    ((timetaken=_t - BASHTIMER_TTIME))
        
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

    ((timetaken=_t - BASHTIMER_TTIME))

    printf 'Time : %s \n' "$(BashTimer::Convert "$timetaken")"

    BashTimer::setTime
    BASHTIMER_LAST_CMD=""
}

BashTimer::FancyPrompt(){
    local _t timetaken _n
    [[ -z "$BASHTIMER_LAST_CMD" ]] && {
        BashTimer::setTime
        return
    }
    printf -v _t '%(%s)T'
    printf -v _n '%(%H:%M:%S)T'

    ((timetaken=_t - BASHTIMER_TTIME))

    if (( timetaken < 3 )); then
        col="${BASHTIMER_COLOR[ok]:-${BASHTIMER_DEFAULT_COLOR[ok]}}"
    else
        col="${BASHTIMER_COLOR[err]:-${BASHTIMER_DEFAULT_COLOR[err]}}"
    fi

    out="[ Taken : $(BashTimer::Convert "$timetaken") | Start Time : $BASHTIMER_TIME , End Time : $_n ]"

    printf "%b%$((COLUMNS - ${#out} + 20))s%b\n" "$col" "$out" "${BASHTIMER_COLOR[reset]:-${BASHTIMER_DEFAULT_COLOR[reset]}}"

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
