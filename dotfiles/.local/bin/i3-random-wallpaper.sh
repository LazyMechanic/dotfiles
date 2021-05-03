#!/bin/bash

N=$((1 + $RANDOM % 7))

feh --bg-fill $HOME/.local/share/wallpapers/$(N).jpg \
    --bg-fill $HOME/.local/share/wallpapers/$(N).jpg