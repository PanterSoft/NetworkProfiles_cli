import SwiftUI

@available(macOS 11.0, *)
struct NetworkProfilesApp: App {
    @StateObject private var viewModel = NetworkProfilesViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}

@available(macOS 10.15, *)
class NetworkProfilesViewModel: ObservableObject {
    @Published var profiles: [NetworkProfile] = []
    @Published var selectedProfile: NetworkProfile?

    init() {
        loadProfiles()
    }

    func loadProfiles() {
        let configFilePath = CommandLine.arguments[1]
        if let config = loadConfig(from: configFilePath) {
            profiles = config.profiles
        }
    }

    func applySelectedProfile() {
        guard let profile = selectedProfile else { return }
        applyNetworkSettings(profile: profile)
    }
}

@available(macOS 10.15, *)
struct ContentView: View {
    @EnvironmentObject var viewModel: NetworkProfilesViewModel

    var body: some View {
        VStack {
            List(viewModel.profiles, id: \.profileName) { profile in
                Text(profile.profileName)
                    .onTapGesture {
                        viewModel.selectedProfile = profile
                    }
            }
            Button("Apply Selected Profile") {
                viewModel.applySelectedProfile()
            }
            .disabled(viewModel.selectedProfile == nil)
        }
        .padding()
    }
}
