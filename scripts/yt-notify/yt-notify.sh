#!/bin/bash

EMAIL="nilseckerle2001@protonmail.com"
DATA_DIR="$HOME/.local/share/yt-notify"
# Find chenel id's on youtub F12 inspect and search for browseId
# then in the format:
# UCxxxxxx...|Channel Name
# UCxxxxxx...|Channel Name
CHANNELS_FILE="$DATA_DIR/channels.txt"
SEEN_FILE="$DATA_DIR/seen.txt"

mkdir -p "$DATA_DIR"
touch "$SEEN_FILE"

while IFS='|' read -r channel_id channel_name; do
    [[ "$channel_id" =~ ^#.*$ || -z "$channel_id" ]] && continue

    xml=$(curl -s "https://www.youtube.com/feeds/videos.xml?channel_id=${channel_id}")

    # Extract video IDs one per line
    video_ids=$(echo "$xml" | grep -oP '(?<=<yt:videoId>)[^<]+')

    # echo "DEBUG [$channel_name]: $(echo "$video_ids" | wc -l) videos found"
    # echo "DEBUG IDs: $video_ids"

    while IFS= read -r video_id; do
        [ -z "$video_id" ] && continue

        if ! grep -qe "^${video_id}$" "$SEEN_FILE" 2>/dev/null; then
            title=$(echo "$xml" | xmllint --html --xpath \
                "string(//entry[.//*[.='$video_id']]/title)" - 2>/dev/null)
            [ -z "$title" ] && title="(no title)"
            link="https://www.youtube.com/watch?v=${video_id}"

            echo "$video_id" >> "$SEEN_FILE"

            printf "Subject: New video: %s: %s\nFrom: %s\nTo: %s\n\n%s\n%s\n" \
                "$channel_name" "$title" "$EMAIL" "$EMAIL" "$title" "$link" \
                | msmtp "$EMAIL"
        fi
    done <<< "$video_ids"

done < "$CHANNELS_FILE"

# Update videos without sending mails. Runn manually:
# # Extract all current video IDs into seen.txt without sending any emails
# while IFS='|' read -r id _; do
#     curl -s "https://www.youtube.com/feeds/videos.xml?channel_id=${id}" | \
#         grep -oP '(?<=<yt:videoId>)[^<]+'
# done < ~/.local/share/yt-notify/channels.txt >> ~/.local/share/yt-notify/seen.txt
