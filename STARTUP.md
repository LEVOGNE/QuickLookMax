# STARTUP.md

Allgemeine Fibel fuer neue Projekte.

Dieses Dokument verdichtet bewaehrte Architektur-, Sicherheits-, Design- und Wartbarkeitserkenntnisse in einer einzigen Startanleitung.

Ziel: Ein neues Projekt von Anfang an so aufsetzen, dass Struktur, Sicherheit, Design, Animation, Echtzeit, Wiederverwendbarkeit und Wartbarkeit direkt sauber verankert sind.

---

## 1. Zweck dieses Dokuments

Dieses Dokument ist keine lose Ideensammlung.
Es ist die verbindliche Startfibel fuer neue Projekte.

Wenn ein neues Projekt beginnt, gilt:
- Erst `STARTUP.md` lesen
- Dann Projektregeln festschreiben
- Dann Architektur und Sicherheitsfundament bauen
- Erst danach das erste Fachfeature implementieren

Die wichtigste Erkenntnis:
- Viele Probleme entstehen nicht, weil man schlecht programmiert, sondern weil gewisse Gesetze zu spaet festgelegt wurden.
- Besonders kritisch sind dabei: CSP, CSRF, sicheres Rendering, Animationen, Layout-Systeme, Echtzeit-Updates, Migrationsstrategie und Wiederverwendbarkeit.

---

## 2. Kernphilosophie

### 2.1 Zentral, klar, streng

Das Projekt soll nicht aus unkontrolliert vielen Dateien bestehen.
Es soll zentral, lesbar und diszipliniert aufgebaut sein.

Grundsatz:
- so wenig Dateien wie sinnvoll
- so viel Struktur wie noetig
- keine chaotische Verteilung von Logik
- keine Logik in Templates
- keine doppelten Implementierungen

Das bedeutet:
- eine zentrale Core-Datei fuer Backend-Logik
- eine zentrale JS-Datei fuer Frontend-Logik
- eine zentrale CSS-Datei fuer Design
- so wenig Templates wie moeglich

Wichtig:
- Zentralisierung darf nie Unordnung bedeuten.
- Innerhalb zentraler Dateien muss die Struktur streng OOP-orientiert, sektioniert und wiederverwendbar sein.

### 2.2 OOP als Pflicht

Jedes neue Projekt soll von Anfang an objektorientiert aufgebaut sein.

Das bedeutet:
- klare Klassen mit klarer Verantwortung
- keine wilden Utility-Teppiche ohne Zustandsgrenzen
- keine verstreute Business-Logik in freien Funktionen, wenn eine Klasse fachlich passender ist
- keine Template-Logik, die Controller- oder Service-Aufgaben uebernimmt
- Frontend und Backend bekommen jeweils ein klares Klassensystem

OOP heisst hier nicht:
- moeglichst viele Dateien
- kuenstlich komplizierte Vererbung

OOP heisst hier:
- Verantwortung kapseln
- Zustand bewusst verwalten
- APIs bewusst gestalten
- Verhalten an einer definierten Stelle halten

### 2.3 Sicherheit ist kein Nachtrag

Sicherheit muss am ersten Tag Teil der Architektur sein.

Niemals wieder spaeter nachziehen:
- CSP
- CSRF
- XSS-Schutz
- sicheres DOM-Rendering
- Cookie-Strategie
- Session-Invalidierung
- Migrationsfaehigkeit

### 2.4 Wiederverwendung vor Schnellschuss

Was mehr als einmal vorkommt, wird frueh als System gebaut:
- Animationen
- Modals
- Fenster
- Tabellen
- Toasts
- API-Client
- State-Store
- Layout-Engine
- Page-Transitions
- Event-Routing

---

## 3. Absolute Projektgesetze fuer neue Projekte

Diese Regeln sollen am Anfang jedes neuen Projekts als Gesetze festgelegt werden.

### 3.1 Architekturgesetze

- Eine zentrale Core-Datei fuer die Hauptlogik.
- Eine zentrale JS-Datei fuer Frontend-Logik.
- Eine zentrale CSS-Datei fuer Design-Tokens und Komponenten.
- Templates sind Struktur, nicht Logik.
- Innerhalb zentraler Dateien wird streng in Sektionen und Klassen gearbeitet.
- Jede Klasse hat genau eine klare Hauptverantwortung.
- Wiederholte Logik wird sofort in gemeinsame Klassen oder Methoden ueberfuehrt.

### 3.2 Sicherheitsgesetze

- Keine Inline-Skripte in Templates.
- Keine `onclick`, `onsubmit`, `onchange`, `oninput` oder andere Inline-Handler.
- Keine untrusted Daten per `innerHTML` rendern.
- Jede schreibende Anfrage braucht serverseitigen CSRF-Schutz.
- CSP wird von Tag 1 an mitgedacht und spaetestens vor dem ersten groesseren Feature aktiviert.
- Alle sicherheitsrelevanten Header werden zentral gesetzt.
- Session-Invalidierung muss geplant sein.
- Schema-Aenderungen muessen additive Migrationen haben.

### 3.3 UI- und Designgesetze

- Alle Farben, Abstaende, Radien und Schatten laufen ueber Design-Tokens.
- Keine harten Einzelwerte im Code, wenn dafuer Tokens existieren koennen.
- Keine neue UI ohne wiederverwendbare Klasse oder Komponente.
- Fenster, Modals, Tabellen, Toasts und Navigation sind Basissysteme, keine Einzelfall-Loesungen.

### 3.4 Bewegungs- und Layoutgesetze

- Alle Animationen laufen ueber eine einzige Animationsklasse.
- Kein verstreutes `style.transition`.
- Kein willkuerliches `setTimeout` als Animationssteuerung.
- Kein Polling fuer Live-Daten.
- Layout ist ein eigenes System, kein zufaelliges Nebenergebnis von CSS.

### 3.5 Qualitaetsgesetze

- Vor Refactoring zuerst Verhalten absichern.
- Vor Fachfeatures zuerst Sicherheitsbasis.
- Vor Produktivgang zuerst Migrationspruefung.
- Bugfixes fliessen in die Architekturregeln zurueck.

---

## 4. Empfohlene Startstruktur fuer ein neues Projekt

Die konkrete Struktur kann je nach Stack leicht variieren.
Der Grundgedanke bleibt gleich.

### 4.1 Backend

Empfohlene Sektionen in der zentralen Core-Datei:

1. Imports und Config
2. Datenbank und Engine
3. Core-Modelle
4. Security und Auth-Utilities
5. Laufzeit-Usertypen oder Systemrollen
6. Dependencies und Guards
7. Services
8. Registries oder Integrationssysteme
9. App-Initialisierung und Middleware
10. Routen
11. Webhook oder Systemintegration
12. Lifespan, Startup, Migration, Seed

### 4.2 Frontend

Empfohlene Basisklassen in der zentralen JS-Datei:

- `App` als Namespace oder Root-Fassade
- `UI` fuer allgemeine UI-Steuerung
- `API` fuer alle Requests
- `Store` fuer lokalen Zustand
- `Util` fuer sichere kleine Helfer
- `Animate` fuer alle Animationen
- `PageAnim` fuer Seitenwechsel
- `Layout` fuer Fenster- und Grid-Logik
- `Admin` oder Fachcontroller je nach Projekt
- `Router` fuer Navigation
- `Window`, `Modal`, `Table`, `Toast` als Webkomponenten

### 4.3 CSS

Die CSS-Datei braucht von Anfang an:

- globale Tokens
- Theme-Variablen
- Typografie-Rollen
- Button-System
- Formular-System
- Fenster-System
- Modal-System
- Tabellen-System
- Toast-System
- Statusfarben
- Icon-System

### 4.4 Templates

Templates enthalten:

- HTML-Struktur
- Slots
- semantische Container
- `data-*`-Attribute fuer Event-Routing

Templates enthalten nicht:

- Inline-Logik
- Inline-Skripte
- Inline-Event-Handler
- unsichere String-Injektionen

---

## 5. Sicherheitsfundament ab Tag 1

## 5.1 CSP von Anfang an mitdenken

Die wichtigste Erkenntnis:
CSP spaeter nachzuruesten ist teuer.

Darum gilt ab Projektstart:
- keine Inline-Skripte
- keine Inline-Event-Handler
- keine dynamischen HTML-Injektionen mit ungeprueften Daten
- JavaScript lebt in der JS-Datei
- Events laufen ueber Event Delegation

Empfohlener Zielzustand:

```http
Content-Security-Policy:
default-src 'self';
script-src 'self';
style-src 'self' 'unsafe-inline';
img-src 'self' data:;
font-src 'self';
connect-src 'self';
object-src 'none';
base-uri 'self';
frame-ancestors 'none';
```

Empfohlene Einfuehrung:

1. Zuerst Architektur CSP-kompatibel bauen
2. Dann `Content-Security-Policy-Report-Only`
3. Alle Verstoesse entfernen
4. Danach echte CSP aktivieren

Wichtig:
- `script-src` soll ohne `unsafe-inline` auskommen.
- `style-src` kann in fruehen Phasen temporaer weicher sein, sollte aber spaeter ebenfalls gehaertet werden.

## 5.2 CSRF ab dem ersten schreibenden Endpoint

`SameSite=Lax` ist hilfreich, aber kein vollstaendiger CSRF-Schutz.

Pflicht fuer neue Projekte:
- Double-Submit-Cookie oder Synchronizer-Token
- Header-Pruefung fuer `POST`, `PUT`, `PATCH`, `DELETE`
- zusaetzlich `Origin` pruefen
- fallback `Referer` pruefen

Empfohlener Standard:

- Auth per HTTP-only Cookie
- getrenntes CSRF-Cookie
- Header `X-CSRF-Token`
- serverseitiger Vergleich Cookie gegen Header

## 5.3 XSS-Regeln

- Untrusted Daten nur per `textContent`, nie blind per `innerHTML`
- Wo HTML wirklich noetig ist: explizites Escaping
- Templates nutzen Escaping immer bewusst
- Daten aus User-Input niemals direkt in JS-Strings interpolieren
- Aktionen laufen ueber IDs und `data-*`, nicht ueber Stringverkettung

## 5.4 Session- und Auth-Regeln

- Tokens haben `exp`
- Tokens haben `iat`
- Passwortwechsel invalidiert alte Tokens
- Optional: `jti` oder `token_version`
- Cookies sind `HttpOnly`, `Secure` in Produktion, `SameSite` bewusst gesetzt
- Rollen und Tenant-Kontext werden serverseitig geprueft

## 5.5 Header-Baseline

Zentrale Security-Header:

- `Content-Security-Policy`
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy` minimal halten
- `frame-ancestors 'none'` oder entsprechende Alternative

## 5.6 Rate Limiting und Replay-Schutz

- Login immer rate-limitieren
- Webhooks immer signieren
- Webhooks immer Replay-Schutz haben
- Multi-Worker-Zustaende nie nur in Memory halten, wenn mehrere Prozesse laufen

## 5.7 Migrationsgesetz

Neue Datenbankspalten oder Tabellen duerfen bestehende Installationen nicht brechen.

Darum:
- additive Migrationen
- Startup-Pruefung
- klare Fehlermeldung wenn Schema nicht passt
- keine stillen Annahmen ueber bestehende Datenbanken

---

## 6. Multi-Tenant- und Rollenprinzipien

Wenn das Projekt Mandanten kennt, gilt:

- jeder Datensatz gehoert eindeutig zu einem Tenant
- jede Query wird tenant-sicher gebaut
- Superadmin oder Systemrolle ist gesondert behandelt
- Tenant-Fremdzugriffe liefern keinen aufschlussreichen Leak
- Verfuegbarkeitspruefungen duerfen keine sensiblen Infos verraten

Wichtig:
- Tenant-Filter ist keine spaete Korrektur
- Tenant-Filter ist Teil jeder Repository-, Service- und Route-Logik

---

## 7. Echtzeit-Prinzip: kein Polling

Die Erfahrung aus realen Projekten ist eindeutig:
- Polling macht Systeme lauter, langsamer und fehleranfaelliger
- ein sauberer SSE-Ansatz ist fuer dieses System die bessere Basis

Darum:
- ein Event-Stream pro Tab
- getypte Events
- Frontend routet Events zu bestehenden Reload- oder Merge-Funktionen
- Multi-Worker-Faehigkeit ueber Redis oder vergleichbaren Broker

Grundsatz:
- keine `setInterval`-Fetch-Loops fuer Live-Daten
- Realtime ist ein eigenes System, nicht verstreute Sonderlogik

---

## 8. Animationen und Bewegungsprinzipien

Animationen muessen von Anfang an zentralisiert sein.

### 8.1 Ein Animationssystem

Alle Animationen laufen ueber eine einzige Klasse, zum Beispiel `Animate`.

Nie verwenden:
- direkte `style.transition`
- manuelle Timing-Kaskaden mit `setTimeout`
- spontane Spezialanimationen ausserhalb des Systems

Erlaubte Ausnahmen nur bewusst:
- dauerhafte Physik-Loops
- Spezialfaelle, die das zentrale System technisch nicht abbilden kann

### 8.2 Ein Seitenanimationssystem

Seitenwechsel sollen ueber eine zentrale Klasse laufen, zum Beispiel `PageAnim`.

Vorteile:
- einheitlicher Login-Entry
- einheitlicher Logout-Exit
- einheitliche Navigation
- keine verteilten CSS-Keyframes

### 8.3 Ein Layoutsystem

Fenster-, Grid- und Bereichslayouts sollen als eigenes System existieren, zum Beispiel `Layout`.

Grundsatz:
- Layout ist nicht zufaellig
- Layout ist berechnet
- Collapse, Expand, Reorder, Resize und Persistenz sind Teil eines gemeinsamen Systems

### 8.4 Layout-Persistenz

Bewaehrtes Prinzip:
- DB = Master
- Browser-Storage = Fallback

Das bedeutet:
- der Nutzer verliert keine Layouts
- die Seite fuehlt sich lokal sofort an
- das System ist trotzdem persistent

---

## 9. Wiederverwendbare UI-Bausteine, die fast jedes Projekt direkt braucht

Diese Bausteine sollen frueh als Basissystem vorhanden sein.

### 9.1 Fenster-Komponente

Beispiel: `app-window`

Nutzen:
- standardisierte Sektionsdarstellung
- klarer Titelbereich
- Aktionsslot
- einheitliche visuelle Sprache

### 9.2 Modal-Komponente

Beispiel: `app-modal`

Nutzen:
- einheitliches Overlay
- standardisierte Groessen
- gemeinsames Oeffnen/Schliessen
- keine Sondermodals pro Feature

### 9.3 Tabellen-Komponente

Beispiel: `app-table`

Nutzen:
- Sortierung
- Selektion
- Smart-Merge
- API-Loading
- SSE-Verknuepfung

### 9.4 Toast-Komponente

Beispiel: `app-toast`

Nutzen:
- globale Rueckmeldung
- standardisierte Fehler- und Erfolgsmeldungen
- keine ad hoc Alerts

### 9.5 Optionale Standard-Bausteine

Je nach Projekt sinnvoll:
- Scroller
- Lazy Loader
- Icon-System
- Router
- Splitter
- Drag-and-Drop-System

---

## 10. Design-Fibel fuer neue Projekte

Das Designsystem muss zu Beginn festgelegt werden, nicht am Ende.

### 10.1 Design-Tokens zuerst

Von Anfang an definieren:
- Farben
- Radius
- Schatten
- Spacing
- Transition-Kurven
- Typografie-Rollen

Niemals:
- harte Farben quer durchs Projekt
- willkuerliche Einzelwerte
- unkoordinierte Komponentenstile

### 10.2 Typografie-Rollen statt Einzelentscheidungen

Empfohlene Rollen:
- Grundschrift
- UI-Schrift
- Input-Schrift
- Alert-Schrift
- Monospace

### 10.3 Komponenten visuell vereinheitlichen

Pflichtsysteme:
- Buttons
- Formulare
- Badges
- Alerts
- Cards
- Tabellen
- Fenster
- Modals
- Toasts

### 10.4 Icon-System zentralisieren

- lokale SVGs
- einheitliche Groessen
- vererbte Farbe
- kein Inline-SVG-Chaos im Template

### 10.5 Theme-System frueh entscheiden

Wenn Dark/Light vorgesehen ist:
- beide Modi von Anfang an in Tokens planen
- kein spaeteres chaotisches Umschichten

---

## 11. API- und Frontend-Grundprinzipien

### 11.1 Ein API-Client

`fetch()` darf nicht ueberall lose im Projekt herumliegen.

Es braucht eine zentrale API-Klasse:
- `get`
- `post`
- `put`
- `patch`
- `delete`
- Fehlernormalisierung
- JSON-Handling
- CSRF-Header

### 11.2 Ein State-Store

Lokaler Zustand gehoert in einen zentralen Store:
- Theme
- Layout
- Collapsed State
- Reihenfolge
- Breiten
- UI-Einstellungen

### 11.3 Event Delegation statt Template-Handler

Jede UI-Aktion soll ueber:
- `data-action`
- Listener auf Container-Ebene
- Controller-Methoden

laufen.

Nicht ueber:
- `onclick`
- `onsubmit`
- String-Konstruktionen im HTML

### 11.4 Sichere Render-Strategie

Bevorzugen:
- `textContent`
- `createElement`
- `append`
- `dataset`
- `setAttribute`

Nur kontrolliert:
- `innerHTML`

---

## 12. Test- und Qualitaetsstrategie

Gruene Tests allein bedeuten nicht automatisch saubere Architektur.
Aber ohne gruene Tests ist jede Refaktorierung riskant.

### 12.1 Vor dem ersten grossen Feature

Absichern:
- Login
- Logout
- Session
- Hauptnavigation
- Kern-CRUD
- Tenant-Isolation
- Rollenrechte
- Echtzeit-Updates
- Webhook oder Integrationspfade

### 12.2 Pflicht-Testarten

- API-Tests
- Sicherheits-Tests
- Smoke-Tests
- Multi-Worker- oder Event-Tests, falls relevant
- Browser-End-to-End fuer Kernflows

### 12.3 Sicherheits-Tests

Immer frueh testen:
- XSS-Pfade
- CSRF-Blockierung
- Rollenmissbrauch
- Tenant-Leaks
- Replay-Schutz
- Session-Invalidierung

### 12.4 Regressionen als Architekturinput

Jeder echte Bug beantwortet zwei Fragen:

1. Wie fixen wir den Fehler?
2. Welche neue Regel verhindert, dass dieser Fehler wiederkommt?

---

## 13. Dokumentationsprinzipien

Dokumentation darf nicht nur rueckblickend gefuellt werden.
Sie ist Teil der Architektur.

### 13.1 Empfehlenswerte Dokumente

- `STARTUP.md` als Fibel
- `CLAUDE.md` als Projektgesetze und Index
- `CHANGELOG.md` als Entwicklungsgedachtnis
- `DESIGN.md` als visuelles Regelwerk
- komponentenspezifische Dokus fuer Standardbausteine

### 13.2 Was in den Changelog gehoert

- nicht nur neue Features
- auch Architekturentscheidungen
- auch Sicherheitsfixes
- auch Regressionen
- auch Erkenntnisse, die kuenftige Projekte besser machen

---

## 14. Bewaehrte Muster, die direkt in neue Projekte uebernommen werden sollten

### 14.1 Zentrale Seitenanimation

Ein dediziertes Seitenanimationssystem statt verteilten CSS-Keyframes.

### 14.2 Einheitliches Layoutsystem

Fenster, Reorder, Resize, Collapse und Persistenz als gemeinsames System.

### 14.3 Universal SSE

Ein Stream, getypte Events, Frontend-Routing.

### 14.4 Wiederverwendbare Webkomponenten

- Window
- Modal
- Table
- Toast

### 14.5 API-Client statt losem Fetch

Alle Requests an einer Stelle.

### 14.6 Store als lokale Wahrheit

Lokale UI-Zustaende nicht ueberall verstreuen.

### 14.7 Debounced Persistenz

Sofort lokal reagieren, spaeter sicher synchronisieren.

### 14.8 Security frueh statt spaet

Die teuersten Nacharbeiten entstehen bei:
- CSP
- CSRF
- Schema-Migrationen
- unsicherem DOM-Rendering

---

## 15. Dinge, die man in neuen Projekten bewusst vermeiden muss

- Inline-JavaScript
- spontane `fetch()`-Inseln
- Polling fuer Echtzeit
- verstreute Animationen
- ad hoc Modals
- Tabellen pro Feature neu bauen
- unescaped `innerHTML`
- Sicherheitsfeatures erst kurz vor Produktion einbauen
- Datenbankaenderungen ohne Migrationspfad
- Duplicate Logic mit kleinen Variationen
- versteckte globale Zustandsfelder ohne klares Eigentum

---

## 16. Start-Checkliste fuer jedes neue Projekt

## 16.1 Vor der ersten Zeile Code

- Projektziel klar?
- Rollen klar?
- Datenmodell grob klar?
- Sicherheitsniveau klar?
- Echtzeitbedarf klar?
- Layoutbedarf klar?
- UI-Bausteine klar?
- Dokumentationsdateien angelegt?

## 16.2 Vor dem ersten Feature

- zentrale Config steht
- DB-Grundlage steht
- Auth-Grundlage steht
- CSP- und CSRF-Strategie steht
- API-Client steht
- Store steht
- Design-Tokens stehen
- Window/Modal/Table/Toast stehen
- SSE-Strategie steht
- Migrationen sind eingeplant

## 16.3 Vor produktionsnahen Tests

- keine Inline-Handler mehr
- keine Inline-Skripte mehr
- mutierende Requests CSRF-geschuetzt
- CSP mindestens im Report-Only aktiv
- Security-Header gesetzt
- Migrationspfad getestet
- Kernflows browserseitig getestet

## 16.4 Vor Produktion

- CSP aktiv
- CSRF aktiv
- Cookies korrekt
- Logging und Audit bedacht
- Rate-Limiting aktiv
- Webhooks signiert
- Multi-Worker-Verhalten geprueft
- bestehende Datenbankmigrationen erfolgreich getestet

---

## 17. Minimaler Umsetzungsplan fuer einen sauberen Projektstart

### Phase 1: Fundament

- Projektgesetze festlegen
- Startdokumente anlegen
- Design-Tokens definieren
- Config, DB, Auth, API-Client, Store, Security-Header vorbereiten

### Phase 2: Sicherheitsbasis

- CSP-kompatible Struktur bauen
- CSRF-System einbauen
- sichere Render-Regeln umsetzen
- Rollen- und Tenant-Prinzip verankern

### Phase 3: UI-Grundsysteme

- Window
- Modal
- Table
- Toast
- Animate
- PageAnim
- Layout

### Phase 4: Realtime und Persistenz

- SSE
- Event-Routing
- lokale Persistenz
- DB-basierte Persistenz

### Phase 5: Fachfeatures

- erst jetzt eigentliche Produktlogik

### Phase 6: Harter Qualitaetscheck

- Sicherheits-Tests
- Browser-Smoke
- Mehrprozess-Szenarien
- Migrationspruefung

---

## 18. Schlussprinzip

Ein gutes Projekt startet nicht mit dem ersten Feature.
Ein gutes Projekt startet mit den richtigen Gesetzen.

Die wichtigste Lehre ist:
- Architektur muss frueh bewusst sein
- Sicherheit muss von Anfang an drin sein
- Wiederverwendung muss Absicht sein
- Bugfixes muessen in neue Regeln uebersetzt werden

Wer so startet, spart spaeter:
- Umbauten
- Regressionen
- Sicherheitsnacharbeiten
- doppelte Logik
- unnoetige Komplexitaet

Kurzform:

- erst Gesetze
- dann Fundament
- dann Systeme
- dann Features
- dann Haertung

Und nie umgekehrt.
