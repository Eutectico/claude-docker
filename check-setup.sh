#!/bin/bash
# Quick Check Script für Docker Setup (Linux)

echo "🔍 Prüfe Docker Installation..."
echo ""

# Check Docker
if command -v docker &> /dev/null; then
    echo "✅ Docker installiert:"
    docker --version
else
    echo "❌ Docker NICHT installiert"
    echo "   Installation: sudo apt-get install docker.io"
fi

echo ""

# Check Docker läuft
if docker info > /dev/null 2>&1; then
    echo "✅ Docker läuft"
else
    echo "❌ Docker läuft NICHT"
    echo "   Starten: sudo systemctl start docker"
    echo "   Auto-Start: sudo systemctl enable docker"
fi

echo ""

# Check Docker Compose
if command -v docker-compose &> /dev/null; then
    echo "✅ docker-compose (alt) installiert:"
    docker-compose --version
elif docker compose version &> /dev/null 2>&1; then
    echo "✅ docker compose (neu) installiert:"
    docker compose version
else
    echo "❌ Docker Compose NICHT installiert"
    echo "   Installation: sudo apt-get install docker-compose-plugin"
fi

echo ""

# Check Benutzer in docker Gruppe
if groups | grep -q docker; then
    echo "✅ Benutzer ist in docker-Gruppe"
else
    echo "⚠️  Benutzer ist NICHT in docker-Gruppe"
    echo "   Hinzufügen: sudo usermod -aG docker \$USER"
    echo "   Dann: neu einloggen"
fi

echo ""

# Check Scripts
if [ -f "start.sh" ] && [ -x "start.sh" ]; then
    echo "✅ start.sh ist ausführbar"
else
    echo "⚠️  start.sh ist NICHT ausführbar"
    echo "   Beheben: chmod +x start.sh"
fi

if [ -f "stop.sh" ] && [ -x "stop.sh" ]; then
    echo "✅ stop.sh ist ausführbar"
else
    echo "⚠️  stop.sh ist NICHT ausführbar"
    echo "   Beheben: chmod +x stop.sh"
fi

echo ""

# Check .env
if [ -f ".env" ]; then
    echo "✅ .env Datei existiert"
    if grep -q "ANTHROPIC_API_KEY=.\+" .env; then
        echo "✅ ANTHROPIC_API_KEY ist gesetzt"
    else
        echo "⚠️  ANTHROPIC_API_KEY ist NICHT gesetzt"
        echo "   Bearbeiten Sie .env und fügen Sie Ihren API Key hinzu"
        echo "   API Key erhalten: https://console.anthropic.com/settings/keys"
    fi
else
    echo "⚠️  .env Datei existiert NICHT"
    echo "   Wird beim ersten Start automatisch erstellt"
fi

echo ""
echo "📊 Zusammenfassung:"

# Prüfe alles
ALL_OK=true

if ! command -v docker &> /dev/null; then ALL_OK=false; fi
if ! docker info > /dev/null 2>&1; then ALL_OK=false; fi
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then ALL_OK=false; fi

if [ "$ALL_OK" = true ]; then
    echo "✅ Alles bereit! Sie können ./start.sh ausführen."
else
    echo "❌ Einige Komponenten fehlen. Siehe oben für Details."
fi
