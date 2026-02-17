#!/usr/bin/env bash
set -e  # Exit on any error

APP_NAME=""
LOG_DIR="/home/ubuntu/deploy-logs"
WORK_DIR="/home/ubuntu/"

# Set PATH with all required binaries
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"

# Create log directory
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/deploy-prep-$(date +%Y%m%d-%H%M%S).log"

# Redirect all output to log file
exec >> "$LOG_FILE" 2>&1

echo "==============================="
echo "DEPLOY PREP START: $(date)"
echo "==============================="

# Change to working directory
cd "$WORK_DIR" || { echo "Failed to cd to $WORK_DIR"; exit 1; }

# Pull latest code
git pull origin main

# Flush PM2 logs
pm2 flush

# Clean the mess
docker compose down

# Verify .env exists
[ -f "docker-compose.yml" ] || { echo "Missing docker-compose.yml file"; exit 1; }

echo "==============================="
echo "DEPLOY PREP END: $(date) | STATUS: SUCCESS"
echo "==============================="

# Reload PM2 apps (or start if not running)
pm2 reload ecosystem.config.js || pm2 start ecosystem.config.js

# Keep only last 5 log files
ls -1t "$LOG_DIR"/deploy-prep-*.log | tail -n +6 | xargs -r rm -f
