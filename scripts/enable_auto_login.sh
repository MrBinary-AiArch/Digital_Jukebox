#!/bin/bash
# Digital Jukebox - Enable Auto-Login
# Backs up .bashrc and appends the logic to launch start_session.sh

BASHRC="$HOME/.bashrc"
BACKUP_BASHRC="$HOME/.bashrc.bak"

# 1. Backup First!
if [ ! -f "$BACKUP_BASHRC" ]; then
    echo "Creating backup of .bashrc at $BACKUP_BASHRC..."
    cp "$BASHRC" "$BACKUP_BASHRC"
else
    echo "Backup found ($BACKUP_BASHRC). Skipping..."
fi

# 2. Add Auto-Start Logic
# We wrap this in a check for interactive SSH sessions to avoid breaking SCP/SFTP.
# This prevents "Connection Closed" errors when transferring files later.

BLOCK_START="# --- DIGITAL JUKEBOX AUTO-LOGIN ---"
BLOCK_END="# --- END DIGITAL JUKEBOX AUTO-LOGIN ---"

if grep -q "$BLOCK_START" "$BASHRC"; then
    echo "Auto-login configuration already exists in .bashrc."
else
    echo "Appending auto-login logic to .bashrc..."
    cat <<EOF >> "$BASHRC"

$BLOCK_START
# Only run if:
# 1. Shell is interactive ($- contains i)
# 2. We are not already in Tmux (TMUX is empty)
# 3. We are connected via SSH (SSH_CONNECTION is set)

if [[ \$- == *i* ]] && [[ -z "\$TMUX" ]] && [[ -n "\$SSH_CONNECTION" ]]; then
    # Source the session manager if it exists
    if [ -f "\$HOME/scripts/start_session.sh" ]; then
        source "\$HOME/scripts/start_session.sh"
    fi
fi
$BLOCK_END
EOF
    echo "Done! Auto-login enabled."
fi
