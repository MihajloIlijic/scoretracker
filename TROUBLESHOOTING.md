# Troubleshooting Guide

## Docker daemon läuft nicht

### Fehler:
```
Cannot connect to the Docker daemon at unix:///Users/.../.docker/run/docker.sock. 
Is the docker daemon running?
```

### Lösung:

**macOS:**
1. Öffnen Sie Docker Desktop (im Applications Ordner oder über Spotlight)
2. Warten Sie, bis Docker Desktop vollständig gestartet ist (Icon in der Menüleiste sollte grün sein)
3. Prüfen Sie den Status: `docker info` sollte funktionieren

**Linux:**
```bash
sudo systemctl start docker
sudo systemctl enable docker  # Für automatischen Start
```

**Windows:**
1. Öffnen Sie Docker Desktop
2. Warten Sie, bis es vollständig gestartet ist

### Prüfen ob Docker läuft:
```bash
docker info
```

Sollte eine Ausgabe ohne Fehler geben.

---

## Port bereits belegt

### Fehler:
```
Error response from daemon: Ports are not available: exposing port TCP ... address already in use
```

### Lösung:

**Option 1: Ports in docker-compose.yml ändern**
```yaml
ports:
  - "3001:80"    # Frontend auf Port 3001
  - "8081:8080"  # Backend auf Port 8081
```

**Option 2: Ports in .env Datei ändern**
```bash
FRONTEND_PORT=3001
API_PORT=8081
```

**Option 3: Prozess beenden, der den Port verwendet**
```bash
# Port finden
lsof -i :3000
lsof -i :8080

# Prozess beenden (PID aus vorherigem Befehl)
kill -9 <PID>
```

---

## Datenbank-Verbindungsfehler

### Fehler:
```
failed to connect to database: connection refused
```

### Lösung:

1. **Prüfen ob PostgreSQL läuft:**
   ```bash
   docker-compose ps postgres
   ```

2. **Logs prüfen:**
   ```bash
   docker-compose logs postgres
   ```

3. **Datenbank neu starten:**
   ```bash
   docker-compose restart postgres
   ```

4. **Warten bis Datenbank bereit ist:**
   Docker Compose wartet automatisch auf Health Check, aber manchmal dauert es länger.

---

## Backend startet nicht

### Fehler:
```
Error: failed to connect to database
```

### Lösung:

1. **Prüfen ob Backend auf Datenbank wartet:**
   ```bash
   docker-compose logs backend
   ```

2. **Backend neu starten:**
   ```bash
   docker-compose restart backend
   ```

3. **Dependencies prüfen:**
   Backend sollte `depends_on: postgres` mit `condition: service_healthy` haben.

---

## Frontend baut nicht / Flutter Image Fehler

### Fehler:
```
failed to resolve source metadata for docker.io/flutter/flutter:latest: 
pull access denied, repository does not exist
```

### Lösung:

**Option 1: Alternative Flutter Image (bereits implementiert)**
Das Dockerfile verwendet jetzt `cirrusci/flutter:latest`. Falls das auch nicht funktioniert:

1. **Dockerfile.frontend prüfen** - sollte `cirrusci/flutter:latest` verwenden
2. **Image manuell pullen:**
   ```bash
   docker pull cirrusci/flutter:latest
   ```

**Option 2: Frontend lokal bauen (Alternative)**
Wenn das Flutter Docker Image weiterhin Probleme macht:

1. **Frontend lokal bauen:**
   ```bash
   flutter pub get
   flutter build web --release
   ```

2. **Dockerfile.frontend.simple verwenden:**
   ```bash
   # In docker-compose.yml ändern:
   dockerfile: Dockerfile.frontend.simple
   ```

3. **Neu bauen:**
   ```bash
   docker-compose build frontend
   ```

### Weitere Tipps:

1. **Logs prüfen:**
   ```bash
   docker-compose logs frontend
   ```

2. **Docker Cache leeren:**
   ```bash
   docker-compose build --no-cache frontend
   ```

3. **Flutter Version prüfen:**
   Das Dockerfile verwendet `cirrusci/flutter:latest`. Falls es Probleme gibt, können Sie eine spezifische Version verwenden.

---

## Alle Container löschen und neu starten

### Vollständiger Reset:

```bash
# Alle Container stoppen und entfernen
docker-compose down -v

# Volumes löschen (ACHTUNG: Daten gehen verloren!)
docker volume prune

# Neu bauen und starten
docker-compose up --build
```

---

## CORS-Fehler im Browser

### Fehler:
```
Access to XMLHttpRequest has been blocked by CORS policy
```

### Lösung:

1. **Backend CORS-Konfiguration prüfen** in `backend/cmd/server/main.go`
2. **Frontend URL hinzufügen** zu `AllowOrigins`
3. **Backend neu starten:**
   ```bash
   docker-compose restart backend
   ```

---

## Häufige Befehle

```bash
# Status prüfen
docker-compose ps

# Logs anzeigen
docker-compose logs -f

# Einzelnen Service neu starten
docker-compose restart <service-name>

# Alle Services neu starten
docker-compose restart

# Container-Status prüfen
docker ps -a

# Images anzeigen
docker images

# Docker System aufräumen
docker system prune -a
```

