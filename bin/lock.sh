#!/bin/bash

tmp_dir="/tmp/swaylock"
mkdir -p "$tmp_dir"

rm -f "$tmp_dir"/*

swaylock_cmd="swaylock"

for output in $(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name'); do
  grim -o "$output" "$tmp_dir/$output.png"

  convert "$tmp_dir/$output.png" -blur 0x8 "$tmp_dir/$output-blurred.png"

  swaylock_cmd="$swaylock_cmd --image $output:$tmp_dir/$output-blurred.png"
done

eval "$swaylock_cmd"

rm -rf "$tmp_dir"
