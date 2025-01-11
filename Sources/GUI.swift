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
    var configWindowController: ConfigWindowController?

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
        menu.addItem(NSMenuItem(title: "Configure", action: #selector(showConfigWindow), keyEquivalent: "c"))
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

    @objc func showConfigWindow() {
        if configWindowController == nil {
            configWindowController = ConfigWindowController()
        }
        configWindowController?.showWindow(nil)
        configWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

class ConfigWindowController: NSWindowController {
    override init(window: NSWindow?) {
        super.init(window: window)
        // Initialisieren Sie das Fenster hier
        let window = NSWindow(contentRect: NSMakeRect(0, 0, 480, 270),
                              styleMask: [.titled, .closable, .resizable],
                              backing: .buffered, defer: false)
        window.title = "Configuration"
        self.window = window
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        if let window = self.window {
            let contentViewController = NSViewController()
            let contentView = NSView(frame: window.contentView!.bounds)
            contentViewController.view = contentView
            window.contentViewController = contentViewController

            let label = NSTextField(labelWithString: "Configuration Settings")
            label.frame = NSRect(x: 20, y: window.contentView!.bounds.height - 40, width: 200, height: 20)
            contentView.addSubview(label)
        }
        self.window?.makeKeyAndOrderFront(sender)
    }
}
