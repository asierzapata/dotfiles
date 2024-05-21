#!/bin/bash

sketchybar --add item media e \
           --set media label.color=$ITEM_BG_COLOR \
                       label.max_chars=50 \
                       icon.padding_left=0 \
                       scroll_texts=on \
                       icon=􀑪             \
                       icon.color=$ITEM_BG_COLOR   \
                       background.drawing=off \
                       script="$PLUGIN_DIR/media.sh" \
           --subscribe media media_change
