#!/bin/bash

export _JAVA_AWT_WM_NONREPARENTING=1
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function output_name () {
    local edid=$1
    echo $edid
    screen_name=`xrandr --prop | grep -C1  EDID | "$DIR"/get_output_name.py $edid`
}

xrandr --output eDP --mode 1920x1080 --dpi 96 --pos 0x0


# output_name 00ffffffffffff0010ac7ba053435932
# xrandr --output $screen_name --off
# xrandr --output $screen_name --mode 1920x1200 --pos 1920x0
# i3-msg '[workspace="2"]' move workspace to output $screen_name
# 
# output_name 00ffffffffffff0010ac7ba04c473735
# xrandr --output $screen_name --off
# xrandr --output $screen_name --mode 1920x1200 --pos 3840x0
# i3-msg '[workspace="3"]' move workspace to output $screen_name

# output_name 02ffffffffffff001e6d455aa7960600
# xrandr --output $screen_name --off
# xrandr --output $screen_name --mode 1920x1080 --pos 1920x0

