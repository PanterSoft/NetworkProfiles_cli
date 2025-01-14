# NetworkProfiles CLI

## Voraussetzungen

- macOS 10.15 oder neuer
- Xcode installiert

## Anwendung ausführen

### Command-Line Interface (CLI)

Um die CLI-Version der Anwendung auszuführen, verwenden Sie den folgenden Befehl:

```sh
swift run NetworkProfiles_cli <config-file-path> [create|delete|help]
```

- `<config-file-path>`: Pfad zur Konfigurationsdatei
- `create`: Erstellt ein neues Netzwerkprofil
- `delete`: Löscht ein bestehendes Netzwerkprofil (noch nicht implementiert)
- `help`: Zeigt diese Hilfeinformationen an

Wenn keine Aktion (`create`, `delete`, `help`) angegeben wird, können Sie ein vorhandenes Profil aus der Konfigurationsdatei auswählen und aktivieren.