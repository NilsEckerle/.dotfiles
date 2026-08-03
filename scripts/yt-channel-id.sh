#!/usr/bin/env bash
id=$(curl -fsSL -A "Mozilla/5.0" "$1" \
  | grep -oE '(channelId|externalId|browseId)":"UC[A-Za-z0-9_-]{22}|channel/UC[A-Za-z0-9_-]{22}' \
  | grep -oE 'UC[A-Za-z0-9_-]{22}' \
  | head -n1)
echo "https://www.youtube.com/feeds/videos.xml?channel_id=$id"
