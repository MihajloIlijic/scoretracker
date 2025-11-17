# Quick Start Guide

## 🚀 In 3 Schritten starten

### 1. Dependencies installieren (optional für lokale Entwicklung)

```bash
# Flutter Dependencies
flutter pub get

# Go Dependencies
cd backend
go mod download
cd ..
```

### 2. Docker Compose starten

```bash
docker-compose up --build
```

Das startet automatisch:
- ✅ PostgreSQL Datenbank
- ✅ Go Backend API (Port 8080)
- ✅ Flutter Web Frontend (Port 3000)

### 3. Öffnen Sie die Anwendung

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080/api/health

## 🛑 Stoppen

```bash
docker-compose down
```

## 🔄 Neustart nach Änderungen

```bash
# Stoppen
docker-compose down

# Neu bauen und starten
docker-compose up --build
```

## 📝 Erste Schritte

1. Öffnen Sie http://localhost:3000 im Browser
2. Klicken Sie auf das "+" Symbol
3. Geben Sie einen Spieler, ein Spiel und Punkte ein
4. Score wird gespeichert und angezeigt

## 🐛 Troubleshooting

### Port bereits belegt?
Ändern Sie die Ports in `docker-compose.yml` oder `.env`:

```yaml
ports:
  - "3001:80"  # Frontend auf Port 3001
  - "8081:8080"  # Backend auf Port 8081
```

### Datenbank-Verbindungsfehler?
Stellen Sie sicher, dass PostgreSQL vollständig gestartet ist:
```bash
docker-compose logs postgres
```

### Backend startet nicht?
Prüfen Sie die Logs:
```bash
docker-compose logs backend
```

### Frontend baut nicht?
Prüfen Sie die Logs:
```bash
docker-compose logs frontend
```

## 🔧 Lokale Entwicklung (ohne Docker)

### Option 1: Nur Datenbank mit Docker
```bash
docker-compose up postgres
```

### Option 2: Alles lokal
1. PostgreSQL lokal installieren und starten
2. Backend: `cd backend && go run cmd/server/main.go`
3. Frontend: `flutter run -d chrome`

