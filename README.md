# Score Tracker

Eine moderne Webanwendung zum Verwalten von Spielständen mit Flutter Web Frontend und Go Backend.

## 🚀 Technologie-Stack

- **Frontend**: Flutter Web
- **Backend**: Go (Golang) mit Gin Framework
- **Datenbank**: PostgreSQL
- **Containerisierung**: Docker & Docker Compose

## 📋 Voraussetzungen

- Docker & Docker Compose
- Flutter SDK (für lokale Entwicklung)
- Go 1.21+ (für lokale Entwicklung)

## 🏃 Schnellstart mit Docker

1. **Klonen Sie das Repository** (falls noch nicht geschehen)

2. **Environment-Variablen konfigurieren** (optional)
   ```bash
   cp .env.example .env
   # Bearbeiten Sie .env nach Bedarf
   ```

3. **Alle Services starten**
   ```bash
   docker-compose up --build
   ```

4. **Anwendung öffnen**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8080
   - API Health Check: http://localhost:8080/api/health

## 🛠️ Lokale Entwicklung

### Backend (Go)

```bash
cd backend

# Dependencies installieren
go mod download

# Umgebungsvariablen setzen (oder .env Datei verwenden)
export DB_HOST=localhost
export DB_PORT=5432
export DB_USER=scoretracker
export DB_PASSWORD=scoretracker_pass
export DB_NAME=scoretracker_db
export API_PORT=8080

# Server starten
go run cmd/server/main.go
```

### Frontend (Flutter Web)

```bash
# Dependencies installieren
flutter pub get

# Development Server starten
flutter run -d chrome
```

### Datenbank (PostgreSQL)

```bash
# Nur Datenbank mit Docker starten
docker-compose up postgres
```

## 📡 API Endpoints

- `GET /api/health` - Health Check
- `GET /api/scores` - Alle Scores abrufen
- `POST /api/scores` - Neuen Score erstellen
- `GET /api/scores/:id` - Score abrufen
- `PUT /api/scores/:id` - Score aktualisieren
- `DELETE /api/scores/:id` - Score löschen

### Beispiel: Score erstellen

```bash
curl -X POST http://localhost:8080/api/scores \
  -H "Content-Type: application/json" \
  -d '{
    "player": "Max Mustermann",
    "game": "Chess",
    "points": 1500
  }'
```

## 🐳 Docker Services

- **postgres**: PostgreSQL Datenbank (Port 5432)
- **backend**: Go API Server (Port 8080)
- **frontend**: Flutter Web App (Port 3000)

## 📁 Projektstruktur

```
scoretracker/
├── lib/                    # Flutter Web Frontend
│   ├── main.dart
│   └── services/
│       └── api_service.dart
├── web/                    # Web-Konfiguration
├── backend/                # Go Backend
│   ├── cmd/
│   │   └── server/
│   │       └── main.go
│   ├── internal/
│   │   ├── handlers/       # HTTP Handler
│   │   ├── models/         # Datenmodelle
│   │   ├── database/       # DB-Logik
│   │   └── middleware/     # Middleware
│   └── Dockerfile
├── docker-compose.yml      # Docker Orchestrierung
├── Dockerfile.frontend     # Flutter Web Build
└── pubspec.yaml            # Flutter Dependencies
```

## 🔧 Konfiguration

### Environment Variables

Erstellen Sie eine `.env` Datei im Root-Verzeichnis:

```bash
# Backend
API_PORT=8080

# Database
DB_HOST=postgres
DB_PORT=5432
DB_USER=scoretracker
DB_PASSWORD=scoretracker_pass
DB_NAME=scoretracker_db

# Frontend
FRONTEND_PORT=3000
API_BASE_URL=http://localhost:8080/api
```

## 🧪 Testing

```bash
# Backend Tests
cd backend
go test ./...

# Frontend Tests
flutter test
```

## 📝 Entwicklung

### Neue Features hinzufügen

1. **Backend**: Neue Handler in `backend/internal/handlers/` erstellen
2. **Models**: Neue Models in `backend/internal/models/` definieren
3. **Frontend**: Neue Services in `lib/services/` erstellen
4. **UI**: Widgets in `lib/` implementieren

### Datenbank-Migrationen

Die Datenbank-Migrationen werden automatisch beim Start des Backends ausgeführt (GORM AutoMigrate).

## 📄 License

Dieses Projekt ist für Bildungszwecke erstellt.

## 🤝 Beitrag

Beiträge sind willkommen! Bitte erstellen Sie einen Pull Request.
