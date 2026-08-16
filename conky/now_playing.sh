#!/bin/bash
result=$(playerctl -a metadata --format '{{status}}|{{artist}} - {{title}}' 2>/dev/null | grep '^Playing' | head -n 1 | cut -d'|' -f2)

if [ -z "$result" ]; then
    echo "Nothing playing"
else
    echo "$result"
fi
