import Foundation
import Dispatch

struct NetworkProfile: Codable {
    let profileName: String
    let ipv4Address: String?
    let router: String?
    let subnetMask: String?
    let dnsServers: [String]
    let interfaceName: String
    let mode: String
}

struct Config: Codable {
    var profiles: [NetworkProfile]
}

func loadConfig(from filePath: String) -> Config? {
    let url = URL(fileURLWithPath: filePath)
    guard let data = try? Data(contentsOf: url) else {
        print("Failed to read data from \(filePath)")
        return nil
    }
    let decoder = JSONDecoder()
    return try? decoder.decode(Config.self, from: data)
}

func saveConfig(_ config: Config, to filePath: String) {
    let url = URL(fileURLWithPath: filePath)
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    guard let data = try? encoder.encode(config) else {
        print("Failed to encode config data.")
        return
    }
    do {
        try data.write(to: url)
    } catch {
        print("Failed to write config data to \(filePath): \(error)")
    }
}

func applyNetworkSettings(profile: NetworkProfile) {
    var commands: [String] = []

    if profile.mode == "manual" {
        let dnsServers = profile.dnsServers.joined(separator: " ")
        commands.append("networksetup -setmanual \(profile.interfaceName) \(profile.ipv4Address!) \(profile.subnetMask!) \(profile.router!)")
        commands.append("networksetup -setdnsservers \(profile.interfaceName) \(dnsServers)")
    } else if profile.mode == "dhcp" {
        commands.append("networksetup -setdhcp \(profile.interfaceName)")
        if !profile.dnsServers.isEmpty {
            let dnsServers = profile.dnsServers.joined(separator: " ")
            commands.append("networksetup -setdnsservers \(profile.interfaceName) \(dnsServers)")
        }
    }

    for command in commands {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        task.launch()
        task.waitUntilExit()
    }
}

func selectProfile(profiles: [NetworkProfile]) -> NetworkProfile? {
    print("Available profiles:")
    for (index, profile) in profiles.enumerated() {
        print("\(index + 1). \(profile.profileName)")
    }
    print("Select a profile number:")
    guard let input = readLine(), let index = Int(input), index > 0, index <= profiles.count else {
        print("Invalid selection.")
        return nil
    }
    return profiles[index - 1]
}

func getAvailableInterfaces() -> [String] {
    let task = Process()
    task.launchPath = "/usr/sbin/networksetup"
    task.arguments = ["-listallnetworkservices"]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard let output = String(data: data, encoding: .utf8) else {
        print("Failed to read output from networksetup command.")
        return []
    }

    print("Command output:\n\(output)") // Debugging-Ausgabe

    let lines = output.split(separator: "\n")
    var interfaces: [String] = []

    for line in lines {
        if !line.contains("*") && !line.isEmpty {
            interfaces.append(String(line))
        }
    }

    return interfaces
}

func createProfile() -> NetworkProfile? {
    print("Enter profile name:")
    guard let profileName = readLine() else { return nil }

    let interfaces = getAvailableInterfaces()
    guard !interfaces.isEmpty else {
        print("No available network interfaces found.")
        return nil
    }

    print("Available interfaces:")
    for (index, interface) in interfaces.enumerated() {
        print("\(index + 1). \(interface)")
    }
    print("Select an interface number:")
    guard let input = readLine(), let index = Int(input), index > 0, index <= interfaces.count else {
        print("Invalid selection.")
        return nil
    }
    let interfaceName = interfaces[index - 1]

    print("Enter mode (dhcp/manual):")
    guard let mode = readLine(), mode == "dhcp" || mode == "manual" else { return nil }

    var ipv4Address: String? = nil
    var router: String? = nil
    var subnetMask: String? = nil
    var dnsServers: [String] = []

    if mode == "manual" {
        print("Enter IPv4 address:")
        ipv4Address = readLine()
        print("Enter router address:")
        router = readLine()
        print("Enter subnet mask:")
        subnetMask = readLine()
    }

    print("Enter DNS servers (comma separated):")
    if let dnsInput = readLine() {
        dnsServers = dnsInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }

    return NetworkProfile(profileName: profileName, ipv4Address: ipv4Address, router: router, subnetMask: subnetMask, dnsServers: dnsServers, interfaceName: interfaceName, mode: mode)
}

func deleteProfile(profiles: inout [NetworkProfile], profileName: String) -> Bool {
    if let index = profiles.firstIndex(where: { $0.profileName == profileName }) {
        profiles.remove(at: index)
        return true
    }
    return false
}

signal(SIGINT) { _ in
    print("\nOperation cancelled by user.")
    exit(0)
}

guard CommandLine.arguments.count > 1 else {
    print("Usage: NetworkProfiles_cli <config-file-path> [create|delete]")
    exit(1)
}

let configFilePath = CommandLine.arguments[1]
var config = loadConfig(from: configFilePath) ?? Config(profiles: [])

if CommandLine.arguments.count > 2 {
    let action = CommandLine.arguments[2]
    if action == "create" {
        if let newProfile = createProfile() {
            config.profiles.append(newProfile)
            saveConfig(config, to: configFilePath)
            print("Profile created successfully.")
        } else {
            print("Failed to create profile.")
        }
    } else if action == "delete" {
        print("Enter the profile name to delete:")
        if let profileName = readLine(), deleteProfile(profiles: &config.profiles, profileName: profileName) {
            saveConfig(config, to: configFilePath)
            print("Profile deleted successfully.")
        } else {
            print("Failed to delete profile.")
        }
    }
} else {
    if let selectedProfile = selectProfile(profiles: config.profiles) {
        applyNetworkSettings(profile: selectedProfile)
    } else {
        print("No profile selected.")
    }
}
