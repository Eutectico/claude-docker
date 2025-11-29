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

    # Prüfe AUTH_METHOD
    if grep -q "^AUTH_METHOD=" .env; then
        AUTH_METHOD=$(grep "^AUTH_METHOD=" .env | cut -d '=' -f2)
        echo "✅ AUTH_METHOD ist gesetzt: $AUTH_METHOD"

        # Validiere die gewählte Methode
        case "$AUTH_METHOD" in
            "api_key")
                if grep -q "ANTHROPIC_API_KEY=.\+" .env; then
                    echo "✅ ANTHROPIC_API_KEY ist gesetzt"
                else
                    echo "⚠️  ANTHROPIC_API_KEY ist NICHT gesetzt"
                    echo "   Bearbeiten Sie .env und fügen Sie Ihren API Key hinzu"
                    echo "   API Key erhalten: https://console.anthropic.com/settings/keys"
                fi
                ;;
            "interactive")
                echo "✅ Interactive Login - keine Vorkonfiguration nötig"
                ;;
            "bedrock")
                if grep -q "AWS_ACCESS_KEY_ID=.\+" .env || grep -q "AWS_PROFILE=.\+" .env; then
                    echo "✅ AWS Bedrock Konfiguration gefunden"
                else
                    echo "⚠️  AWS Credentials nicht konfiguriert"
                    echo "   Setzen Sie AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY oder AWS_PROFILE"
                fi
                ;;
            "vertex")
                if grep -q "GOOGLE_CLOUD_PROJECT=.\+" .env; then
                    echo "✅ Google Vertex AI Konfiguration gefunden"
                else
                    echo "⚠️  GOOGLE_CLOUD_PROJECT ist NICHT gesetzt"
                    echo "   Setzen Sie GOOGLE_CLOUD_PROJECT in .env"
                fi
                ;;
            *)
                echo "⚠️  Unbekannte AUTH_METHOD: $AUTH_METHOD"
                echo "   Gültige Werte: api_key, interactive, bedrock, vertex"
                ;;
        esac
    else
        echo "⚠️  AUTH_METHOD ist NICHT gesetzt (Standard: api_key)"
    fi

    # Führe vollständige Validierung aus wenn verfügbar
    if [ -f "scripts/validate-auth.sh" ]; then
        echo ""
        echo "🔐 Führe vollständige Authentifizierungsvalidierung aus..."
        if bash scripts/validate-auth.sh 2>/dev/null; then
            echo ""
        else
            echo "⚠️  Validierung mit Fehlern - siehe Details oben"
        fi
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
