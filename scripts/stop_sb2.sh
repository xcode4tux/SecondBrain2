#!/bin/bash
# Stop Second Brain 2 - Close Obsidian and optionally stop Ollama

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")

# Parse flags
NO_PROMPT=false
STOP_OLLAMA=false
for arg in "$@"; do
    case "$arg" in
        --no-prompt) NO_PROMPT=true ;;
        --stop-ollama) STOP_OLLAMA=true ;;
    esac
done

echo -e '\uf5ae Stopping Second Brain 2...'

# Close Obsidian
OBSIDIAN_PIDS=$(pgrep -f 'obsidian' 2>/dev/null || true)
if [ -n "$OBSIDIAN_PIDS" ]; then
    echo -e '   \uf4d4 Closing Obsidian...'
    pkill -f 'obsidian' 2>/dev/null || true
    sleep 2
    # Force kill if still running
    if pgrep -f 'obsidian' > /dev/null 2>&1; then
        pkill -9 -f 'obsidian' 2>/dev/null || true
    fi
    echo -e '   \uf6f2 Obsidian: Stopped'
else
    echo -e '   \uf6f2 Obsidian: Not running'
fi

# Optionally stop Ollama
if $STOP_OLLAMA; then
    echo -e '   \uf4d4 Stopping Ollama...'
    OLLAMA_PIDS=$(pgrep -f 'ollama' 2>/dev/null || true)
    if [ -n "$OLLAMA_PIDS" ]; then
        # Try graceful stop first
        pkill -f 'ollama serve' 2>/dev/null || true
        sleep 2
        if pgrep -f 'ollama' > /dev/null 2>&1; then
            pkill -9 -f 'ollama' 2>/dev/null || true
        fi
        echo -e '   \uf6f2 Ollama: Stopped'
    else
        echo -e '   \uf6f2 Ollama: Not running'
    fi
else
    echo -e '   \uf6f2 Ollama: Left running (use --stop-ollama to stop)'
fi

echo ''
echo -e '\uf2db Second Brain 2 stopped.'
echo ''
if ! $NO_PROMPT; then
    read -p 'Press Enter to close this terminal...'
fi