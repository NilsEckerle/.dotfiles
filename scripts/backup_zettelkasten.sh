#!/usr/bin/env bash
DISPLAY=:0
cd ~/Documents/Zettelkasten && {
  git add . &&
  (git diff --cached --quiet ||
  git commit -m "Backup_$(date +%Y-%m-%d_%H-%M)") &&
  git pull --rebase 2>/tmp/git_error &&
  git push 2>/tmp/git_error
} || { 
  ERROR=$(cat /tmp/git_error 2>/dev/null || echo "Unknown git error");
  notify-send -u critical -t 0 -a "Zettelkasten" "Git failed: $ERROR";
}
