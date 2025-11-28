# Claude Code CLI in Docker

Docker Container für die Claude Code CLI von Anthropic mit Node.js v22 und npm v10.

**Cross-Platform:** Windows, Linux, macOS

## ☕ Support This Project

Wenn dir dieses Projekt hilft, kannst du mir gerne einen Kaffee spendieren!

<a href="https://www.buymeacoffee.com/Eutectico" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

## 🚀 Features

- **Node.js v22** (latest)
- **npm v10+**
- **Claude Code CLI** (`@anthropic-ai/claude-code`)
- **Bash Terminal** mit allen Tools
- **Persistente Konfiguration** (API Key und Einstellungen bleiben erhalten)
- **Cross-Platform** Scripts (PowerShell + Bash)

## 📦 Installation

### Voraussetzungen
- Docker installiert (Desktop oder Engine)
- Docker Compose installiert
- Anthropic API Key (erforderlich)

### API Key erhalten

1. Besuchen Sie: https://console.anthropic.com/settings/keys
2. Erstellen Sie einen neuen API Key
3. Kopieren Sie den Key (beginnt mit `sk-ant-...`)

### Setup

#### Windows (PowerShell)

1. **Container bauen und starten:**
```powershell
cd D:\scripts\copilot\claude-cli
.\start.ps1
```

2. **In den Container einloggen:**
```powershell
docker exec -it claude-code-cli /bin/bash
```

#### Linux / macOS (Bash)

1. **Scripts ausführbar machen:**
```bash
cd /path/to/claude-cli
chmod +x start.sh stop.sh check-setup.sh
```

2. **Container bauen und starten:**
```bash
./start.sh
```

> **Hinweis:** Die Scripts erkennen automatisch ob `docker-compose` oder `docker compose` verfügbar ist.

3. **In den Container einloggen:**
```bash
docker exec -it claude-code-cli /bin/bash
```

### API Key konfigurieren

1. **Beim ersten Start** wird automatisch eine `.env` Datei erstellt
2. **Bearbeiten Sie `.env`** und fügen Sie Ihren API Key ein:
```bash
ANTHROPIC_API_KEY=sk-ant-your-key-here
```

### Status prüfen

```bash
docker-compose ps
```

## 🎯 Verwendung

### Interaktiver Modus

**Direkt in den Container springen:**

Windows:
```powershell
docker exec -it claude-code-cli /bin/bash
```

Linux/macOS:
```bash
docker exec -it claude-code-cli /bin/bash
```

Im Container:
```bash
# Claude Code starten
claude

# Beispiel-Befehle:
# - Direkt im Terminal arbeiten
# - Code erklären lassen
# - Git-Workflows ausführen
# - Routine-Aufgaben automatisieren
```

### Einzelne Befehle ausführen

**Ohne in den Container zu springen:**

Windows:
```powershell
# Claude Code starten
docker exec -it claude-code-cli claude

# In Workspace arbeiten
docker exec -it claude-code-cli bash -c "cd /workspace && claude"
```

Linux/macOS:
```bash
# Claude Code starten
docker exec -it claude-code-cli claude

# In Workspace arbeiten
docker exec -it claude-code-cli bash -c "cd /workspace && claude"
```

### Workspace nutzen

Dateien im `workspace/` Ordner sind im Container verfügbar:

Windows:
```powershell
# Datei erstellen
echo "console.log('Hello')" > workspace/test.js

# Im Container bearbeiten
docker exec -it claude-code-cli bash -c "cd /workspace && cat test.js"
```

Linux/macOS:
```bash
# Datei erstellen
echo "console.log('Hello')" > workspace/test.js

# Im Container bearbeiten
docker exec -it claude-code-cli bash -c "cd /workspace && cat test.js"
```

## ⚙️ Konfiguration

### API Key ändern

Bearbeiten Sie `.env`:
```bash
ANTHROPIC_API_KEY=sk-ant-your-new-key-here
```

Dann Container neu starten:
```bash
docker-compose restart
```

### Workspace-Verzeichnis ändern

In `docker-compose.yml`:

Windows:
```yaml
volumes:
  - D:/Ihre/Projekte:/workspace  # Ihr lokaler Windows-Pfad
```

Linux/macOS:
```yaml
volumes:
  - /home/user/projekte:/workspace  # Ihr lokaler Unix-Pfad
```

### Zusätzliche Tools installieren

```bash
# Im Container
apt-get update
apt-get install -y python3 pip
```

## 🔧 Verwaltung

### Container neustarten

Windows:
```powershell
docker-compose restart
```

Linux/macOS:
```bash
docker-compose restart
```

### Container stoppen

Windows:
```powershell
.\stop.ps1
# oder manuell:
docker-compose down
```

Linux/macOS:
```bash
./stop.sh
# oder manuell:
docker-compose down
```

### Container neu bauen (nach Dockerfile-Änderungen)

```bash
docker-compose up -d --build
```

### Volumes löschen (Konfiguration geht verloren!)

```bash
docker-compose down -v
```

### Container-Logs ansehen

```bash
docker-compose logs -f
```

## 📊 Claude Code CLI Befehle

### Verfügbare Modi:

```bash
# Interaktiver Modus
claude

# Version anzeigen
claude --version

# Hilfe anzeigen
claude --help

# Diagnose-Tool
claude doctor
```

### Tipps:

- **Kontext angeben**: Claude Code versteht den Kontext Ihres Projekts
- **Code-Verständnis**: Lassen Sie sich komplexen Code erklären
- **Git-Workflows**: Automatisieren Sie Git-Operationen
- **Routine-Aufgaben**: Delegieren Sie wiederkehrende Aufgaben

## 🔐 Sicherheit

- **API Key schützen**: Niemals in Git committen (`.gitignore` ist konfiguriert)
- **Environment Variables**: API Keys nur in `.env` speichern
- **Volumes**: Persistente Daten sind in Docker Volumes gespeichert
- **Container-Isolation**: Arbeiten Sie sicher in isolierter Umgebung

## 🐛 Troubleshooting

### "API key not configured"
```bash
# Prüfen Sie .env
cat .env

# API Key sollte gesetzt sein:
# ANTHROPIC_API_KEY=sk-ant-...

# Container neu starten
docker-compose restart
```

### "Invalid API key"
- Prüfen Sie ob der API Key korrekt ist
- Erstellen Sie einen neuen Key unter: https://console.anthropic.com/settings/keys
- Aktualisieren Sie `.env` mit dem neuen Key

### Container startet nicht
```bash
# Logs prüfen
docker-compose logs

# Container neu bauen
docker-compose down
docker-compose up -d --build
```

### Node.js Version prüfen
```bash
docker exec claude-code-cli node --version
docker exec claude-code-cli npm --version
```

### Permission Denied (Linux)
```bash
# Scripts ausführbar machen
chmod +x start.sh stop.sh check-setup.sh

# Docker ohne sudo nutzen
sudo usermod -aG docker $USER
# Dann neu einloggen
```

### Docker Compose nicht gefunden (Linux)
```bash
# Moderne Docker-Installation (empfohlen)
sudo apt-get update
sudo apt-get install docker-compose-plugin

# Oder alte Version
sudo apt-get install docker-compose

# Testen
docker compose version
# oder
docker-compose version
```

## 📚 Ressourcen

- [Claude Code Dokumentation](https://docs.claude.com/en/docs/claude-code)
- [Claude Code GitHub](https://github.com/anthropics/claude-code)
- [Anthropic Console](https://console.anthropic.com/)
- [Node.js Dokumentation](https://nodejs.org/)

## 💡 Tipps & Best Practices

### Effektive Nutzung

**Im Container arbeiten:**
```bash
docker exec -it claude-code-cli /bin/bash
cd /workspace/mein-projekt
claude
```

**Kontext nutzen:**
Claude Code versteht automatisch den Kontext Ihres Projekts und kann:
- Code analysieren und erklären
- Git-Operationen durchführen
- Tests ausführen
- Refactoring vorschlagen

### Code-Verständnis

```bash
# Im Projekt-Verzeichnis
cd /workspace/mein-projekt
claude
# Dann: "Explain how the authentication system works"
```

## 🔐 Sicherheit

- **API Key**: Wird nur in Docker Volume gespeichert, nicht im Image
- **Authentifizierung**: Bleibt im Docker Volume, nicht im Container
- **Workspace**: Nur lokale Dateien im `workspace/` Ordner sind sichtbar

## ⚡ Erweiterte Nutzung

### Alias erstellen (PowerShell)

Fügen Sie zu Ihrem PowerShell-Profil hinzu:
```powershell
function claude { docker exec -it claude-code-cli claude $args }
```

Dann:
```powershell
claude
```

### Alias erstellen (Linux/macOS)

Fügen Sie zu `~/.bashrc` oder `~/.zshrc` hinzu:
```bash
alias claude='docker exec -it claude-code-cli claude'
```

Dann:
```bash
claude
```

### Permanenter Zugriff auf Projekte

In `docker-compose.yml` weitere Volumes hinzufügen:
```yaml
volumes:
  - ./workspace:/workspace
  - /home/user/projekte/app1:/projects/app1
  - /home/user/projekte/app2:/projects/app2
```

## 📖 Weitere Informationen

Siehe auch:
- `PLATFORM.md` - Plattform-spezifische Details
- `.env.example` - Environment-Variablen Template
