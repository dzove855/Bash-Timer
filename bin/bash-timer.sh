#!/bin/bash

# we need bash >=4.4.

declare BASHTIMER_TTIME
declare BASHTIMER_TIME
declare BASHTIMER_TIME_FORMAT="%H:%M:%S"
declare BASHTIMER_LAST_CMD
declare BASHTIMER_OUTPUT_FORMAT="[ RC %r, Taken %t | Start Time: %s , End Time: %e ]"

declare -A BASHTIMER_DEFAULT_COLOR=(
    [ok]="\033[1;32m"
    [err]="\033[0;31m"
    [reset]="\033[0m"
)
declare -A BASHTIMER_COLOR
declare -a BASHTIMER_IGNORE_COMMAND=("history" "BashTimer")

# save time in a temporary file and remove it once it's not used anymore
BashTimer::setTime(){
    printf -v BASHTIMER_TIME "%($BASHTIMER_TIME_FORMAT)T"
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

    BASHTIMER_LAST_CMD=""
}

BashTimer::FancyFormatParser(){
    local -A parser=(
        [%t]="$timetaken"
        [%s]="$BASHTIMER_TIME"
        [%e]="$_n"
        [%r]="$_r"
    )
    local _o="$BASHTIMER_OUTPUT_FORMAT" key

    for key in "${!parser[@]}"; do
        _o="${_o//$key/${parser[$key]}}"
    done

    printf '%s' "$_o"
}

BashTimer::FancyPrompt(){
    local _t timetaken _n _r="$?"
    [[ -z "$BASHTIMER_LAST_CMD" ]] && {
        BashTimer::setTime
        return
    }
    printf -v _t '%(%s)T'
    printf -v _n "%($BASHTIMER_TIME_FORMAT)T"

    ((timetaken=_t - BASHTIMER_TTIME))

    if (( timetaken < 3 )) && [[ $_r == 0 ]]; then
        col="${BASHTIMER_COLOR[ok]:-${BASHTIMER_DEFAULT_COLOR[ok]}}"
    else
        col="${BASHTIMER_COLOR[err]:-${BASHTIMER_DEFAULT_COLOR[err]}}"
    fi

    printf "%b%${COLUMNS}s%b\n" "$col" "$(BashTimer::FancyFormatParser)" "${BASHTIMER_COLOR[reset]:-${BASHTIMER_DEFAULT_COLOR[reset]}}"

    BASHTIMER_LAST_CMD=""

}

BashTimer::Reset(){
    local _p="$BASH_COMMAND" entry
    for entry  in "${BASHTIMER_IGNORE_COMMAND[@]}"; do
        [[ "$_p" =~ $entry ]] && return
    done

    BashTimer::setTime
    BASHTIMER_LAST_CMD="$_p"
}

trap 'BashTimer::Reset' DEBUG
