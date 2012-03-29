#!/bin/zsh

# generic options
FOREGROUND='#C3C9C9'
#FOREGROUND='#2E2E2E'
FOREGROUND_ALT='#C5292D'
#BACKGROUND='#343434'
BACKGROUND='#333232'
FONT='Acknowledge:size=10'

GEOMETRY='+0-0'
WIDTH=
HEIGHT=12
EXPAND='left'
TEXT_ALIGN='r'
SCREEN_ALIGN='r'

# dzen-ng specific

SEPARATOR="^fg(${FOREGROUND_ALT})::^fg()"   # WIDGET SEPARATOR
INTERVAL=1.5                                # SLEEP INTERVAL

EXECUTE=(MPD BATTERY CPUTEMP CLOCK)         # WIDGET ORDER

DZEN_ARGS=''
GDBAR_ARGS=''

## some functions ;)
function CLOCK {
    ## [day] [month] [year], [hour]:[minutes]    

    CLOCK=$(date +"%d %b %y, %H:%M")
    print "${CLOCK}"
}

function CPUTEMP {
    CORETEMP=$(awk '{ print substr($1,0,length($1)-3) }' /sys/class/hwmon/hwmon*/temp1_input)
    print "${CORETEMP}°C"
}

function BATTERY {
    BATTERY=$(acpi -b | awk '{ print $4 }')
    BT_STATE=$(awk '{ if ($1 == 1) print "AC"; else print "BT"; }' /sys/class/power_supply/AC/online)

    print "${BT_STATE} ${BATTERY}"

}

function MPD {
    MPD_STATE=$(mpc | awk '/playing|paused/ { print substr($1, 2, length($1)-2) }')
    MPD_CURRENT=$(mpc | head -n 1)

    case ${MPD_STATE} in
        `/bin/false`)
            print "[stopped]"
            ;;
        *)
            print "[$MPD_STATE] ${MPD_CURRENT}"
            ;;
    esac
}

# execute
while true
do
    #for ((index=0; index < ${#EXECUTE[@]}; index++))
    for index in {1..${#EXECUTE[@]}..1}
    do
        print -n " ${SEPARATOR} `${EXECUTE[index]}`"
    done

    print --

    sleep $INTERVAL
done | dzen2 -fg "${FOREGROUND}" -bg "${BACKGROUND}" -fn "${FONT}" -h "${HEIGHT}" -expand "${EXPAND}" -ta "${TEXT_ALIGN}" -sa "${SCREEN_ALIGN}" -title-name "dzen-ng" ${DZEN_ARGS}

