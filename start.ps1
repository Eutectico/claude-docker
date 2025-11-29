# Startup Script für Claude Code CLI Container (Windows)

Write-Host "🚀 Starte Claude Code CLI Container..." -ForegroundColor Cyan

# Prüfe ob Docker läuft
try {
    docker info | Out-Null
} catch {
    Write-Host "❌ Docker ist nicht verfügbar. Bitte starten Sie Docker Desktop." -ForegroundColor Red
    exit 1
}

# Prüfe Docker Compose
$dockerComposeCmd = $null
if (Get-Command docker-compose -ErrorAction SilentlyContinue) {
    $dockerComposeCmd = "docker-compose"
} elseif ((docker compose version 2>$null) -and $LASTEXITCODE -eq 0) {
    $dockerComposeCmd = "docker", "compose"
} else {
    Write-Host "❌ Docker Compose ist nicht installiert." -ForegroundColor Red
    Write-Host "Installieren Sie Docker Desktop von: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

Write-Host "📋 Nutze: $($dockerComposeCmd -join ' ')" -ForegroundColor Gray

# Erstelle Workspace-Verzeichnis falls nicht vorhanden
if (-not (Test-Path "workspace")) {
    Write-Host "📁 Erstelle workspace-Verzeichnis..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "workspace" | Out-Null
}

# Prüfe ob .env existiert
if (-not (Test-Path ".env")) {
    Write-Host "⚠️  .env Datei nicht gefunden. Erstelle aus .env.example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host ""
    Write-Host "⚠️  WICHTIG: Bitte konfigurieren Sie Ihre Authentifizierungsmethode in .env!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 Verfügbare Methoden:" -ForegroundColor Cyan
    Write-Host "  1. api_key      - Anthropic API Key (Standard)" -ForegroundColor White
    Write-Host "  2. interactive  - Interactive OAuth Login mit Claude.ai Account" -ForegroundColor White
    Write-Host "  3. bedrock      - AWS Bedrock mit IAM/OIDC" -ForegroundColor White
    Write-Host "  4. vertex       - Google Vertex AI" -ForegroundColor White
    Write-Host ""
    Write-Host "Bearbeiten Sie .env und:" -ForegroundColor White
    Write-Host "  1. Setzen Sie AUTH_METHOD auf eine der obigen Optionen" -ForegroundColor Gray
    Write-Host "  2. Konfigurieren Sie die entsprechenden Credentials" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Beispiel für API Key:" -ForegroundColor Yellow
    Write-Host "  AUTH_METHOD=api_key" -ForegroundColor Gray
    Write-Host "  ANTHROPIC_API_KEY=sk-ant-your-key-here" -ForegroundColor Gray
    Write-Host ""
    Read-Host "Drücken Sie Enter wenn Sie die Konfiguration abgeschlossen haben"
}

# Validiere Authentifizierung
if (Test-Path "scripts\validate-auth.ps1") {
    Write-Host ""
    try {
        & ".\scripts\validate-auth.ps1"
        if ($LASTEXITCODE -ne 0) {
            Write-Host ""
            Write-Host "❌ Authentifizierungsvalidierung fehlgeschlagen!" -ForegroundColor Red
            Write-Host "Bitte korrigieren Sie die Konfiguration in .env und versuchen Sie es erneut." -ForegroundColor Yellow
            exit 1
        }
    } catch {
        Write-Host "❌ Fehler bei der Authentifizierungsvalidierung: $_" -ForegroundColor Red
        exit 1
    }
}

# Baue und starte Container
Write-Host ""
Write-Host "📦 Baue und starte Docker Container..." -ForegroundColor Cyan

if ($dockerComposeCmd -is [array]) {
    & $dockerComposeCmd[0] $dockerComposeCmd[1] up -d --build
} else {
    & $dockerComposeCmd up -d --build
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Container gestartet!" -ForegroundColor Green
    Write-Host ""

    # Warte kurz bis Container bereit ist
    Start-Sleep -Seconds 3

    # Prüfe Node.js und npm Version
    Write-Host "🔍 Prüfe Installation..." -ForegroundColor Cyan
    $nodeVersion = docker exec claude-code-cli node --version
    $npmVersion = docker exec claude-code-cli npm --version

    Write-Host "  • Node.js: $nodeVersion" -ForegroundColor White
    Write-Host "  • npm: $npmVersion" -ForegroundColor White
    Write-Host "  • Claude Code CLI: installiert" -ForegroundColor White
    Write-Host ""

    Write-Host "🎯 Nächste Schritte:" -ForegroundColor Cyan
    Write-Host "  1. In Container einloggen:" -ForegroundColor White
    Write-Host "     docker exec -it claude-code-cli /bin/bash" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. Claude Code starten:" -ForegroundColor White
    Write-Host "     claude" -ForegroundColor Gray
    Write-Host ""

    Write-Host "📚 Weitere Befehle:" -ForegroundColor Cyan
    Write-Host "  • Container stoppen: .\stop.ps1" -ForegroundColor White
    Write-Host "  • Direkt Frage stellen: docker exec -it claude-code-cli claude" -ForegroundColor White
    Write-Host "  • API Key setzen: Bearbeiten Sie .env" -ForegroundColor White
    Write-Host ""

    # Frage ob direkt einloggen
    $login = Read-Host "Möchten Sie jetzt in den Container einloggen? (j/n)"
    if ($login -eq "j" -or $login -eq "J") {
        Write-Host ""
        Write-Host "🚪 Öffne interaktive Bash-Session..." -ForegroundColor Cyan
        Write-Host ""
        docker exec -it claude-code-cli /bin/bash
    }
} else {
    Write-Host ""
    Write-Host "❌ Fehler beim Starten des Containers!" -ForegroundColor Red
    Write-Host "Logs:" -ForegroundColor Yellow
    if ($dockerComposeCmd -is [array]) {
        & $dockerComposeCmd[0] $dockerComposeCmd[1] logs
    } else {
        & $dockerComposeCmd logs
    }
    exit 1
}
