#!/usr/bin/env bash
# Reveals waybar when the cursor touches the top edge of any monitor,
# hides it again once the cursor moves well clear of the bar.
# Relies on waybar's own IPC signals (config: on-sigusr1=show, on-sigusr2=hide).

SHOW_AT=2     # px from the top edge that triggers a reveal
HIDE_AT=45    # px past which the bar hides again (bar height + margin + buffer)
POLL=0.1      # seconds between cursor checks

state="hidden"

while true; do
    read -r x y < <(hyprctl cursorpos | tr -d ',')

    if [[ "$state" == "hidden" && "$y" -le "$SHOW_AT" ]]; then
        pkill -SIGUSR1 -x waybar
        state="shown"
    elif [[ "$state" == "shown" && "$y" -gt "$HIDE_AT" ]]; then
        pkill -SIGUSR2 -x waybar
        state="hidden"
    fi

    sleep "$POLL"
done
