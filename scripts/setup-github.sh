#!/bin/bash

# setup-github.sh
# Digital Jukebox - GitHub Credentials Setup (Using Personal Access Token)

# -----------------------------------------------------------------------------
# 1. Gather Credentials (using PAT, NOT your GitHub password)
# -----------------------------------------------------------------------------
echo "Digital Jukebox: GitHub Configuration (Personal Access Token)"
echo "--------------------------------------------------------------"

if [ -z "$GITHUB_USER" ]; then
    read -p "Enter GitHub Username: " GH_USER
else
    read -p "Enter GitHub Username [Current: $GITHUB_USER]: " GH_USER
    GH_USER=${GH_USER:-$GITHUB_USER}
fi

echo "Enter your GitHub Personal Access Token (PAT):"
read -sp "Token: " GH_TOKEN
echo ""

if [ -z "$GH_TOKEN" ]; then
    echo "Error: GitHub Token is required."
    exit 1
fi

# -----------------------------------------------------------------------------
# 2. Update ~/.bashrc (System-wide Environment)
# -----------------------------------------------------------------------------
BASHRC="$HOME/.bashrc"
update_bashrc() {
    local key=$1
    local value=$2
    if grep -q "export $key=" "$BASHRC"; then
        sed -i "s|export $key=.*|export $key=\"$value\"|g" "$BASHRC"
    else
        echo "export $key=\"$value\"" >> "$BASHRC"
    fi
}

update_bashrc "GITHUB_USER" "$GH_USER"
update_bashrc "GITHUB_TOKEN" "$GH_TOKEN"

# -----------------------------------------------------------------------------
# 3. Update Project .env
# -----------------------------------------------------------------------------
PROJECT_ENV="$HOME/projects/Digital_Jukebox/.env"
if [ -f "$PROJECT_ENV" ]; then
    echo "Updating $PROJECT_ENV..."
    # Update GITHUB_USER
    if grep -q "^GITHUB_USER=" "$PROJECT_ENV"; then
        sed -i "s|^GITHUB_USER=.*|GITHUB_USER=\"$GH_USER\"|g" "$PROJECT_ENV"
    else
        echo "GITHUB_USER=\"$GH_USER\"" >> "$PROJECT_ENV"
    fi
    # Update GITHUB_TOKEN
    if grep -q "^GITHUB_TOKEN=" "$PROJECT_ENV"; then
        sed -i "s|^GITHUB_TOKEN=.*|GITHUB_TOKEN=\"$GH_TOKEN\"|g" "$PROJECT_ENV"
    else
        echo "GITHUB_TOKEN=\"$GH_TOKEN\"" >> "$PROJECT_ENV"
    fi
fi

# -----------------------------------------------------------------------------
# 4. Update Gemini CLI settings.json (MCP GitHub Server)
# -----------------------------------------------------------------------------
SETTINGS_JSON="$HOME/.gemini/settings.json"
if [ -f "$SETTINGS_JSON" ]; then
    echo "Updating Gemini CLI settings.json (MCP Server)..."
    # Use jq to update the GITHUB_PERSONAL_ACCESS_TOKEN inside mcpServers.github.env
    # Note: If the key doesn't exist, this might fail unless structured.
    # We assume the standard structure from Lessons Learned.
    tmp=$(mktemp)
    jq ".mcpServers.github.env.GITHUB_PERSONAL_ACCESS_TOKEN = \"$GH_TOKEN\"" "$SETTINGS_JSON" > "$tmp" && mv "$tmp" "$SETTINGS_JSON"
    echo "Gemini CLI settings updated."
else
    echo "Warning: ~/.gemini/settings.json not found. Skipping MCP update."
fi

echo "--------------------------------------------------------------"
echo "Success! GitHub credentials (PAT) updated in:"
echo " - ~/.bashrc"
echo " - $PROJECT_ENV"
echo " - $SETTINGS_JSON"
echo ""
echo "CRITICAL: Run 'source ~/.bashrc' to apply changes to this session."
echo "CRITICAL: If you updated the token, you MUST restart the Gemini CLI."
