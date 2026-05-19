#!/bin/bash
# Start Second Brain 2 - Obsidian Vault + Ollama + Local Query Engine
# Starts Ollama (if not running), opens the vault in Obsidian, and starts vault_query

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(dirname "$SCRIPT_DIR")
VAULT="$PROJECT_ROOT"

# Parse flags
NO_PROMPT=false
for arg in "$@"; do
    case "$arg" in
        --no-prompt) NO_PROMPT=true ;;
    esac
done

echo -e '\uf9c6 Starting Second Brain 2...'

# Check if Ollama is running, start if needed
if ! curl -s --max-time 2 http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo -e '   \uf473 Starting Ollama...'
    ollama serve > /dev/null 2>&1 &
    OLLAMA_STARTED=true
    sleep 3
    if ! curl -s --max-time 2 http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo -e '   \uf28b ERROR: Ollama failed to start. Install with: curl -fsSL https://ollama.com/install.sh | sh'
        if ! $NO_PROMPT; then
            echo ''
            read -p 'Press Enter to close this terminal...'
        fi
        exit 1
    fi
else
    echo -e '   \uf6f2 Ollama: Already running'
fi

# Check if qwen3 model is available (fast local LLM for vault queries)
if ! ollama list 2>/dev/null | grep -q 'qwen3:1.7b'; then
    echo -e '   ⚠ WARNING: qwen3:1.7b model not found. Run: ollama pull qwen3:1.7b'
fi
echo -e '   \uf6f2 Ollama: Ready'

# Check GPU acceleration status
GPU_STATUS=$(curl -s http://localhost:11434/api/ps 2>/dev/null)
if echo "$GPU_STATUS" | python3 -c "import sys,json; d=json.load(sys.stdin); print(next((m for m in d.get('models',[])), None))" 2>/dev/null | grep -q 'vram'; then
    echo -e '   🎮 GPU: Active (Vulkan)'
else
    # Check if Vulkan GPU was detected at startup
    if sudo journalctl -u ollama --no-pager -n 50 2>/dev/null | grep -q 'Vulkan0'; then
        echo -e '   🎮 GPU: AMD Radeon RX Vega (Vulkan) detected - will accelerate model loads'
    elif sudo journalctl -u ollama --no-pager -n 50 2>/dev/null | grep -q 'inference compute.*cpu'; then
        echo -e '   ⚠ GPU: Not detected - running in CPU-only mode'
    else
        echo -e '   🖥  Compute: Checking...'
    fi
fi

# Open vault in Obsidian
OBSIDIAN_CMD=""
if command -v obsidian > /dev/null 2>&1; then
    OBSIDIAN_CMD="obsidian"
elif flatpak list 2>/dev/null | grep -q md.obsidian.Obsidian; then
    OBSIDIAN_CMD="flatpak run md.obsidian.Obsidian"
elif [ -f /usr/bin/obsidian ]; then
    OBSIDIAN_CMD="/usr/bin/obsidian"
elif [ -f /snap/bin/obsidian ]; then
    OBSIDIAN_CMD="/snap/bin/obsidian"
fi

if [ -n "$OBSIDIAN_CMD" ]; then
    echo -e '   \uf015 Opening Obsidian with vault...'
    nohup $OBSIDIAN_CMD "$VAULT" > /dev/null 2>&1 &
else
    echo -e '   \uf28b Obsidian not found. Open vault manually at: '"$VAULT"
fi

echo ''
echo -e '\uf9c6 Second Brain 2 is ready!'
echo ''
echo -e '   \uf015 Vault:       '"$VAULT"
echo -e '   \uf4d4 Query:       python3 '"$VAULT"'/vault_query.py --interactive'
echo -e '   \uf473 Ollama:      http://localhost:11434'
echo ''

# Quick health check
echo -e '   Vault contents:'
echo -e '   '$(find "$VAULT" -name '*.md' -not -path '*/.git/*' | wc -l)' markdown notes'
echo -e '   '$(find "$VAULT" -name '*.py' | wc -l)' scripts'
echo ''

if ! $NO_PROMPT; then
    read -p 'Press Enter to close this terminal...'
fi