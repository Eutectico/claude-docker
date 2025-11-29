# Authentication Validation Script (PowerShell)
# Prüft ob die gewählte Authentifizierungsmethode korrekt konfiguriert ist

# .env Datei laden
if (-not (Test-Path ".env")) {
    Write-Host "❌ .env Datei nicht gefunden!" -ForegroundColor Red
    exit 1
}

# Parse .env file
$envVars = @{}
Get-Content ".env" | ForEach-Object {
    # Remove carriage returns and trim
    $line = $_.Trim() -replace "`r", ""
    if ($line -match '^([^#][^=]+)=(.*)$') {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        $envVars[$key] = $value
    }
}

# Standard auf api_key wenn nicht gesetzt, und trimme alle Whitespace
$AUTH_METHOD = if ($envVars['AUTH_METHOD']) {
    $envVars['AUTH_METHOD'].Trim() -replace '\s', ''
} else {
    'api_key'
}

Write-Host "🔐 Prüfe Authentifizierungsmethode: $AUTH_METHOD" -ForegroundColor Cyan
Write-Host ""

switch ($AUTH_METHOD) {
    "api_key" {
        Write-Host "Methode: Anthropic API Key" -ForegroundColor Blue
        if (-not $envVars['ANTHROPIC_API_KEY']) {
            Write-Host "❌ FEHLER: ANTHROPIC_API_KEY ist nicht gesetzt!" -ForegroundColor Red
            Write-Host "Lösung:" -ForegroundColor Yellow
            Write-Host "  1. Erstellen Sie einen API Key unter: https://console.anthropic.com/settings/keys"
            Write-Host "  2. Fügen Sie den Key in .env hinzu: ANTHROPIC_API_KEY=sk-ant-..."
            exit 1
        } elseif ($envVars['ANTHROPIC_API_KEY'] -notmatch '^sk-ant-') {
            Write-Host "⚠️  WARNUNG: API Key hat nicht das erwartete Format (sollte mit 'sk-ant-' beginnen)" -ForegroundColor Yellow
        } else {
            Write-Host "✅ API Key ist gesetzt" -ForegroundColor Green
        }
    }

    "interactive" {
        Write-Host "Methode: Interactive OAuth Login" -ForegroundColor Blue
        Write-Host "✅ Keine Vorkonfiguration erforderlich" -ForegroundColor Green
        Write-Host "Hinweis:" -ForegroundColor Yellow
        Write-Host "  Nach dem Container-Start führen Sie 'claude' aus"
        Write-Host "  Folgen Sie dann dem interaktiven Login-Prozess"
    }

    "bedrock" {
        Write-Host "Methode: AWS Bedrock" -ForegroundColor Blue
        $bedrockOk = $true

        if (-not $envVars['AWS_ACCESS_KEY_ID'] -and -not $envVars['AWS_PROFILE']) {
            Write-Host "❌ FEHLER: Weder AWS_ACCESS_KEY_ID noch AWS_PROFILE ist gesetzt!" -ForegroundColor Red
            $bedrockOk = $false
        }

        if ($envVars['AWS_ACCESS_KEY_ID'] -and -not $envVars['AWS_SECRET_ACCESS_KEY']) {
            Write-Host "❌ FEHLER: AWS_ACCESS_KEY_ID ist gesetzt, aber AWS_SECRET_ACCESS_KEY fehlt!" -ForegroundColor Red
            $bedrockOk = $false
        }

        if (-not $envVars['AWS_REGION']) {
            Write-Host "⚠️  WARNUNG: AWS_REGION nicht gesetzt, verwende Standard: us-east-1" -ForegroundColor Yellow
        }

        if ($bedrockOk) {
            Write-Host "✅ AWS Bedrock Konfiguration sieht korrekt aus" -ForegroundColor Green
            if ($envVars['AWS_ACCESS_KEY_ID']) {
                $keyPreview = $envVars['AWS_ACCESS_KEY_ID'].Substring(0, [Math]::Min(10, $envVars['AWS_ACCESS_KEY_ID'].Length))
                Write-Host "  • Access Key ID: ${keyPreview}..."
            }
            if ($envVars['AWS_PROFILE']) {
                Write-Host "  • AWS Profile: $($envVars['AWS_PROFILE'])"
            }
            $region = if ($envVars['AWS_REGION']) { $envVars['AWS_REGION'] } else { 'us-east-1' }
            Write-Host "  • Region: $region"
        } else {
            Write-Host "Lösung:" -ForegroundColor Yellow
            Write-Host "  Setzen Sie entweder:"
            Write-Host "  1. AWS_ACCESS_KEY_ID und AWS_SECRET_ACCESS_KEY, oder"
            Write-Host "  2. AWS_PROFILE für AWS CLI Profile"
            exit 1
        }
    }

    "vertex" {
        Write-Host "Methode: Google Vertex AI" -ForegroundColor Blue
        $vertexOk = $true

        if (-not $envVars['GOOGLE_CLOUD_PROJECT']) {
            Write-Host "❌ FEHLER: GOOGLE_CLOUD_PROJECT ist nicht gesetzt!" -ForegroundColor Red
            $vertexOk = $false
        }

        if (-not $envVars['GOOGLE_APPLICATION_CREDENTIALS']) {
            Write-Host "⚠️  WARNUNG: GOOGLE_APPLICATION_CREDENTIALS nicht gesetzt" -ForegroundColor Yellow
            Write-Host "  Standardmethode: Application Default Credentials wird verwendet"
        }

        if (-not $envVars['GOOGLE_CLOUD_REGION']) {
            Write-Host "⚠️  INFO: GOOGLE_CLOUD_REGION nicht gesetzt, verwende Standard: us-central1" -ForegroundColor Yellow
        }

        if ($vertexOk) {
            Write-Host "✅ Google Vertex AI Konfiguration sieht korrekt aus" -ForegroundColor Green
            Write-Host "  • Project: $($envVars['GOOGLE_CLOUD_PROJECT'])"
            $region = if ($envVars['GOOGLE_CLOUD_REGION']) { $envVars['GOOGLE_CLOUD_REGION'] } else { 'us-central1' }
            Write-Host "  • Region: $region"
        } else {
            Write-Host "Lösung:" -ForegroundColor Yellow
            Write-Host "  1. Setzen Sie GOOGLE_CLOUD_PROJECT in .env"
            Write-Host "  2. Optional: GOOGLE_APPLICATION_CREDENTIALS für Service Account"
            exit 1
        }
    }

    default {
        Write-Host "❌ FEHLER: Unbekannte Authentifizierungsmethode: $AUTH_METHOD" -ForegroundColor Red
        Write-Host "Erlaubte Werte:" -ForegroundColor Yellow
        Write-Host "  • api_key      - Anthropic API Key"
        Write-Host "  • interactive  - Interactive OAuth Login"
        Write-Host "  • bedrock      - AWS Bedrock"
        Write-Host "  • vertex       - Google Vertex AI"
        exit 1
    }
}

Write-Host ""
Write-Host "✅ Authentifizierungsprüfung erfolgreich!" -ForegroundColor Green
exit 0
