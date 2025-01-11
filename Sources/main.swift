import Darwin
import Foundation

@available(macOS 10.15, *)
struct NetworkProfilesCLI {
    static func main() {
        print("NetworkProfilesCLI started") // Debugging-Ausgabe
        if CommandLine.arguments.count > 1 {
            let action = CommandLine.arguments[1]
            if action == "gui" {
                // If the app is available on macOS 11.0 or later, run it
                if #available(macOS 11.0, *) {
                    Task {
                        await NetworkProfilesApp.main()
                    }
                } else {
                    print("The GUI is only available on macOS 11.0 or newer.")
                    exit(1)
                }
            } else {
                runCommandLineApp()
            }
        } else {
            print("Usage: NetworkProfiles_cli <config-file-path> [create|delete|gui|list-interfaces]")
            exit(1)
        }
    }
}

// Function to handle the CLI version of the app
func runCommandLineApp() {
    print("Running command-line app...")
    guard CommandLine.arguments.count > 1 else {
        print("Invalid arguments. Provide a valid config file path.")
        exit(1)
    }
    let configPath = CommandLine.arguments[1]

    print("Config path: \(configPath)")

    if !FileManager.default.fileExists(atPath: configPath) {
        print("Configuration file does not exist at path: \(configPath). Creating a new one.")
        createEmptyConfigFile(at: configPath)
    }

    guard let config = loadConfig(from: configPath) else {
        print("Failed to load configuration file. Creating a new one.")
        createEmptyConfigFile(at: configPath)
        guard let newConfig = loadConfig(from: configPath) else {
            print("Failed to create a new configuration file.")
            exit(1)
        }
        selectAndApplyProfile(config: newConfig, configPath: configPath)
        return
    }

    if CommandLine.arguments.count == 2 {
        selectAndApplyProfile(config: config, configPath: configPath)
    } else {
        let action = CommandLine.arguments[2]
        print("Action: \(action)")

        if action == "list-interfaces" {
            let interfaces = listAllNetworkInterfaces()
            print("Available network interfaces:")
            for interface in interfaces {
                print(interface)
            }
            exit(0)
        }

        runAction(action, with: config, at: configPath)
    }
}

func selectAndApplyProfile(config: Config, configPath: String) {
    if let profile = selectProfile(config: config) {
        applyNetworkSettings(profile: profile)
        print("Profile \(profile.profileName) applied successfully.")
    } else {
        print("Profile selection canceled.")
    }
}

func runAction(_ action: String, with config: Config, at configPath: String) {
    switch action {
    case "create":
        print("Creating profile...")
        if let newProfile = createProfile() {
            var updatedConfig = config
            updatedConfig.profiles.append(newProfile)
            saveConfig(updatedConfig, to: configPath)
            print("Profile created and saved successfully.")
        } else {
            print("Profile creation canceled.")
        }
    case "delete":
        print("Feature not implemented yet.")
    default:
        print("Unknown action: \(action)")
        exit(1)
    }
}

if #available(macOS 10.15, *) {
    NetworkProfilesCLI.main()
} else {
    print("This program requires macOS 10.15 or newer.")
    exit(1)
}
