#!/bin/bash
# Rofi Calculator
# Handles scientific notation and copies result to clipboard

# Function to evaluate mathematical expression
calculate() {
  local expression="$1"

  # Convert scientific notation (e.g., 16e6 -> 16*10^6) for bc compatibility
  expression=$(echo "$expression" | sed 's/\([0-9]\)e\([+-]\?[0-9]\)/\1*10^\2/g')

  result=$(awk "BEGIN {printf \"%.10g\", $expression}" 2>/dev/null)

  echo "$result"
}

# Main calculator function
main() {
  # History file for calculator
  HIST_FILE="$HOME/.config/rofi/calc_history"
  mkdir -p "$(dirname "$HIST_FILE")"

  # If no argument provided, show rofi prompt
  if [ -z "$1" ]; then
    # Read history and create menu options
    history_entries=""
    if [ -f "$HIST_FILE" ]; then
      history_entries=$(tail -20 "$HIST_FILE" | tac)
    fi

    # Show rofi with history and prompt for new calculation
    expression=$(echo -e "$history_entries" | rofi -dmenu -p "Calculator" -mesg "Examples: 16e6/1024, sin(pi/2), sqrt(144), log(100), 2**8")

    if [ -z "$expression" ]; then
      exit 0
    fi
  else
    expression="$1"
  fi

  # Clean up expression (remove spaces around operators for better parsing)
  expression=$(echo "$expression" | sed 's/ //g')

  # Calculate result
  result=$(calculate "$expression")

  if [ -z "$result" ] || [ "$result" = "0" ] && [ "$expression" != "0" ]; then
    rofi -e "Error: Invalid expression '$expression'"
    exit 1
  fi

  # Format result (remove trailing zeros and decimal point if not needed)
  formatted_result=$(echo "$result" | sed 's/\.0*$//' | sed 's/\(.*\.\)0*$/\1/' | sed 's/\.$//') 

  # Copy to clipboard
  echo "$formatted_result" | xclip -selection clipboard

  # Save to history
  echo "$expression = $formatted_result" >> "$HIST_FILE"

  # Show result notification
  notify-send "Calculator" "$expression = $formatted_result" -t 3000

  # Also show in rofi for immediate visibility
  echo "$expression = $formatted_result" | rofi -dmenu -p "Result (copied to clipboard)" -mesg "Result copied to clipboard"
}

main "$@"
