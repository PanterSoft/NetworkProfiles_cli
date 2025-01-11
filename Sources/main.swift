import Darwin
import Foundation

@available(macOS 10.15, *)
struct NetworkProfilesCLI {
    static func main() {
        if CommandLine.arguments.count > 1 {
            let configPath = CommandLine.arguments[1]
            if CommandLine.arguments.count > 2 {
                let action = CommandLine.arguments[2]
                if action == "help" {
                    showUsage()
                } else {
                    runCommandLineApp(configPath: configPath, action: action)
                }
            } else {
                selectAndActivateProfile(configPath: configPath)
            }
        } else {
            showUsage()
            exit(1)
        }
    }
}

func selectAndActivateProfile(configPath: String) {
    if !FileManager.default.fileExists(atPath: configPath) {
        print("Configuration file does not exist at path: \(configPath).")
        exit(1)
    }

    guard let config = loadConfig(from: configPath) else {
        print("Failed to load configuration file.")
        exit(1)
    }

    selectAndApplyProfile(config: config, configPath: configPath)
}

// Function to handle the CLI version of the app
func runCommandLineApp(configPath: String, action: String) {
    print("Running command-line app...")
    print("Config path: \(configPath)")
    print("Action: \(action)")

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

    if action == "create" || action == "delete" || action == "help" {
        runAction(action, with: config, at: configPath)
    } else {
        print("Unknown action: \(action)")
        showUsage()
        exit(1)
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
    case "help":
        showUsage()
    default:
        print("Unknown action: \(action)")
        showUsage()
        exit(1)
    }
}

func showUsage() {
    print("""
    Usage: NetworkProfiles_cli <config-file-path> [create|delete|help]
    - create: Create a new network profile
    - delete: Delete an existing network profile (not implemented yet)
    - help: Show this usage information
    """)
}

if #available(macOS 10.15, *) {
    NetworkProfilesCLI.main()
} else {
    print("This program requires macOS 10.15 or newer.")
    exit(1)
}
