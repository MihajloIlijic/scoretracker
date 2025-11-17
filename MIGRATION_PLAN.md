# ScoreTracker - Migrationsplan zur Webanwendung mit Go-Backend

## Übersicht
Umwandlung des Flutter-Projekts in eine moderne Webanwendung mit:
- **Frontend**: Flutter Web (bestehende Struktur behalten)
- **Backend**: Go (Golang) REST API
- **Containerisierung**: Docker & Docker Compose
- **Datenbank**: PostgreSQL (empfohlen) oder SQLite für Entwicklung

## Entscheidung: Flutter Web
✅ **Entscheidung getroffen**: Wir verwenden Flutter Web als Frontend
- Bestehender Code in `lib/` kann wiederverwendet werden
- `web/` Verzeichnis bereits vorhanden
- Keine Migration zu React/Vue nötig

## Projektstruktur (Final)

```
scoretracker/
├── lib/                    # Flutter Web Frontend (BEHALTEN)
│   └── main.dart
├── web/                    # Web-Konfiguration (BEHALTEN)
│   ├── index.html
│   ├── manifest.json
│   └── icons/
├── backend/                # NEU: Go Backend
│   ├── cmd/
│   │   └── server/
│   │       └── main.go
│   ├── internal/
│   │   ├── handlers/       # HTTP Handler
│   │   ├── models/         # Datenmodelle
│   │   ├── database/       # DB-Logik
│   │   └── middleware/     # Middleware (CORS, Logging)
│   ├── go.mod
│   ├── go.sum
│   └── Dockerfile
├── pubspec.yaml            # BEHALTEN (Flutter Dependencies)
├── analysis_options.yaml   # BEHALTEN
├── docker-compose.yml      # NEU: Docker Orchestrierung
├── Dockerfile.frontend     # NEU: Flutter Web Build
├── .dockerignore           # NEU
├── .env.example            # NEU: Environment Variables Template
└── README.md
```

## Cleanup: Zu löschende Verzeichnisse

❌ **Zu löschen** (nicht für Web benötigt):
- `android/` - Android-spezifisch
- `ios/` - iOS-spezifisch
- `macos/` - macOS Desktop-spezifisch
- `linux/` - Linux Desktop-spezifisch
- `windows/` - Windows Desktop-spezifisch
- `build/` - Build-Artefakte (wird neu generiert)

✅ **Zu behalten**:
- `lib/` - Flutter/Dart Code
- `web/` - Web-Konfiguration
- `test/` - Tests (optional)
- `pubspec.yaml` - Dependencies
- `analysis_options.yaml` - Linter Config

## Schritt-für-Schritt Plan

### Phase 1: Cleanup & Projektstruktur
1. **Cleanup durchführen**
   - ❌ Löschen: `android/`, `ios/`, `macos/`, `linux/`, `windows/`, `build/`
   - ✅ Behalten: `lib/`, `web/`, `pubspec.yaml`, `analysis_options.yaml`

2. **Backend-Verzeichnisstruktur erstellen**
   - `backend/cmd/server/` - Entry Point
   - `backend/internal/handlers/` - HTTP Handler
   - `backend/internal/models/` - Datenmodelle
   - `backend/internal/database/` - DB-Logik
   - `backend/internal/middleware/` - Middleware

### Phase 2: Go Backend Setup
1. **Go-Projekt initialisieren**
   - `go mod init scoretracker/backend`
   - Basis-Struktur mit cmd/server/main.go
   - HTTP Server mit Router (z.B. Gin, Echo, oder net/http)

2. **API-Struktur definieren**
   - REST API Endpoints
   - Models/Structs für Daten
   - Handler für verschiedene Routen

3. **Datenbank Integration**
   - Datenbankwahl (PostgreSQL für Produktion, SQLite für Entwicklung)
   - ORM oder native SQL (z.B. GORM, sqlx)
   - Migrationen

4. **Middleware**
   - CORS für Frontend-Kommunikation
   - Logging
   - Error Handling

### Phase 3: Flutter Web Frontend Setup
1. **Flutter Web Dependencies prüfen**
   - `pubspec.yaml` für Web-Tauglichkeit prüfen
   - HTTP-Paket hinzufügen: `http: ^1.1.0` oder `dio: ^5.0.0`
   - State Management: `provider` oder `riverpod` (optional)

2. **API-Integration in Flutter**
   - HTTP Client Service erstellen (`lib/services/api_service.dart`)
   - API Base URL konfigurierbar machen
   - Error Handling implementieren

3. **Flutter Web Build**
   - `flutter build web` für Production
   - Output: `build/web/` Verzeichnis
   - Statische Assets für Docker

### Phase 4: Docker Setup
1. **Backend Dockerfile** (`backend/Dockerfile`)
   - Multi-stage Build: `golang:alpine` (Build) → `alpine:latest` (Runtime)
   - Go Build im Container
   - Exposed Port: `8080` (API)
   - Health Check implementieren

2. **Frontend Dockerfile** (`Dockerfile.frontend`)
   - Stage 1: `flutter/flutter:latest` für Build
   - Stage 2: `nginx:alpine` für statische Assets
   - `build/web/` Output in Nginx kopieren
   - Exposed Port: `80` (Web-App)

3. **Docker Compose** (`docker-compose.yml`)
   - Service: `backend` (Port 8080)
   - Service: `frontend` (Port 3000)
   - Service: `postgres` (Port 5432)
   - Netzwerk: `scoretracker-network`
   - Volumes: `postgres_data` für persistente Daten
   - Environment Variables aus `.env`

4. **Environment Variables**
   - `.env.example` als Template
   - `.env` für lokale Entwicklung (nicht committen!)
   - Variablen: `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `API_PORT`, etc.

### Phase 5: Integration & Testing
1. **API-Endpoints testen**
   - Postman oder curl
   - Integration zwischen Frontend und Backend

2. **CORS konfigurieren**
   - Backend CORS-Middleware für Frontend

3. **End-to-End Test**
   - Vollständiger Workflow testen

## Technologie-Stack (Final)

### Backend (Go)
- **Framework**: Gin (einfach, performant, gut dokumentiert)
- **Datenbank**: PostgreSQL mit GORM (ORM) oder sqlx (native SQL)
- **Validation**: `go-playground/validator`
- **Logging**: `logrus` oder `zap` (strukturiertes Logging)
- **CORS**: `github.com/gin-contrib/cors`

### Frontend (Flutter Web)
- **Framework**: Flutter (bereits vorhanden)
- **HTTP Client**: `http` Paket oder `dio` (mehr Features)
- **State Management**: `provider` oder `riverpod` (optional)
- **Build**: `flutter build web --release`
- **Deployment**: Nginx für statische Assets

### Docker
- **Base Images**: 
  - Backend Build: `golang:alpine`
  - Backend Runtime: `alpine:latest`
  - Frontend Build: `flutter/flutter:latest`
  - Frontend Runtime: `nginx:alpine`
  - Database: `postgres:15-alpine`

### Datenbank
- **Produktion**: PostgreSQL 15
- **Entwicklung**: PostgreSQL (via Docker) oder SQLite (optional)

## API-Spezifikation (Beispiel)

### Basis-Endpoints
```
GET  /api/health          - Health Check
GET  /api/scores          - Alle Scores abrufen
POST /api/scores          - Neuen Score erstellen
GET  /api/scores/:id      - Score abrufen
PUT  /api/scores/:id      - Score aktualisieren
DELETE /api/scores/:id    - Score löschen
```

### Datenmodell (Beispiel)
```go
type Score struct {
    ID        int       `json:"id" gorm:"primaryKey"`
    Player    string    `json:"player"`
    Points    int       `json:"points"`
    Game      string    `json:"game"`
    CreatedAt time.Time `json:"created_at"`
    UpdatedAt time.Time `json:"updated_at"`
}
```

## Nächste Schritte (Implementierungsreihenfolge)

1. ✅ Plan erstellen (DIESER SCHRITT)
2. ⏳ Cleanup: Nicht benötigte Verzeichnisse löschen
3. ⏳ Backend-Struktur erstellen
4. ⏳ Go Backend Basis-Setup (Gin, Health Check, CORS)
5. ⏳ Datenbank-Schema & Migrationen
6. ⏳ CRUD API-Endpoints implementieren
7. ⏳ Flutter Web HTTP-Integration
8. ⏳ Docker-Setup (Dockerfiles + docker-compose.yml)
9. ⏳ Testing & Integration
10. ⏳ Dokumentation

## Offene Entscheidungen

- **Datenbank**: PostgreSQL (empfohlen) oder SQLite für Start? → **Empfehlung: PostgreSQL**
- **Authentication**: Wird Auth benötigt? (JWT, OAuth, etc.) → **Später hinzufügbar**
- **API-Versionierung**: `/api/v1/` oder direkt `/api/`? → **Empfehlung: `/api/` (erstmal)**
- **Development-Modus**: Hot Reload für Flutter Web + Go Backend? → **Beide Optionen möglich**

## Risiken & Überlegungen

### Flutter Web Build
- Flutter Web Build kann groß werden → Code Splitting beachten
- Performance: Erste Render-Zeit kann höher sein als native Web-Frameworks
- Browser-Kompatibilität: Moderne Browser erforderlich

### Go Backend
- Concurrent Requests gut handhabbar
- GORM vs. sqlx: GORM einfacher, sqlx performanter
- Migrationen: Automatisch mit GORM oder manuell mit migrate

### Docker
- Flutter Build Image ist groß → Multi-stage Build wichtig
- Volumes für Development: Code-Änderungen ohne Rebuild
- Health Checks für Production-Ready Setup

## Technische Details

### Port-Konfiguration
- **Frontend**: Port `3000` (Nginx)
- **Backend API**: Port `8080` (Gin Server)
- **PostgreSQL**: Port `5432`
- **Netzwerk**: Alle Services im gleichen Docker-Netzwerk

### Environment Variables (.env)
```bash
# Backend
API_PORT=8080
API_HOST=0.0.0.0

# Database
DB_HOST=postgres
DB_PORT=5432
DB_USER=scoretracker
DB_PASSWORD=scoretracker_pass
DB_NAME=scoretracker_db

# Frontend
API_BASE_URL=http://localhost:8080/api
```

### CORS-Konfiguration
- Erlaube Requests von Frontend-Origin
- Erlaube notwendige Headers (Content-Type, Authorization)
- Erlaube HTTP-Methoden (GET, POST, PUT, DELETE)

## Deployment-Strategie

### Lokale Entwicklung
**Option 1: Docker Compose (vollständig containerisiert)**
- `docker-compose up` - Alle Services starten
- Frontend: http://localhost:3000
- Backend: http://localhost:8080

**Option 2: Hybrid (Hot Reload)**
- Backend lokal: `go run backend/cmd/server/main.go` (Port 8080)
- Frontend lokal: `flutter run -d chrome` (Hot Reload)
- Datenbank: `docker-compose up postgres` (nur DB)

### Production Build
- `docker-compose build` - Alle Images bauen
- `docker-compose up -d` - Services im Hintergrund starten
- Reverse Proxy (nginx/traefik) für Production (optional)
- Health Checks für alle Services

## Checkliste für Implementierung

- [ ] Cleanup durchführen
- [ ] Backend-Struktur erstellen
- [ ] Go Backend mit Gin initialisieren
- [ ] CORS Middleware konfigurieren
- [ ] Datenbank-Schema definieren
- [ ] CRUD Endpoints implementieren
- [ ] Flutter Web HTTP-Service erstellen
- [ ] Dockerfiles erstellen
- [ ] docker-compose.yml konfigurieren
- [ ] .env.example erstellen
- [ ] README.md aktualisieren
- [ ] Testing durchführen

## Zusammenfassung

### Was wird gemacht:
1. ✅ Flutter Web als Frontend (bestehende Struktur)
2. ✅ Go Backend mit Gin Framework
3. ✅ PostgreSQL Datenbank
4. ✅ Docker Compose für Orchestrierung
5. ✅ REST API für Score-Tracking

### Was wird gelöscht:
- ❌ Mobile/Desktop Plattformen (android, ios, macos, linux, windows)
- ❌ Build-Artefakte (build/)

### Was wird behalten:
- ✅ Flutter Code (`lib/`)
- ✅ Web-Konfiguration (`web/`)
- ✅ Flutter Dependencies (`pubspec.yaml`)

### Neue Struktur:
- ✅ `backend/` - Go Backend
- ✅ `docker-compose.yml` - Docker Orchestrierung
- ✅ `Dockerfile.frontend` - Flutter Web Build
- ✅ `.env.example` - Environment Template

---

**✅ Plan ist vollständig! Bereit für Implementierung.**

Soll ich mit der Implementierung beginnen? Starte mit:
1. Cleanup (Verzeichnisse löschen)
2. Backend-Struktur erstellen
3. Basis-Setup implementieren

