import Foundation

struct NetworkProfile: Codable {
    let profileName: String
    let ipv4Address: String?
    let router: String?
    let subnetMask: String?
    let dnsServers: [String]?
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

func createEmptyConfigFile(at filePath: String) {
    let config = Config(profiles: [])
    saveConfig(config, to: filePath)
}

func applyNetworkSettings(profile: NetworkProfile) {
    var commands: [String] = []

    if profile.mode == "manual" {
        let dnsServers = profile.dnsServers?.joined(separator: " ") ?? ""
        commands.append("networksetup -setmanual \(profile.interfaceName) \(profile.ipv4Address!) \(profile.subnetMask!) \(profile.router!)")
        if !dnsServers.isEmpty {
            commands.append("networksetup -setdnsservers \(profile.interfaceName) \(dnsServers)")
        } else {
            commands.append("networksetup -setdnsservers \(profile.interfaceName) empty")
        }
    } else if profile.mode == "dhcp" {
        commands.append("networksetup -setdhcp \(profile.interfaceName)")
        if let dnsServers = profile.dnsServers, !dnsServers.isEmpty {
            let dnsServersString = dnsServers.joined(separator: " ")
            commands.append("networksetup -setdnsservers \(profile.interfaceName) \(dnsServersString)")
        } else {
            commands.append("networksetup -setdnsservers \(profile.interfaceName) empty")
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

func listAllNetworkInterfaces() -> [String] {
    let task = Process()
    task.launchPath = "/usr/sbin/networksetup"
    task.arguments = ["-listallhardwareports"]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    task.waitUntilExit()

    guard let output = String(data: data, encoding: .utf8) else {
        print("Failed to read network interfaces.")
        return []
    }

    var interfaces: [String] = []
    let lines = output.split(separator: "\n")
    for line in lines {
        if line.contains("Device:") {
            let components = line.split(separator: ":")
            if components.count > 1 {
                interfaces.append(components[1].trimmingCharacters(in: .whitespaces))
            }
        }
    }

    return interfaces
}

func listAllNetworkServices() -> [String] {
    let task = Process()
    task.launchPath = "/usr/sbin/networksetup"
    task.arguments = ["-listallnetworkservices"]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    task.waitUntilExit()

    guard let output = String(data: data, encoding: .utf8) else {
        print("Failed to read network services.")
        return []
    }

    var services: [String] = []
    let lines = output.split(separator: "\n")
    for line in lines {
        if !line.contains("*") && !line.contains("An asterisk") {
            services.append(line.trimmingCharacters(in: .whitespaces))
        }
    }

    return services
}

func selectNetworkService() -> String? {
    let services = listAllNetworkServices()
    guard !services.isEmpty else {
        print("No network services available.")
        return nil
    }

    print("Available network services:")
    for (index, service) in services.enumerated() {
        print("\(index + 1). \(service)")
    }

    print("Select a network service by number:")
    guard let input = readLine(), let index = Int(input), index > 0, index <= services.count else {
        print("Invalid selection.")
        return nil
    }

    return services[index - 1]
}

func createProfile() -> NetworkProfile? {
    print("Profile name:")
    guard let profileName = readLine(), !profileName.isEmpty else { return nil }

    print("Mode (manual/dhcp):")
    guard let mode = readLine(), !mode.isEmpty else { return nil }

    var ipv4Address: String? = nil
    var router: String? = nil
    var subnetMask: String? = nil
    var dnsServers: [String]? = nil

    if mode == "manual" {
        print("IPv4 address:")
        ipv4Address = readLine()

        print("Router:")
        router = readLine()

        print("Subnet mask:")
        subnetMask = readLine()

        print("DNS servers (comma separated):")
        if let dnsInput = readLine(), !dnsInput.isEmpty {
            dnsServers = dnsInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }
    } else if (mode == "dhcp") {
        print("DNS servers (comma separated):")
        if let dnsInput = readLine(), !dnsInput.isEmpty {
            dnsServers = dnsInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }
    } else {
        print("Invalid mode.")
        return nil
    }

    guard let interfaceName = selectNetworkService() else {
        return nil
    }

    return NetworkProfile(
        profileName: profileName,
        ipv4Address: ipv4Address,
        router: router,
        subnetMask: subnetMask,
        dnsServers: dnsServers,
        interfaceName: interfaceName,
        mode: mode
    )
}

func selectProfile(config: Config) -> NetworkProfile? {
    guard !config.profiles.isEmpty else {
        print("No profiles available.")
        return nil
    }

    print("Available profiles:")
    for (index, profile) in config.profiles.enumerated() {
        print("\(index + 1). \(profile.profileName)")
    }

    print("Select a profile by number:")
    guard let input = readLine(), let index = Int(input), index > 0, index <= config.profiles.count else {
        print("Invalid selection.")
        return nil
    }

    return config.profiles[index - 1]
}
