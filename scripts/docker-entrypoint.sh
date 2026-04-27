#!/bin/sh
set -e

# Capture runtime UID/GID from environment variables, defaulting to 1000
PUID=${USER_UID:-1000}
PGID=${USER_GID:-1000}

# Adjust the node user's UID/GID if they differ from the runtime request
# and fix volume ownership only when a remap is needed
changed=0

if [ "$(id -u node)" -ne "$PUID" ]; then
    echo "Updating node UID to $PUID"
    usermod -o -u "$PUID" node
    changed=1
fi

if [ "$(id -g node)" -ne "$PGID" ]; then
    echo "Updating node GID to $PGID"
    groupmod -o -g "$PGID" node
    usermod -g "$PGID" node
    changed=1
fi

if [ "$changed" = "1" ]; then
    chown -R node:node /paperclip
fi

# Restore Claude Code credentials from persistent volume
if [ -f /paperclip/.claude/.credentials.json ]; then
    mkdir -p /home/node/.claude
    cp /paperclip/.claude/.credentials.json /home/node/.claude/.credentials.json
    chown -R node:node /home/node/.claude
    echo "Claude Code credentials restored from volume"
fi

# Restore Gemini OAuth credentials from persistent volume
if [ -d /paperclip/.gemini ]; then
    cp -r /paperclip/.gemini /home/node/.gemini
    chown -R node:node /home/node/.gemini
    echo "Gemini OAuth credentials restored from volume"
fi
exec gosu node "$@"
