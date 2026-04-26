#!/usr/bin/env bash
KINDLE_DOCS=~/Documents/Kindle-Documents
OBSIDIAN_OUT=~/Documents/Zettelkasten/Kindle-Highlights
mkdir -p "$OBSIDIAN_OUT"

extract_title() {
  local lua_file="$1"
  local title
  title=$(grep -oP '(?<=\["title"\] = ")[^"]+' "$lua_file" | head -1)
  if [[ -z "$title" ]]; then
    title=$(basename "$(dirname "$lua_file")" .sdr)
  fi
  echo "$title"
}

make_safe_title() {
    local title="$1"
    local result
    result=$(echo "$title" | sed 's/[*"\\/<>:|?]//g')
    echo "$result"
}

create_book_dir() {
  mkdir -p "$OBSIDIAN_OUT/$1"
}

find "$KINDLE_DOCS" -name "metadata.*.lua" | while read -r lua_file; do
  # echo -n "Parsing '$lua_file' ... "

  title=$(extract_title "$lua_file")
  save_title=$(make_safe_title "$title")


  # create_book_dir "$save_title"

  # echo "Done"
done


echo ""
echo "Done. Notes written to $OBSIDIAN_OUT"
