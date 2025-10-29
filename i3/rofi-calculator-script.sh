#!/bin/bash
# Rofi Calculator
# Handles scientific notation and copies result to clipboard

# Function to evaluate mathematical expression
calculate() {
  local expression="$1"
  # Convert scientific notation and constants for awk
  local awk_expr="$expression"
  awk_expr=$(echo "$awk_expr" | sed 's/\([0-9]\)e\([+-]\?[0-9]\)/\110^\2/g')
  awk_expr=$(echo "$awk_expr" | sed 's/\bpi\b/atan2(0,-1)/g')
  awk_expr=$(echo "$awk_expr" | sed 's/\be\b/exp(1)/g')

  # Try awk first
  result=$(awk "BEGIN {printf \"%.10g\", $awk_expr}" 2>/dev/null)

  # # If awk failed (exit status != 0) or result is invalid, use Python
  # if [[ $? -ne 0 ]] || [[ -z "$result" || "$result" == "nan" || "$result" == "inf" || "$result" == "-inf" ]]; then
  #   # Prepare expression for Python
  #   local python_expr="$expression"
  #   python_expr=$(echo "$python_expr" | sed 's/\bpi\b/math.pi/g')
  #   python_expr=$(echo "$python_expr" | sed 's/\be\b/math.e/g')
  #   python_expr=$(echo "$python_expr" | sed 's/\b\(sin\|cos\|tan\|exp\|log\|sqrt\|atan2\)\b/math.\1/g')
  #   result=$(python3 -c "import math; print($python_expr)" 2>/dev/null)
  # fi

  echo "$result"
}

# Main calculator function
main() {
  # If argument provided, calculate once and exit
  if [ -n "$1" ]; then
    expression="$1"
  else
    # Show rofi prompt for calculation
    expression=$(wofi -dmenu -p "Calculator" -mesg "Examples: 16e6/1024, sin(pi/2), sqrt(144), log(100), 2**8")

    # If user cancels (Escape) or provides empty input, exit
    if [ -z "$expression" ]; then
      exit 0
    fi
  fi

  # Clean up expression
  expression=$(echo "$expression" | sed 's/ //g')

  # Calculate result
  result=$(calculate "$expression")

  if [ -z "$result" ] || [ "$result" = "0" ] && [ "$expression" != "0" ]; then
    wofi -e "Error: Invalid expression '$expression'"
    exit 1
  fi

  # Format result
  formatted_result=$(echo "$result" | sed 's/\.0$//' | sed 's/\(.\.\)0$/\1/' | sed 's/\.$//') 

  # Copy to clipboard
  echo "$formatted_result" | wl-copy

  # Show result notification
  notify-send "Calculator" "$expression = $formatted_result" -t 3000

  # Show result and exit
  echo "$expression = $formatted_result"
  exit 0
}

main "$@"
