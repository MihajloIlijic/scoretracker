# 📱 Score Tracker - App Übersicht

## 🎯 Hauptfunktionen

### ✅ Implementiert

1. **Score anzeigen** - Liste aller gespeicherten Scores
2. **Score hinzufügen** - Neuen Score mit Spieler, Spiel und Punkten erstellen
3. **Score löschen** - Score aus der Datenbank entfernen
4. **Liste aktualisieren** - Refresh-Funktion (Button + Pull-to-Refresh)

### 🔄 Verfügbar im Backend (noch nicht im UI)

- **Score bearbeiten** - Update-Funktion existiert im Backend, UI-Feature kann hinzugefügt werden

## 📐 UI-Struktur

```
┌─────────────────────────────────────┐
│  Score Tracker          [🔄 Refresh]│  ← App Bar
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 👤  Max Mustermann            │ │
│  │     Game: Chess               │ │
│  │     [1500]          [🗑️]      │ │  ← Score Card
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 👤  Anna Schmidt              │ │
│  │     Game: Poker               │ │
│  │     [3200]          [🗑️]      │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 👤  Tom Müller                │ │
│  │     Game: Chess               │ │
│  │     [1720]          [🗑️]      │ │
│  └───────────────────────────────┘ │
│                                     │
│                                     │
│                          ┌──────┐  │
│                          │  +   │  │  ← Floating Action Button
│                          └──────┘  │
└─────────────────────────────────────┘
```

## 🔄 User Flows

### Flow 1: Score hinzufügen

```
1. User klickt auf [+] Button
   ↓
2. Dialog öffnet sich
   ├─ Player Name: [___________]
   ├─ Game:        [___________]
   └─ Points:      [___________]
   ↓
3. User füllt Felder aus
   ↓
4. User klickt "Add"
   ↓
5. API Request → Backend → Datenbank
   ↓
6. Erfolg: Score in Liste angezeigt
   Fehler: Fehlermeldung angezeigt
```

### Flow 2: Score löschen

```
1. User klickt auf [🗑️] bei einem Score
   ↓
2. Bestätigungsdialog erscheint
   "Are you sure you want to delete [Name]'s score?"
   [Cancel] [Delete]
   ↓
3. User klickt "Delete"
   ↓
4. API Request → Backend → Datenbank
   ↓
5. Erfolg: Score aus Liste entfernt
   Fehler: Fehlermeldung angezeigt
```

### Flow 3: Liste aktualisieren

```
Option A: Refresh Button
1. User klickt [🔄] in App Bar
   ↓
2. API Request → Backend
   ↓
3. Liste wird aktualisiert

Option B: Pull-to-Refresh
1. User zieht Liste nach unten
   ↓
2. API Request → Backend
   ↓
3. Liste wird aktualisiert
```

## 📊 Datenmodell

### Score-Objekt

```dart
Score {
  id: int?           // Automatisch generiert
  player: string     // Name des Spielers (Pflicht)
  game: string       // Name des Spiels (Pflicht)
  points: int        // Punktzahl (Pflicht)
  createdAt: DateTime?  // Automatisch gesetzt
  updatedAt: DateTime?  // Automatisch aktualisiert
}
```

### Beispiel-Daten

```json
{
  "id": 1,
  "player": "Max Mustermann",
  "game": "Chess",
  "points": 1500,
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

## 🎨 UI-Komponenten

### 1. App Bar
- **Titel**: "Score Tracker"
- **Aktionen**: Refresh-Button (🔄)

### 2. Score Card (List Item)
- **Avatar**: Kreis mit Initiale des Spielers
- **Titel**: Spielername
- **Subtitle**: "Game: [Spielname]"
- **Trailing**: 
  - Punkte-Chip (z.B. "1500")
  - Löschen-Button (🗑️)

### 3. Floating Action Button
- **Icon**: Plus (+)
- **Aktion**: Öffnet Add-Score-Dialog

### 4. Add Score Dialog
- **Titel**: "Add New Score"
- **Felder**:
  - Player Name (Text Input)
  - Game (Text Input)
  - Points (Number Input)
- **Buttons**: Cancel, Add

### 5. Delete Confirmation Dialog
- **Titel**: "Delete Score"
- **Content**: Bestätigungstext
- **Buttons**: Cancel, Delete

### 6. Empty State
- **Text**: "No scores yet.\nTap the + button to add one!"

### 7. Error State
- **Text**: Fehlermeldung
- **Button**: "Retry"

### 8. Loading State
- **Indicator**: CircularProgressIndicator

## 🔔 Feedback-Mechanismen

### Success Messages (Snackbar)
- ✅ "Score added successfully" (grün)
- ✅ "Score deleted successfully" (grün)

### Error Messages (Snackbar)
- ❌ "Error adding score: [Details]"
- ❌ "Error deleting score: [Details]"

### Error State
- ❌ "Error loading scores: [Details]"
- 🔄 "Retry" Button

## 📱 Responsive Design

- **Desktop**: Optimale Darstellung auf großen Bildschirmen
- **Tablet**: Angepasste Layouts
- **Mobile**: Touch-optimiert, Pull-to-Refresh

## 🔐 Validierung

### Client-Side (Flutter)
- Player Name: Nicht leer
- Game: Nicht leer
- Points: Muss eine gültige Zahl sein

### Server-Side (Go)
- Alle Felder werden validiert
- Datenbank-Constraints werden geprüft

## 🚀 Performance

- **Lazy Loading**: Liste lädt nur sichtbare Items
- **Caching**: Scores werden im State gespeichert
- **Optimistic Updates**: UI aktualisiert sofort, dann Server-Sync

## 🎯 Use Cases

### Use Case 1: Turnier-Tracking
**Szenario**: Schach-Turnier mit mehreren Spielern
- Scores für jeden Spieler hinzufügen
- Punkte nach jeder Runde aktualisieren (durch Löschen + Neu-Erstellen)
- Liste zeigt alle Teilnehmer

### Use Case 2: Multi-Game Leaderboard
**Szenario**: Verschiedene Spiele verwalten
- Scores für Chess, Poker, Tennis, etc.
- Alle in einer Liste
- Game-Feld zeigt Unterschiede

### Use Case 3: Persönliche Statistik
**Szenario**: Eigene Scores über Zeit tracken
- Eigene Scores hinzufügen
- Entwicklung über Zeit sehen (durch Liste)

## 🔮 Mögliche Erweiterungen

### Kurzfristig
- [ ] Score bearbeiten (Update-UI)
- [ ] Filter nach Spiel
- [ ] Sortierung (nach Punkten, Name, Datum)

### Mittelfristig
- [ ] Statistiken (Durchschnitt, Max, Min)
- [ ] Charts/Graphs
- [ ] Export (CSV, JSON)

### Langfristig
- [ ] Spieler-Profile
- [ ] Turniere/Events
- [ ] Multi-User Support
- [ ] Authentication

---

**Die App ist einfach, intuitiv und fokussiert auf das Wesentliche: Scores verwalten! 🎮**

