#!/usr/bin/env bash

# Get untracked files from git status
untracked_items=$(git status --porcelain | grep '^??' | cut -c4-)

if [ -z "$untracked_items" ]; then
  echo "No untracked files or directories found."
  exit 0
fi

echo "=== Processing Untracked Items ==="
echo

# Separate directories and files
directories=()
files=()

while IFS= read -r item; do
  if [ -d "$item" ]; then
    directories+=("$item")
  elif [ -f "$item" ]; then
    files+=("$item")
  fi
done <<< "$untracked_items"

# Process directories with tree
for dir in "${directories[@]}"; do
  echo "======================================"
  echo "DIRECTORY: $dir"
  echo "======================================"
  tree "$dir"
  echo

    # Now cat all files inside this directory
    while IFS= read -r file; do
      if [ -f "$file" ]; then
        echo "--------------------------------------"
        echo "FILE: $file"
        echo "--------------------------------------"
        if grep -Iq . "$file"; then
          cat "$file"
        else
          echo "binary file - output skipped"
        fi
        echo
        echo
      fi
    done < <(find "$dir" -type f)
  done

# Process standalone files (not in untracked directories)
for file in "${files[@]}"; do
  echo "--------------------------------------"
  echo "FILE: $file"
  echo "--------------------------------------"
  if grep -Iq . "$file"; then
    cat "$file"
  else
    echo "binary file - output skipped"
  fi
  echo
  echo
done
