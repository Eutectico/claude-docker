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
    Write-Host "⚠️  WICHTIG: Bitte tragen Sie Ihren Anthropic API Key in .env ein!" -ForegroundColor Yellow
    Write-Host "   Bearbeiten Sie .env und setzen Sie ANTHROPIC_API_KEY=your-key-here" -ForegroundColor White
    Write-Host "   API Key erhalten Sie unter: https://console.anthropic.com/settings/keys" -ForegroundColor White
    Write-Host ""
    Read-Host "Drücken Sie Enter wenn Sie den API Key eingetragen haben"
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
