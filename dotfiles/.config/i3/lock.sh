#!/usr/bin/env bash
set -e

TIMEC='ffffffaa'
DATEC='ffffffaa'
LAYOUTC='ffffffaa'
SEPC='22222260'
KEYHLC='ffffff80'

LINEC='111111aa'
VERIFC='ffffffaa'
WRONGC='ff0000aa'

INSIDEC='111111aa'
INSIDEWRONGC='111111aa'
INSIDEVERC='111111aa'

RINGC='ffffff50'
RINGWRONGC='ff0000aa'
RINGVERC='00ff00aa'

setxkbmap -model pc104 -layout us,ru -option grp:alt_shift_toggle

i3lock                           \
--datestr="%d.%m.%Y"             \
--blur 5                         \
--screen 1                       \
--keylayout 2                    \
--indicator                      \
--clock                          \
--timecolor $TIMEC               \
--datecolor $DATEC               \
--layoutcolor $LAYOUTC           \
--separatorcolor $SEPC           \
--keyhlcolor $KEYHLC             \
--linecolor $LINEC               \
--verifcolor $VERIFC             \
--wrongcolor $WRONGC             \
--insidecolor $INSIDEC           \
--insidewrongcolor $INSIDEWRONGC \
--insidevercolor $INSIDEVERC     \
--ringcolor $RINGC               \
--ringwrongcolor $RINGWRONGC     \
--ringvercolor $RINGVERC         &
