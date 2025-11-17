# 📱 Score Tracker - Bedienungsanleitung

## 🎯 Was ist Score Tracker?

Score Tracker ist eine Webanwendung zum Verwalten von Spielständen. Sie können Scores für verschiedene Spiele und Spieler speichern, anzeigen und verwalten.

## 🚀 App starten

### Mit Docker (empfohlen):
```bash
docker-compose up --build
```

Dann öffnen Sie im Browser: **http://localhost:3000**

### Lokal (für Entwicklung):
```bash
# Backend starten
cd backend
go run cmd/server/main.go

# Frontend starten (in neuem Terminal)
flutter run -d chrome
```

## 📖 Funktionalität & Bedienung

### 1. Hauptansicht - Score-Liste

Nach dem Start sehen Sie die **Hauptansicht** mit:

- **App-Bar** (oben):
  - Titel: "Score Tracker"
  - Refresh-Button (🔄) - Aktualisiert die Score-Liste

- **Score-Liste** (Mitte):
  - Zeigt alle gespeicherten Scores an
  - Jeder Score zeigt:
    - **Avatar** mit Initiale des Spielers
    - **Spielername**
    - **Spiel** (z.B. "Chess", "Poker")
    - **Punkte** als Chip (z.B. "1500")
    - **Löschen-Button** (🗑️)

- **Floating Action Button** (unten rechts):
  - Plus-Symbol (+) - Öffnet Dialog zum Hinzufügen eines neuen Scores

### 2. Neuen Score hinzufügen

**Schritte:**
1. Klicken Sie auf das **+ Symbol** (unten rechts)
2. Ein Dialog öffnet sich: **"Add New Score"**
3. Füllen Sie die Felder aus:
   - **Player Name**: Name des Spielers (z.B. "Max Mustermann")
   - **Game**: Name des Spiels (z.B. "Chess", "Poker", "Tennis")
   - **Points**: Punktzahl (nur Zahlen, z.B. "1500")
4. Klicken Sie auf **"Add"**
5. Der Score wird gespeichert und in der Liste angezeigt

**Validierung:**
- Alle Felder sind **Pflichtfelder**
- Points muss eine **gültige Zahl** sein
- Bei Fehlern erscheint eine Fehlermeldung

### 3. Score löschen

**Schritte:**
1. Finden Sie den Score in der Liste
2. Klicken Sie auf das **Löschen-Symbol** (🗑️) rechts neben dem Score
3. Ein Bestätigungsdialog erscheint: **"Delete Score"**
4. Klicken Sie auf **"Delete"** zum Bestätigen
5. Der Score wird gelöscht und aus der Liste entfernt

**Hinweis:** Sie können auch auf **"Cancel"** klicken, um den Vorgang abzubrechen.

### 4. Liste aktualisieren

**Methoden:**
- **Pull-to-Refresh**: Ziehen Sie die Liste nach unten, um zu aktualisieren
- **Refresh-Button**: Klicken Sie auf das 🔄 Symbol in der App-Bar

### 5. Leere Liste

Wenn noch keine Scores vorhanden sind, sehen Sie:
```
No scores yet.
Tap the + button to add one!
```

## 🎨 UI-Features

### Responsive Design
- Die App passt sich an verschiedene Bildschirmgrößen an
- Funktioniert auf Desktop, Tablet und Mobile

### Error Handling
- **Fehler beim Laden**: Zeigt Fehlermeldung mit "Retry"-Button
- **Fehler beim Speichern**: Zeigt Snackbar mit Fehlermeldung
- **Fehler beim Löschen**: Zeigt Snackbar mit Fehlermeldung

### Success Messages
- Nach erfolgreichem Hinzufügen: Grüne Snackbar "Score added successfully"
- Nach erfolgreichem Löschen: Grüne Snackbar "Score deleted successfully"

## 📊 Beispiel-Workflow

### Beispiel 1: Schach-Turnier

1. **Score hinzufügen:**
   - Player: "Anna Schmidt"
   - Game: "Chess"
   - Points: "1850"
   - → Score wird gespeichert

2. **Weitere Scores hinzufügen:**
   - Player: "Tom Müller"
   - Game: "Chess"
   - Points: "1720"
   
   - Player: "Lisa Weber"
   - Game: "Chess"
   - Points: "1950"

3. **Liste anzeigen:**
   - Alle drei Scores werden in der Liste angezeigt
   - Sortiert nach Erstellungszeit (neueste zuerst)

4. **Score löschen:**
   - Tom Müller hat das Turnier verlassen
   - Klicken Sie auf Löschen bei seinem Score
   - Score wird entfernt

### Beispiel 2: Multi-Game Tracking

Sie können Scores für verschiedene Spiele verwalten:

- **Chess**: Anna (1850), Tom (1720)
- **Poker**: Max (5000), Sarah (3200)
- **Tennis**: Alex (120), Maria (95)

Alle Scores werden in einer gemeinsamen Liste angezeigt, aber das **Game**-Feld zeigt, welches Spiel gemeint ist.

## 🔧 Technische Details

### API-Integration
- Die App kommuniziert mit dem Go Backend über REST API
- Base URL: `http://localhost:8080/api` (standardmäßig)
- Automatisches Error Handling bei Verbindungsproblemen

### Daten-Persistenz
- Alle Scores werden in der PostgreSQL Datenbank gespeichert
- Daten bleiben erhalten, auch nach Neustart der Container

### CORS
- Backend ist für Frontend-Requests konfiguriert
- CORS erlaubt Requests von `http://localhost:3000`

## 🐛 Häufige Probleme

### "Error loading scores"
- **Ursache**: Backend läuft nicht oder nicht erreichbar
- **Lösung**: Prüfen Sie, ob Backend läuft (`docker-compose ps`)

### "Failed to create score"
- **Ursache**: Validierungsfehler oder Backend-Problem
- **Lösung**: Prüfen Sie die Eingaben und Backend-Logs

### Liste wird nicht aktualisiert
- **Ursache**: Cache-Problem oder Backend-Problem
- **Lösung**: Refresh-Button klicken oder Pull-to-Refresh

## 💡 Tipps & Tricks

1. **Schnelles Hinzufügen**: Verwenden Sie Tab-Taste zum Wechseln zwischen Feldern
2. **Mehrere Scores**: Sie können schnell mehrere Scores hintereinander hinzufügen
3. **Spielnamen konsistent halten**: Verwenden Sie immer die gleiche Schreibweise (z.B. "Chess" nicht "chess" oder "Chess Game")
4. **Browser-Refresh**: Bei Problemen können Sie die Seite im Browser neu laden (F5)

## 🎯 Nächste Schritte (Erweiterungen)

Mögliche zukünftige Features:
- ✅ Score bearbeiten (Update-Funktion bereits im Backend vorhanden)
- ✅ Filter nach Spiel
- ✅ Sortierung nach Punkten
- ✅ Statistiken (Durchschnitt, Höchstwert, etc.)
- ✅ Spieler-Profile
- ✅ Mehrere Turniere/Events

---

**Viel Spaß beim Tracken Ihrer Scores! 🎮🏆**

