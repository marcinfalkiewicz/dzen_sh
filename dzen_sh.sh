#!/usr/bin/env bash

# generic options
FOREGROUND='#C3C9C9'
#FOREGROUND='#2E2E2E'
FOREGROUND_ALT='#CCFF42'
FOREGROUND_ERR='#FF4141'
#BACKGROUND='#343434'
BACKGROUND='#1B1D1E'
FONT='Acknowledge:size=10'

#GEOMETRY=''
#WIDTH=
HEIGHT=12
#EXPAND='right'
TEXT_ALIGN='r'
SCREEN_ALIGN='r'

# dzen-ng specific

SEPARATOR="^fg(${FOREGROUND_ALT})::^fg()"   # WIDGET SEPARATOR
INTERVAL=1.5                                # SLEEP INTERVAL

EXECUTE=(WIFI BATTERY ALSA CPUTEMP CLOCK)         # WIDGET ORDER

DZEN_ARGS='-dock ' # -expand "${EXPAND}" -geometry "${GEOMETRY}"
GDBAR_ARGS=''

## module vars

WLAN_INTERFACE="wlan0"


## some functions ;)
function CLOCK {
    ## [day] [month] [year], [hour]:[minutes]    

    CLOCK=$(date +"%d %b %y, %H:%M")
    echo "${CLOCK}"
}

function CPUTEMP {
    CORETEMP=$(awk '{ print substr($1,0,length($1)-3) }' /sys/devices/virtual/thermal/thermal_zone0/temp)
    echo "${CORETEMP}°C"
}

function BATTERY {
    BATTERY=$(acpi -b | awk '{ print substr($4,0,length($4)-2) }')
    BT_STATE=$(awk '{ if ($1 == 1) print "AC"; else print "BT"; }' /sys/class/power_supply/AC/online)

    echo "${BT_STATE} [${BATTERY}]"

}

function MPD {
    MPD_STATE=$(mpc | awk '/playing|paused/ { print substr($1, 2, length($1)-2) }')
    MPD_CURRENT=$(mpc | head -n 1)

    case ${MPD_STATE} in
        `false`)
            echo "[stopped]"
            ;;
        *)
            echo "[$MPD_STATE] ${MPD_CURRENT}"
            ;;
    esac
}

function NVIDIA_LSPCI {
    DEVICE=$(lspci -d 10de:)

    case ${DEVICE} in
        `false`)
            echo "[off]"
            ;;
        *)
            echo "[on]"
            ;;
    esac
}

function WIFI {
    CONNECTED=$(iwconfig ${WLAN_INTERFACE} | awk '/ESSID/ { print substr($4, 7, length($4)-10) }')

    case ${CONNECTED} in
        off)
            echo "NETWORK [^fg(${FOREGROUND_ERR})D/C^fg()]"
            ;;
        *)
            CONNECTED=$(iwconfig ${WLAN_INTERFACE} | awk '/ESSID/ { print substr($4, 8, length($4)-8) }')
            echo "NETWORK [^fg(${FOREGROUND_ALT})${CONNECTED}^fg()]"
            ;;
    esac
}

function ALSA {
    VOLUME=$(amixer -c0 get Master | awk '/^  Mono/ { print $4 }' | tr -d [=[=]-[=]=] | tr -d [%])
    VOLUME_STAT=$(amixer -c0 get Master | awk '/^  Mono/ { print $6 }' | tr -d [=[=]-[=]=] | tr -d [%])

    case "${VOLUME_STAT}" in
        off)
            echo "VOL [0]"
            ;;
        *)
            echo "VOL [${VOLUME}]"
            ;;
    esac
}

# execute
while true
do
    for ((index=0; index < ${#EXECUTE[@]}; index++))
#    for index in {1..${#EXECUTE[@]}..1}
#    for index in ${EXECUTE[@]:0}
    do
        echo -n "^pa(;-3) ${SEPARATOR} `${EXECUTE[index]}`^pa()"
    done

    echo
    sleep $INTERVAL
done | dzen2 -fg "${FOREGROUND}" -bg "${BACKGROUND}" -fn "${FONT}" -h "${HEIGHT}" -ta "${TEXT_ALIGN}" -sa "${SCREEN_ALIGN}" -title-name "dzen-ng" ${DZEN_ARGS}
