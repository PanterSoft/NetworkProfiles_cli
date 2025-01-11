#!/bin/bash

# Define variables
APP_NAME="NetworkProfiles"
BUILD_DIR=".build/release"
APP_BUNDLE="$APP_NAME.app"
DMG_NAME="$APP_NAME.dmg"
DMG_DIR="dmg"

# Clean up previous builds
rm -rf "$BUILD_DIR"
rm -rf "$APP_BUNDLE"
rm -rf "$DMG_DIR"
rm -f "$DMG_NAME"

# Build the application
swift build -c release

# Create the app bundle structure
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"
mkdir -p "$APP_BUNDLE/Contents/Resources/Assets.car"

# Copy the built executable to the app bundle
cp "$BUILD_DIR/NetworkProfiles_cli" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# Create the Info.plist file
cat <<EOF > "$APP_BUNDLE/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.$APP_NAME</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

# Create the DMG directory structure
mkdir -p "$DMG_DIR"
cp -R "$APP_BUNDLE" "$DMG_DIR"

# Create the DMG file
hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_DIR" -ov -format UDZO "$DMG_NAME"

# Clean up
rm -rf "$DMG_DIR"
rm -rf "$APP_BUNDLE"

echo "DMG file created: $DMG_NAME"