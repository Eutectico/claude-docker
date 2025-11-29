#!/bin/bash
# Stop Script für Claude Code CLI Container (Linux)

echo "🛑 Stoppe Claude Code CLI Container..."

# Prüfe Docker Compose Version und setze Command
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    echo "❌ Docker Compose ist nicht installiert."
    exit 1
fi

$DOCKER_COMPOSE down

if [ $? -eq 0 ]; then
    echo "✅ Container gestoppt!"
    echo "💡 Ihre Claude Code Konfiguration bleibt erhalten."
else
    echo "❌ Fehler beim Stoppen!"
    exit 1
fi
