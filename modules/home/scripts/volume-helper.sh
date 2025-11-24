#!/usr/bin/env sh

if ! command -v pactl >/dev/null; then
    exit 0;
fi

# pactl output depends on the current locale
export LANG=C.UTF-8 LC_ALL=C.UTF-8

DEFAULT_STEP=5
LIMIT=${LIMIT:-100}
SINK="@DEFAULT_SINK@"

clamp() {
    if [ "$1" -lt 0 ]; then
        echo "0"
    elif [ "$1" -gt "$LIMIT" ]; then
        echo "$LIMIT"
    else
        echo "$1"
    fi
}

get_sink_volume() { # sink
    ret=$(pactl get-sink-volume "$1")
    # get first percent value
    ret=${ret%%%*}
    ret=${ret##* }
    echo "$ret"
    unset ret
}

CHANGE=0
VOLUME=-1
TOGGLE_MUTE=0
TOGGLE_MIC_MUTE=0
SOURCE="@DEFAULT_SOURCE@"

while true; do
    case $1 in
        --sink)
            SINK=${2:-$SINK}
            shift;;
        --source)
            SOURCE=${2:-$SOURCE}
            shift;;
        -l|--limit)
            LIMIT=$((${2:-$LIMIT}))
            shift;;
        --set-volume)
            VOLUME=$(($2))
            shift;;
        -i|--increase)
            CHANGE=$((${2:-$DEFAULT_STEP}))
            shift;;
        -d|--decrease)
            CHANGE=$((-${2:-$DEFAULT_STEP}))
            shift;;
        --toggle-mute)
            TOGGLE_MUTE=1
            ;;
        --toggle-mic-mute)
            TOGGLE_MIC_MUTE=1
            ;;
        *)
            break
            ;;
    esac
    shift
done

if [ "$TOGGLE_MIC_MUTE" -eq 1 ]; then
    pactl set-source-mute "$SOURCE" toggle
elif [ "$TOGGLE_MUTE" -eq 1 ]; then
    pactl set-sink-mute "$SINK" toggle
elif [ "$CHANGE" -ne 0 ]; then
    VOLUME=$(get_sink_volume "$SINK")
    VOLUME=$(( VOLUME + CHANGE ))
    pactl set-sink-volume "$SINK" "$(clamp "$VOLUME")%"
elif [ "$VOLUME" -ge 0 ]; then
    pactl set-sink-volume "$SINK" "$(clamp "$VOLUME")%"
fi

# Display desktop notification

if ! command -v notify-send >/dev/null; then
    exit 0;
fi

# Check if this was a mic mute action
if [ "$TOGGLE_MIC_MUTE" -eq 1 ]; then
    case $(pactl get-source-mute "$SOURCE") in
        *yes)
            TEXT="Microphone: muted"
            VOLUME=0
            ;;
        *)
            TEXT="Microphone: unmuted"
            VOLUME=100
            ;;
    esac
else
    # Regular volume/mute notification
    VOLUME=$(get_sink_volume "$SINK")
    TEXT="Volume: ${VOLUME}%"
    case $(pactl get-sink-mute "$SINK") in
        *yes)
            TEXT="Volume: muted"
            VOLUME=0
            ;;
    esac
fi

notify-send \
    --app-name sway \
    --expire-time 800 \
    --hint string:x-canonical-private-synchronous:volume \
    --hint "int:value:$VOLUME" \
    --transient \
    "${TEXT}"
