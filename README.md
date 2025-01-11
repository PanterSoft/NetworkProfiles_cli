# NetworkProfiles CLI

## Voraussetzungen

- macOS 10.15 oder neuer
- Xcode installiert

## Anwendung ausführen

### Command-Line Interface (CLI)

Um die CLI-Version der Anwendung auszuführen, verwenden Sie den folgenden Befehl:

```sh
swift run NetworkProfiles_cli <config-file-path> [create|delete|gui]
```

- `<config-file-path>`: Pfad zur Konfigurationsdatei
- `create`: Erstellt ein neues Netzwerkprofil
- `delete`: Löscht ein bestehendes Netzwerkprofil (noch nicht implementiert)
- `gui`: Startet die GUI-Version der Anwendung (nur auf macOS 11.0 oder neuer verfügbar)

### Graphical User Interface (GUI)

Um die GUI-Version der Anwendung auszuführen, verwenden Sie den folgenden Befehl:

```sh
swift run NetworkProfiles_cli gui
```

Hinweis: Die GUI-Version ist nur auf macOS 11.0 oder neuer verfügbar.