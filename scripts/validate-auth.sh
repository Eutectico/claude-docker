#!/bin/bash
# Authentication Validation Script
# Prüft ob die gewählte Authentifizierungsmethode korrekt konfiguriert ist

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# .env Datei laden
if [ -f ".env" ]; then
    # Exportiere Variablen aus .env (ohne Kommentare und leere Zeilen)
    set -a
    source <(grep -v '^#' .env | grep -v '^$' | sed 's/\r$//')
    set +a
else
    echo -e "${RED}❌ .env Datei nicht gefunden!${NC}"
    exit 1
fi

# Standard auf api_key wenn nicht gesetzt, und trimme Whitespace
AUTH_METHOD=$(echo "${AUTH_METHOD:-api_key}" | tr -d '[:space:]')

echo -e "${BLUE}🔐 Prüfe Authentifizierungsmethode: ${AUTH_METHOD}${NC}"
echo ""

case "$AUTH_METHOD" in
    "api_key")
        echo -e "${BLUE}Methode: Anthropic API Key${NC}"
        if [ -z "$ANTHROPIC_API_KEY" ]; then
            echo -e "${RED}❌ FEHLER: ANTHROPIC_API_KEY ist nicht gesetzt!${NC}"
            echo -e "${YELLOW}Lösung:${NC}"
            echo "  1. Erstellen Sie einen API Key unter: https://console.anthropic.com/settings/keys"
            echo "  2. Fügen Sie den Key in .env hinzu: ANTHROPIC_API_KEY=sk-ant-..."
            exit 1
        elif [[ ! "$ANTHROPIC_API_KEY" =~ ^sk-ant- ]]; then
            echo -e "${YELLOW}⚠️  WARNUNG: API Key hat nicht das erwartete Format (sollte mit 'sk-ant-' beginnen)${NC}"
        else
            echo -e "${GREEN}✅ API Key ist gesetzt${NC}"
        fi
        ;;

    "interactive")
        echo -e "${BLUE}Methode: Interactive OAuth Login${NC}"
        echo -e "${GREEN}✅ Keine Vorkonfiguration erforderlich${NC}"
        echo -e "${YELLOW}Hinweis:${NC}"
        echo "  Nach dem Container-Start führen Sie 'claude' aus"
        echo "  Folgen Sie dann dem interaktiven Login-Prozess"
        ;;

    "bedrock")
        echo -e "${BLUE}Methode: AWS Bedrock${NC}"
        BEDROCK_OK=true

        if [ -z "$AWS_ACCESS_KEY_ID" ] && [ -z "$AWS_PROFILE" ]; then
            echo -e "${RED}❌ FEHLER: Weder AWS_ACCESS_KEY_ID noch AWS_PROFILE ist gesetzt!${NC}"
            BEDROCK_OK=false
        fi

        if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
            echo -e "${RED}❌ FEHLER: AWS_ACCESS_KEY_ID ist gesetzt, aber AWS_SECRET_ACCESS_KEY fehlt!${NC}"
            BEDROCK_OK=false
        fi

        if [ -z "$AWS_REGION" ]; then
            echo -e "${YELLOW}⚠️  WARNUNG: AWS_REGION nicht gesetzt, verwende Standard: us-east-1${NC}"
        fi

        if [ "$BEDROCK_OK" = true ]; then
            echo -e "${GREEN}✅ AWS Bedrock Konfiguration sieht korrekt aus${NC}"
            if [ -n "$AWS_ACCESS_KEY_ID" ]; then
                echo "  • Access Key ID: ${AWS_ACCESS_KEY_ID:0:10}..."
            fi
            if [ -n "$AWS_PROFILE" ]; then
                echo "  • AWS Profile: $AWS_PROFILE"
            fi
            echo "  • Region: ${AWS_REGION:-us-east-1}"
        else
            echo -e "${YELLOW}Lösung:${NC}"
            echo "  Setzen Sie entweder:"
            echo "  1. AWS_ACCESS_KEY_ID und AWS_SECRET_ACCESS_KEY, oder"
            echo "  2. AWS_PROFILE für AWS CLI Profile"
            exit 1
        fi
        ;;

    "vertex")
        echo -e "${BLUE}Methode: Google Vertex AI${NC}"
        VERTEX_OK=true

        if [ -z "$GOOGLE_CLOUD_PROJECT" ]; then
            echo -e "${RED}❌ FEHLER: GOOGLE_CLOUD_PROJECT ist nicht gesetzt!${NC}"
            VERTEX_OK=false
        fi

        if [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
            echo -e "${YELLOW}⚠️  WARNUNG: GOOGLE_APPLICATION_CREDENTIALS nicht gesetzt${NC}"
            echo "  Standardmethode: Application Default Credentials wird verwendet"
        fi

        if [ -z "$GOOGLE_CLOUD_REGION" ]; then
            echo -e "${YELLOW}⚠️  INFO: GOOGLE_CLOUD_REGION nicht gesetzt, verwende Standard: us-central1${NC}"
        fi

        if [ "$VERTEX_OK" = true ]; then
            echo -e "${GREEN}✅ Google Vertex AI Konfiguration sieht korrekt aus${NC}"
            echo "  • Project: $GOOGLE_CLOUD_PROJECT"
            echo "  • Region: ${GOOGLE_CLOUD_REGION:-us-central1}"
        else
            echo -e "${YELLOW}Lösung:${NC}"
            echo "  1. Setzen Sie GOOGLE_CLOUD_PROJECT in .env"
            echo "  2. Optional: GOOGLE_APPLICATION_CREDENTIALS für Service Account"
            exit 1
        fi
        ;;

    *)
        echo -e "${RED}❌ FEHLER: Unbekannte Authentifizierungsmethode: $AUTH_METHOD${NC}"
        echo -e "${YELLOW}Erlaubte Werte:${NC}"
        echo "  • api_key      - Anthropic API Key"
        echo "  • interactive  - Interactive OAuth Login"
        echo "  • bedrock      - AWS Bedrock"
        echo "  • vertex       - Google Vertex AI"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ Authentifizierungsprüfung erfolgreich!${NC}"
exit 0
