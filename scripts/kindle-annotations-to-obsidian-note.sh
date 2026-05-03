#!/usr/bin/env bash
KINDLE_DOCS=~/Documents/Kindle-Documents
OBSIDIAN_OUT=~/Documents/Zettelkasten/Kindle-Highlights
LOG_FILE=~/logs/kindle-highlights.log
ERRORS=0

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
error() { log "ERROR: $*" >&2; ((ERRORS++)); }
notify() {
  notify-send -u critical "Kindle Highlights" "$*" 2>/dev/null || true
}

mkdir -p "$OBSIDIAN_OUT" || { error "Cannot create output dir $OBSIDIAN_OUT"; exit 1; }
mkdir -p "$(dirname "$LOG_FILE")" || { error "Cannot create log dir"; exit 1; }

log "Starting Kindle highlights export"

extract_title() {
  local lua_file="$1"
  local title
  title=$(grep -oP '(?<=\["title"\] = ")[^"]+' "$lua_file" | head -1)
  if [[ -z "$title" || "$title" =~ ^Untitled ]]; then
    title=$(basename "$(dirname "$lua_file")" .sdr)
  fi
  echo "$title"
}

make_safe_title() {
    local title="$1"
    echo "$title" | sed 's/[*"\\/<>:|?]//g'
}

extract() {
    local lua_file="$1"
    awk '
/^\s+\[[0-9]+\] = \{$/ {
    if (depth == 0) {
        in_annotation = 1
        text = ""; note = ""; page = ""; datetime = ""
    }
    depth++
}
in_annotation && /\{$/ && !/^\s+\[[0-9]+\] = \{$/ {
    depth++
}
in_annotation && depth == 1 && /\["text"\]/ {
    match($0, /\["text"\] = "(.+)"/, arr); text = arr[1]
}
in_annotation && depth == 1 && /\["note"\]/ {
    match($0, /\["note"\] = "(.+)"/, arr); note = arr[1]
}
in_annotation && depth == 1 && /^\s+\["page"\] = [0-9]/ {
    match($0, /\["page"\] = ([0-9]+)/, arr)
    if (page == "") page = arr[1]
}
in_annotation && depth == 1 && /\["datetime"\] = / && !/datetime_updated/ {
    match($0, /\["datetime"\] = "([^"]+)"/, arr); datetime = arr[1]
}
in_annotation && /^\s+\},/ {
    depth--
    if (depth == 0) {
        if (text != "")
            print "  text: " text "\n  note: " note "\n  page: " page "\n  datetime: " datetime
        in_annotation = 0
    }
}
    ' "$lua_file"
}

while IFS= read -r lua_file; do
  title=$(extract_title "$lua_file")
  if [[ -z "$title" ]]; then
    error "Could not extract title from $lua_file"
    continue
  fi

  save_title=$(make_safe_title "$title")
  texts=(); notes=(); pages=(); datetimes=()

  while IFS= read -r line; do
    case "$line" in
      "  text: "*)     texts+=("${line#  text: }") ;;
      "  note: "*)     notes+=("${line#  note: }") ;;
      "  page: "*)     pages+=("${line#  page: }") ;;
      "  datetime: "*) datetimes+=("${line#  datetime: }") ;;
    esac
  done < <(extract "$lua_file")

  [[ ${#texts[@]} -eq 0 ]] && continue

  book_dir="$OBSIDIAN_OUT/$save_title"
  if ! mkdir -p "$book_dir"; then
    error "Cannot create book dir $book_dir"
    continue
  fi

  for i in "${!texts[@]}"; do
    safe_dt=$(echo "${datetimes[$i]}" | tr ' :' '_')
    safe_text=$(echo "${texts[$i]}" | awk '{for(i=1;i<=5&&i<=NF;i++) printf "%s%s",$i,(i<5&&i<NF?" ":""); print ""}' | sed 's/[*"\\/<>:|?]//g' | tr ' ' '_')
    out_file="$book_dir/${safe_dt}_${safe_text}.md"

    [[ -f "$out_file" ]] && continue

    if ! cat > "$out_file" << EOF
---
aliases: $save_title
tags:
  - literatur
  - kindle-highlights
  - fleeting
type: literatur
date: ${datetimes[$i]}
page: ${pages[$i]}
up: 
---

Source: $title
Zotero:

# Note
${notes[$i]}

# References
> [!QUOTE] p.${pages[$i]} ${datetimes[$i]}
> ${texts[$i]}
EOF
    then
      error "Failed to write $out_file"
    fi
  done

  log "Written: $book_dir (${#texts[@]} highlights)"
done < <(find "$KINDLE_DOCS" -name "metadata.*.lua")

echo ""
if [[ $ERRORS -eq 0 ]]; then
  log "Done. No errors. Notes written to $OBSIDIAN_OUT"
else
  log "Done with $ERRORS error(s). Check $LOG_FILE"
  notify "Export failed with $ERRORS error(s). Check $LOG_FILE"
  exit 1
fi
