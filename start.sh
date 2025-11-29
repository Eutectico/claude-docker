#!/bin/bash
# Startup Script für Claude Code CLI Container (Linux)

echo "🚀 Starte Claude Code CLI Container..."

# Prüfe ob Docker läuft
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker ist nicht verfügbar. Bitte starten Sie Docker."
    exit 1
fi

# Prüfe Docker Compose Version und setze Command
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
else
    echo "❌ Docker Compose ist nicht installiert."
    echo "Installieren Sie es mit: sudo apt-get install docker-compose-plugin"
    exit 1
fi

echo "📋 Nutze: $DOCKER_COMPOSE"

# Erstelle Workspace-Verzeichnis falls nicht vorhanden
if [ ! -d "workspace" ]; then
    echo "📁 Erstelle workspace-Verzeichnis..."
    mkdir -p workspace
fi

# Prüfe ob .env existiert
if [ ! -f ".env" ]; then
    echo "⚠️  .env Datei nicht gefunden. Erstelle aus .env.example..."
    cp .env.example .env
    echo ""
    echo "⚠️  WICHTIG: Bitte konfigurieren Sie Ihre Authentifizierungsmethode in .env!"
    echo ""
    echo "📋 Verfügbare Methoden:"
    echo "  1. api_key      - Anthropic API Key (Standard)"
    echo "  2. interactive  - Interactive OAuth Login mit Claude.ai Account"
    echo "  3. bedrock      - AWS Bedrock mit IAM/OIDC"
    echo "  4. vertex       - Google Vertex AI"
    echo ""
    echo "Bearbeiten Sie .env und:"
    echo "  1. Setzen Sie AUTH_METHOD auf eine der obigen Optionen"
    echo "  2. Konfigurieren Sie die entsprechenden Credentials"
    echo ""
    echo "Beispiel für API Key:"
    echo "  AUTH_METHOD=api_key"
    echo "  ANTHROPIC_API_KEY=sk-ant-your-key-here"
    echo ""
    read -p "Drücken Sie Enter wenn Sie die Konfiguration abgeschlossen haben..."
fi

# Validiere Authentifizierung
if [ -f "scripts/validate-auth.sh" ]; then
    echo ""
    if ! bash scripts/validate-auth.sh; then
        echo ""
        echo "❌ Authentifizierungsvalidierung fehlgeschlagen!"
        echo "Bitte korrigieren Sie die Konfiguration in .env und versuchen Sie es erneut."
        exit 1
    fi
fi

# Baue und starte Container
echo ""
echo "📦 Baue und starte Docker Container..."
$DOCKER_COMPOSE up -d --build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Container gestartet!"
    echo ""

    # Warte kurz bis Container bereit ist
    sleep 3

    # Prüfe Node.js und npm Version
    echo "🔍 Prüfe Installation..."
    NODE_VERSION=$(docker exec claude-code-cli node --version)
    NPM_VERSION=$(docker exec claude-code-cli npm --version)

    echo "  • Node.js: $NODE_VERSION"
    echo "  • npm: $NPM_VERSION"
    echo "  • Claude Code CLI: installiert"
    echo ""

    echo "🎯 Nächste Schritte:"
    echo "  1. In Container einloggen:"
    echo "     docker exec -it claude-code-cli /bin/bash"
    echo ""
    echo "  2. Claude Code starten:"
    echo "     claude"
    echo ""

    echo "📚 Weitere Befehle:"
    echo "  • Container stoppen: ./stop.sh"
    echo "  • Direkt Frage stellen: docker exec -it claude-code-cli claude"
    echo "  • API Key setzen: Bearbeiten Sie .env"
    echo ""

    # Frage ob direkt einloggen
    read -p "Möchten Sie jetzt in den Container einloggen? (j/n): " LOGIN
    if [ "$LOGIN" = "j" ] || [ "$LOGIN" = "J" ]; then
        echo ""
        echo "🚪 Öffne interaktive Bash-Session..."
        echo ""
        docker exec -it claude-code-cli /bin/bash
    fi
else
    echo ""
    echo "❌ Fehler beim Starten des Containers!"
    echo "Logs:"
    $DOCKER_COMPOSE logs
    exit 1
fi
