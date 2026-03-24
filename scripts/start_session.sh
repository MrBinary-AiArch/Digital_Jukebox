#!/bin/bash
# Digital Jukebox - Auto-Session Manager with Bypass
# ---------------------------------------------------
# To bypass auto-tmux: Press ENTER during the 3-second countdown.

PROJECT_DIR="$HOME/"
SESSION_NAME="jukebox"

# 1. Navigation
if [ -d "$PROJECT_DIR" ]; then
    cd "$PROJECT_DIR" || echo "Warning: Could not cd to $PROJECT_DIR"
else
    echo "Creating project directory: $PROJECT_DIR"
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR" || echo "Warning: Could not cd to $PROJECT_DIR"
fi

# 2. Tmux Check
if [ -n "$TMUX" ]; then
    echo "Already inside a Tmux session."
    return 0 2>/dev/null || exit 0
fi

# 3. Interactive Bypass
echo ""
echo "=========================================="
echo "   DIGITAL JUKEBOX - AUTO-LOGIN ENABLED   "
echo "=========================================="
echo " To STAY in a standard shell (no tmux),   "
echo " PRESS [ENTER] within 3 seconds...        "
echo "=========================================="
echo ""

# -t 3: Wait 3 seconds
# We removed '-n 1' (single key) to prevent terminal garbage (ANSI codes)
# We removed '-s' so you can see if you typed something else by mistake
if read -t 3; then
    echo " > Bypass detected. Starting standard shell."
    echo ""
    # Return 0 to exit this script but keep the parent shell alive
    return 0 2>/dev/null || exit 0
fi

echo " > Timeout reached. Launching Jukebox session..."
sleep 0.5

# 4. Tmux Launch/Attach
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    # Attach to existing session
    exec tmux attach-session -t "$SESSION_NAME"
else
    # Create new session
    exec tmux new-session -s "$SESSION_NAME"
fi
