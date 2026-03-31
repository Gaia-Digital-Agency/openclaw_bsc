#!/bin/bash
# sync-google-auth.sh
# Syncs the Google API key from the main agent's auth-profiles.json
# to all other agents. Run this whenever agents are recreated or
# after an OpenClaw update if Brian/Zack/Casey stop responding.
#
# Usage: bash ~/.openclaw/sync-google-auth.sh
#        Or with a specific key: bash ~/.openclaw/sync-google-auth.sh AIzaSy...

set -e

OPENCLAW_DIR="/home/azlan/.openclaw"
AGENTS=("bsc" "zen" "mna")

# Determine the Google API key
if [ -n "$1" ]; then
  GOOGLE_KEY="$1"
else
  # Read from main agent's auth-profiles.json
  GOOGLE_KEY=$(python3 -c "
import json
with open('$OPENCLAW_DIR/agents/main/agent/auth-profiles.json') as f:
    data = json.load(f)
print(data['profiles']['google:default']['key'])
" 2>/dev/null)
fi

if [ -z "$GOOGLE_KEY" ]; then
  echo "ERROR: Could not find Google API key. Pass it as argument: $0 AIzaSy..."
  exit 1
fi

echo "Syncing Google API key to agents: ${AGENTS[*]}"

for AGENT in "${AGENTS[@]}"; do
  PROFILE_FILE="$OPENCLAW_DIR/agents/$AGENT/agent/auth-profiles.json"

  if [ ! -f "$PROFILE_FILE" ]; then
    echo "WARNING: $PROFILE_FILE not found, skipping $AGENT"
    continue
  fi

  # Check if google:default already exists with same key
  EXISTING_KEY=$(python3 -c "
import json
with open('$PROFILE_FILE') as f:
    data = json.load(f)
print(data.get('profiles', {}).get('google:default', {}).get('key', ''))
" 2>/dev/null)

  if [ "$EXISTING_KEY" = "$GOOGLE_KEY" ]; then
    echo "  [$AGENT] Already has correct Google API key, skipping"
    continue
  fi

  # Add/update the google:default profile
  python3 -c "
import json
with open('$PROFILE_FILE') as f:
    data = json.load(f)

data.setdefault('profiles', {})['google:default'] = {
    'type': 'api_key',
    'provider': 'google',
    'key': '$GOOGLE_KEY'
}
data.setdefault('lastGood', {})['google'] = 'google:default'

with open('$PROFILE_FILE', 'w') as f:
    json.dump(data, f, indent=2)
print('  [$AGENT] Updated with Google API key')
"
done

echo ""
echo "Done. Restart the gateway if it's running:"
echo "  openclaw gateway restart"
