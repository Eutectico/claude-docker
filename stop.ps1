# Stop Script für Claude Code CLI Container (Windows)

Write-Host "🛑 Stoppe Claude Code CLI Container..." -ForegroundColor Cyan

# Prüfe Docker Compose
$dockerComposeCmd = $null
if (Get-Command docker-compose -ErrorAction SilentlyContinue) {
    $dockerComposeCmd = "docker-compose"
} elseif ((docker compose version 2>$null) -and $LASTEXITCODE -eq 0) {
    $dockerComposeCmd = "docker", "compose"
} else {
    Write-Host "❌ Docker Compose ist nicht installiert." -ForegroundColor Red
    exit 1
}

# Stoppe Container
if ($dockerComposeCmd -is [array]) {
    & $dockerComposeCmd[0] $dockerComposeCmd[1] down
} else {
    & $dockerComposeCmd down
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Container gestoppt!" -ForegroundColor Green
    Write-Host "💡 Ihre Claude Code Konfiguration bleibt erhalten." -ForegroundColor Gray
} else {
    Write-Host "❌ Fehler beim Stoppen!" -ForegroundColor Red
    exit 1
}
