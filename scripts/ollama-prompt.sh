#!/usr/bin/env bash

MODEL="${OLLAMA_MODEL:-deepseek-coder-v2:16b}"
API_URL="${OLLAMA_API:-http://localhost:11434/api/chat}"
TEMP_FILE="/tmp/ollama-prompt-$$.txt"
PID_FILE="/tmp/llm-running.pid"
REQURE_PROMPT="true"

stop_llm() {
  if [[ ! -f "$PID_FILE" ]]; then
    echo "[llm] No running job found."
    exit 1
  fi

  local pid
  pid=$(cat "$PID_FILE")

  if ! kill -0 "$pid" 2>/dev/null; then
    echo "[llm] Job with PID $pid is not running."
    rm -f "$PID_FILE"
    exit 1
  fi

  echo "[llm] Stopping LLM job (PID: $pid)..."
  kill "$pid"
  rm -f "$PID_FILE"
  echo "[llm] Job stopped."
}

run_async_llm() {
  local prompt="$1"
  local outfile="/tmp/llm-response-$(date +%s)-$$.md"

  (
    response=$(send_prompt "$prompt")
    printf "%s\n" "$response" > "$outfile"

    notify-send \
      --app-name="llm" \
      --urgency=low \
      --expire-time=0 \
      --action="open=Open result in editor" \
      "LLM task complete" \
      "Click to open the generated response." \
    | while read -r action; do
        if [[ "$action" == "open" ]]; then
          nohup kitty sh -c "nvim \"$outfile\" && rm \"$outfile\""
        fi
      done
  ) &

  echo $! > "$PID_FILE"
}

get_prompt_from_editor() {
  local editor="${EDITOR:-nvim}"
  local temp_file=$(mktemp)
  
  # Create temp file with helpful comment
  cat > "$temp_file" << 'EOF'
# Enter your prompt below (this line will be removed)

EOF
  
  # Open editor and wait for it to close
  "$editor" "$temp_file" < /dev/tty > /dev/tty
  
  # Read content, remove comment line and empty lines
  local content=$(grep -v '^#' "$temp_file" | sed '/^$/d')
  
  # Cleanup
  rm -f "$temp_file"
  
  echo "$content"
}

build_prompt_with_files() {
  local prompt="$1"
  shift
  local files=("$@")

  local combined="$prompt\n\n"

  for file in "${files[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "Warning: File not found: $file" >&2
      continue
    fi

    combined+="--- File: $file ---\n"
    combined+="$(cat "$file")\n\n"
  done

  echo -e "$combined"
}

send_prompt() {
  local prompt="$1"

  # Create JSON payload using jq from stdin to avoid argument list too long
  local json_payload=$(jq -n \
    --arg model "$MODEL" \
    --arg content "$prompt" \
    '{
      model: $model,
      messages: [
      {role: "user", content: $content}
      ],
      stream: false
    }')

  # echo "Sending to Ollama ($MODEL)..." >&2
  # echo "" >&2

  # Send request and extract response
  local response=$(curl -s "$API_URL" -d "$json_payload")

  # Check for errors
  if [[ -z "$response" ]]; then
    echo "Error: No response from Ollama API" >&2
    exit 1
  fi

  # Extract and print the message content
  echo "$response" | jq -r '.message.content // .error // "Error: Unexpected response format"' | fold -s -w 80
}

show_help() {
  local prog_name=$(basename "$0")
  cat << EOF
Usage: $prog_name [OPTIONS] [PROMPT]

Options:
    -f, --file PATH     Include file content in prompt (can be used multiple times)
    -m, --model MODEL   Specify model (default: qwen2.5-coder:14b)
    -n, --no-prompt     Don't require a prompt (useful with stdin only)
    -s, --stop          Stop any running LLM background job
    -h, --help          Show this help message

Environment Variables:
    OLLAMA_MODEL        Default model to use
    OLLAMA_API          API endpoint (default: http://localhost:11434/api/chat)
    EDITOR              Editor to use for prompt input (default: nvim)

Features:
    - Runs LLM queries asynchronously in the background
    - Sends desktop notification when complete
    - Supports reading from stdin (pipe data into the script)
    - Can combine stdin, prompt text, and file contents
    - Stores PID in /tmp/llm-running.pid for job control

Examples:
    # Interactive mode (opens editor)
    $prog_name

    # Direct prompt
    $prog_name "Explain Docker in simple terms"

    # With file context
    $prog_name -f script.sh "Review this code"

    # Multiple files
    $prog_name -f main.py -f config.yaml "Find bugs"

    # Different model
    $prog_name -m llama3.1:8b "Hello"

    # Piped input
    cat error.log | $prog_name "Analyze this error"

    # Piped input with prompt
    git diff | $prog_name "Review these changes"

    # Piped input without additional prompt
    cat data.txt | $prog_name -n

    # Stop running job
    $prog_name --stop

    # Set default model
    export OLLAMA_MODEL="qwen2.5:7b"
    $prog_name "Your prompt here"

Output:
    Results are saved to /tmp/llm-response-<timestamp>-<pid>.txt
    A desktop notification appears when the job completes
    Click the notification to open the result in your editor
EOF
}

main() {
  local prompt=""
  local stdin=""
  local files=()

  # Read from stdin if data is piped
stdin=""
if ! [ -t 0 ]; then
    # Read all stdin but avoid blocking forever
    stdin=$(cat -)
fi

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      -f|--file)
        if [[ -z "$2" ]] || [[ "$2" == -* ]]; then
          echo "Error: -f requires a file path" >&2
          exit 1
        fi
        files+=("$2")
        shift 2
        ;;
      -m|--model)
        MODEL="$2"
        shift 2
        ;;
      -h|--help)
       show_help
        exit 0
        ;;
      -s|--stop)
        stop_llm
        exit 0
        ;;
      -n|--no-prompt)
        REQURE_PROMPT=""
        shift 1
        ;;
      *)
        # Assume it's the prompt text
        prompt="$1"
        shift
        ;;
    esac
  done

  if [[ -n $REQURE_PROMPT ]]; then
    # If no prompt provided, open editor
    if [[ -z "$prompt" ]]; then
      prompt=$(get_prompt_from_editor)
      if [[ -z "$prompt" ]]; then
        echo "No prompt provided. Exiting." >&2
        exit 1
      fi
    fi

    prompt="========== PROMPT ==========\n${prompt}"
  fi

  if [[ ! -z "$prompt" && ! -z "$stdin" ]]; then
    prompt="${stdin}"$'\n\n'"${prompt}"
  elif [[ ! -z "$prompt" ]]; then
    prompt="${prompt}"
  elif [[ ! -z "$stdin" ]]; then
    prompt="${stdin}"
  fi

  # Append file contents to prompt
  if [[ ${#files[@]} -gt 0 ]]; then
    prompt=$(build_prompt_with_files "$prompt" "${files[@]}")
  fi

  # Send to Ollama
  # send_prompt "$prompt"
  run_async_llm "$prompt"
  # echo "[llm] job started in background..."
  # echo "[llm] you will get a desktop notification when it completes."
  exit 0
}

main "$@"
