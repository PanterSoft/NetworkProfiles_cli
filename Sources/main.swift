import Foundation

if #available(macOS 10.15, *) {
    print("Launching CLI application")
    NetworkProfilesCLI.main()
} else {
    print("This program requires macOS 10.15 or newer.")
    exit(1)
}
