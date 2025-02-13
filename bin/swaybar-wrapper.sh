#!/bin/bash

if swaymsg -t get_outputs | jq -e '.[] | select(.name == "DP-4" and .active == true)' >/dev/null; then
  swaymsg bar swaybar output DP-4
else
  swaymsg bar swaybar output *
fi
