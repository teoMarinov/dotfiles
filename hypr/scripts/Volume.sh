#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */ ##
# Volume controls for audio and mic - Cleaned for Noctalia (No Notifications)

sDIR="$HOME/.config/hypr/scripts"

# Get Volume
get_volume() {
    volume=$(pamixer --get-volume)
    if [[ "$volume" -eq "0" ]]; then
        echo "Muted"
    else
        echo "$volume %"
    fi
}

# Sound Feedback (Optional)
play_sound() {
    if [ -f "$sDIR/Sounds.sh" ]; then
        "$sDIR/Sounds.sh" --volume
    fi
}

# Increase Volume
inc_volume() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        toggle_mute
    else
        pamixer -i 5 --allow-boost --set-limit 150 && play_sound
    fi
}

# Decrease Volume
dec_volume() {
    if [ "$(pamixer --get-mute)" == "true" ]; then
        toggle_mute
    else
        pamixer -d 5 && play_sound
    fi
}

# Toggle Mute
toggle_mute() {
    if [ "$(pamixer --get-mute)" == "false" ]; then
        pamixer -m
    elif [ "$(pamixer --get-mute)" == "true" ]; then
        pamixer -u
    fi
}

# Toggle Mic
toggle_mic() {
    if [ "$(pamixer --default-source --get-mute)" == "false" ]; then
        pamixer --default-source -m
    elif [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        pamixer -u --default-source
    fi
}

# Get Microphone Volume
get_mic_volume() {
    volume=$(pamixer --default-source --get-volume)
    if [[ "$volume" -eq "0" ]]; then
        echo "Muted"
    else
        echo "$volume %"
    fi
}

# Increase MIC Volume
inc_mic_volume() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        toggle_mic
    else
        pamixer --default-source -i 5
    fi
}

# Decrease MIC Volume
dec_mic_volume() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        toggle_mic
    else
        pamixer --default-source -d 5
    fi
}

# Execute accordingly
case "$1" in
    "--get") get_volume ;;
    "--inc") inc_volume ;;
    "--dec") dec_volume ;;
    "--toggle") toggle_mute ;;
    "--toggle-mic") toggle_mic ;;
    "--mic-inc") inc_mic_volume ;;
    "--mic-dec") dec_mic_volume ;;
    *) get_volume ;;
esac
