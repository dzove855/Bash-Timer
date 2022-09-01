#!/bin/bash

# we need bash >=4.4.

declare BASHTIMER_CACHE_DIR=$HOME/.cache/bash-timer

# create needed directorys
BashTimer::setup(){
    [[ ! -d "$BASHTIMER_CACHE_DIR" ]] && mkdir "$BASHTIMER_CACHE_DIR"
}

# save time in a temporary file and remove it once it's not used anymore
BashTimer::setTime(){
    printf '%(%s)T' > "$BASHTIMER_CACHE_DIR/$$"
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
    local _o _t timetaken _p
    _p="$(<"$BASHTIMER_CACHE_DIR/cmd.$$")"    

    [[ -z "$_p" ]] && {
        printf '0s'
        BashTimer::setTime
        return
    }

    _o="$(<"$BASHTIMER_CACHE_DIR/$$")"
    printf -v _t '%(%s)T'

    ((timetaken=_t - _o))
        
    BashTimer::Convert "$timetaken"

    BashTimer::setTime
    : > "$BASHTIMER_CACHE_DIR/cmd.$$"
}

BashTimer::Prompt(){
    local _o _t timetaken _p
    _p="$(<"$BASHTIMER_CACHE_DIR/cmd.$$")"

    [[ -z "$_p" ]] && {
        BashTimer::setTime
        return
    }
    _o="$(<"$BASHTIMER_CACHE_DIR/$$")"
    printf -v _t '%(%s)T'

    ((timetaken=_t - _o))

    printf 'Time : %s \n' "$(BashTimer::Convert "$timetaken")"

    BashTimer::setTime
    : > "$BASHTIMER_CACHE_DIR/cmd.$$"
}

BashTimer::Reset(){
    local _p="$BASH_COMMAND"
    case "$_p" in
        "history"*)     return  ;;
        "BashTimer"*)   return  ;;
        ""|*)           BashTimer::setTime ;;
    esac
    printf '%s' "$_p" > "$BASHTIMER_CACHE_DIR/cmd.$$"
}

BashTimer::setup
trap 'rm $BASHTIMER_CACHE_DIR/$$ ; rm $BASHTIMER_CACHE_DIR/cmd.$$' 0
trap 'BashTimer::Reset' DEBUG
