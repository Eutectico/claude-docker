# Claude Code CLI - Plattform-Übersicht

## 📋 Dateien

| Datei | Zweck | Plattform |
|-------|-------|-----------|
| `Dockerfile` | Container-Definition | Alle |
| `docker-compose.yml` | Docker Compose Config | Alle |
| `start.ps1` | Start-Script | Windows |
| `stop.ps1` | Stop-Script | Windows |
| `start.sh` | Start-Script | Linux/macOS |
| `stop.sh` | Stop-Script | Linux/macOS |
| `check-setup.sh` | Setup-Prüfung | Linux/macOS |
| `.env.example` | Umgebungsvariablen Template | Alle |
| `.env` | Ihre API Key Konfiguration (erstellt) | Alle |
| `README.md` | Dokumentation | Alle |
| `PLATFORM.md` | Plattform-Guide | Alle |

## 🚀 Schnellstart

### Windows
```powershell
cd D:\scripts\copilot\claude-cli
.\start.ps1
```

### Linux/macOS
```bash
cd /path/to/claude-cli
chmod +x *.sh
./check-setup.sh  # Optional: Prüft Installation
./start.sh
```

## 🔧 Wichtige Befehle

### Container Management

| Aktion | Windows | Linux/macOS |
|--------|---------|-------------|
| Starten | `.\start.ps1` | `./start.sh` |
| Stoppen | `.\stop.ps1` | `./stop.sh` |
| Einloggen | `docker exec -it claude-code-cli /bin/bash` | `docker exec -it claude-code-cli /bin/bash` |
| Logs | `docker-compose logs -f` | `docker-compose logs -f` |

### Claude Code verwenden

Alle Plattformen:
```bash
# Im Container
docker exec -it claude-code-cli /bin/bash
claude

# Direkt von außen
docker exec -it claude-code-cli claude
```

## 📂 Verzeichnis-Struktur

```
claude-cli/
├── Dockerfile              # Container-Image Definition
├── docker-compose.yml      # Docker Compose Konfiguration
├── start.ps1              # Windows Start-Script
├── stop.ps1               # Windows Stop-Script
├── start.sh               # Linux/macOS Start-Script
├── stop.sh                # Linux/macOS Stop-Script
├── check-setup.sh         # Linux/macOS Setup-Prüfung
├── .env.example           # Environment Template
├── .env                   # Ihre Konfiguration (erstellt)
├── .dockerignore          # Docker Build Ausschlüsse
├── .gitignore             # Git Ausschlüsse
├── README.md              # Hauptdokumentation
├── PLATFORM.md            # Diese Datei
└── workspace/             # Ihr Arbeitsverzeichnis (erstellt)
```

## 🔐 Volumes

| Volume | Beschreibung |
|--------|--------------|
| `claude_config` | Persistente Claude Code Konfiguration |
| `claude_cache` | Cache für bessere Performance |
| `./workspace` | Lokales Arbeitsverzeichnis |

## 🌐 Netzwerk

Container nutzt Bridge-Netzwerk. Keine exponierten Ports notwendig (CLI-only).

## ⚙️ Anpassungen

### Zusätzliche Verzeichnisse mounten

Bearbeiten Sie `docker-compose.yml`:

```yaml
volumes:
  - claude_config:/root/.config
  - claude_cache:/root/.cache
  - ./workspace:/workspace
  - /ihr/projekt/pfad:/projects/mein-projekt  # Neu
```

**Windows:** `D:/Projekte:/projects`
**Linux:** `/home/user/projekte:/projects`

### Zusätzliche Tools installieren

Im Container:
```bash
apt-get update
apt-get install -y python3 git vim
```

Oder im `Dockerfile` permanent hinzufügen.

## 🔑 API Key Verwaltung

### API Key erhalten

1. Besuchen Sie: https://console.anthropic.com/settings/keys
2. Erstellen Sie einen neuen API Key
3. Kopieren Sie den Key (beginnt mit `sk-ant-...`)

### API Key konfigurieren

In `.env`:
```bash
ANTHROPIC_API_KEY=sk-ant-your-key-here
```

### API Key ändern

1. Bearbeiten Sie `.env`
2. Container neu starten: `docker-compose restart`

## 🐛 Troubleshooting

### Script-Permissions (Linux/macOS)
```bash
chmod +x *.sh
```

### Docker läuft nicht
```bash
# Linux
sudo systemctl start docker
sudo systemctl enable docker  # Auto-Start aktivieren

# macOS
# Docker Desktop starten

# Windows
# Docker Desktop starten
```

### Docker Compose Installation (Linux)

**Neue Version (Plugin - empfohlen):**
```bash
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
docker compose version
```

**Alte Version (standalone):**
```bash
sudo apt-get install docker-compose
docker-compose version
```

Die Scripts funktionieren mit beiden Versionen automatisch!

### Claude Code CLI nicht gefunden
```bash
# Container neu bauen
docker-compose down
docker-compose up -d --build
```

### API Key Fehler

**"API key not configured":**
```bash
# Prüfen Sie .env
cat .env

# API Key sollte gesetzt sein
nano .env
# Fügen Sie hinzu: ANTHROPIC_API_KEY=sk-ant-...

# Container neu starten
docker-compose restart
```

**"Invalid API key":**
- Erstellen Sie einen neuen Key: https://console.anthropic.com/settings/keys
- Aktualisieren Sie `.env`
- Container neu starten

### Check Setup (Linux/macOS)

Nutzen Sie das Setup-Prüfungs-Script:
```bash
./check-setup.sh
```

Das Script prüft:
- Docker Installation
- Docker läuft
- Docker Compose verfügbar
- Benutzer in docker-Gruppe
- Scripts sind ausführbar
- `.env` existiert und API Key ist gesetzt

## 💡 Best Practices

1. **API Key sicher**: Niemals in Git committen (`.gitignore` schützt `.env`)
2. **Workspace nutzen**: Dateien in `workspace/` für Container-Zugriff
3. **Volumes behalten**: Nie `docker-compose down -v` nutzen (löscht Config!)
4. **Regelmäßig updaten**: `docker-compose pull && docker-compose up -d --build`
5. **Setup prüfen**: Nutzen Sie `check-setup.sh` (Linux/macOS) vor dem ersten Start

## 🔒 Sicherheits-Hinweise

- **API Key**: Nie in Code oder Git committen
- **Environment**: Immer `.env` für sensible Daten nutzen
- **Volumes**: Persistente Daten sind lokal in Docker Volumes
- **Container-Isolation**: Arbeiten in isolierter Umgebung
- **Backup**: `.env` regelmäßig sichern (enthält API Key)

## 📝 Unterschiede zu GitHub Copilot CLI

| Feature | GitHub Copilot CLI | Claude Code CLI |
|---------|-------------------|-----------------|
| Authentifizierung | GitHub OAuth | API Key |
| Package | `@github/copilot` | `@anthropic-ai/claude-code` |
| Container Name | `github-copilot-cli` | `claude-code-cli` |
| Volumes | 1 (config) | 2 (config + cache) |
| API Key | Optional (GITHUB_TOKEN) | Erforderlich (ANTHROPIC_API_KEY) |

## 🚀 Nächste Schritte

1. **Setup prüfen** (Linux/macOS): `./check-setup.sh`
2. **Container starten**: `./start.sh` oder `.\start.ps1`
3. **API Key setzen**: Bearbeiten Sie `.env`
4. **In Container einloggen**: `docker exec -it claude-code-cli /bin/bash`
5. **Claude Code starten**: `claude`
