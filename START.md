# App Starten

## Voraussetzungen
- Docker & Docker Compose installiert
- Flutter SDK (für lokale Entwicklung)

## Starten

1. Frontend bauen:
```bash
flutter build web --release
```

2. Alle Services starten:
```bash
docker-compose up --build
```

3. App öffnen:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8080/api/health

## Stoppen
```bash
docker-compose down
```

