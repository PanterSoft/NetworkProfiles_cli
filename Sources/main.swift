import Foundation

if #available(macOS 10.15, *) {
    if CommandLine.arguments.contains("menu") {
        let configPath = CommandLine.arguments[1]
        print("Launching menu bar application with config path: \(configPath)")
        createMenuBarApp(configPath: configPath)
    } else {
        print("Launching CLI application")
        NetworkProfilesCLI.main()
    }
} else {
    print("This program requires macOS 10.15 or newer.")
    exit(1)
}
