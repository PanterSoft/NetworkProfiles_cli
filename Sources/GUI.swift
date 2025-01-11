import Cocoa

@MainActor
@available(macOS 10.15, *)
func createMenuBarApp(configPath: String) {
    print("Starting menu bar application...")
    let app = NSApplication.shared
    let delegate = AppDelegate(configPath: configPath)
    app.delegate = delegate
    app.setActivationPolicy(.accessory) // Zeigt die Anwendung nur in der Menüleiste an
    app.activate(ignoringOtherApps: true) // Bringt die Anwendung in den Vordergrund
    app.run()
}

@MainActor
@available(macOS 10.15, *)
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var configPath: String

    init(configPath: String) {
        self.configPath = configPath
        super.init()
        print("AppDelegate initialized with config path: \(configPath)")
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Application did finish launching")
        setupStatusItem()
    }

    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = statusItem.button {
            if #available(macOS 11.0, *) {
                button.image = NSImage(systemSymbolName: "network", accessibilityDescription: "Network Profiles")
                print("Setting up menu bar item with icon: Network Profiles")
            } else {
                button.title = "Network Profiles"
                print("Setting up menu bar item with title: Network Profiles")
            }
        } else {
            print("Failed to create menu bar item")
        }
        constructMenu()
    }

    func constructMenu() {
        print("Constructing menu...")
        let menu = NSMenu()
        if let config = loadConfig(from: configPath) {
            let profileNames = getAllProfileNames(config: config)
            for profileName in profileNames {
                print("Adding profile to menu: \(profileName)")
                menu.addItem(NSMenuItem(title: profileName, action: #selector(applyProfile(_:)), keyEquivalent: ""))
            }
        } else {
            print("Failed to load config from path: \(configPath)")
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Configure", action: nil, keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        print("Menu constructed successfully")
    }

    @objc func applyProfile(_ sender: NSMenuItem) {
        print("Applying profile: \(sender.title)")
        if let config = loadConfig(from: configPath) {
            applyProfileByName(config: config, profileName: sender.title)
        } else {
            print("Failed to load config from path: \(configPath)")
        }
    }
}
