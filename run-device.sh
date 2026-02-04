#!/bin/bash

# run-device.sh - Build and install on connected real device
# Usage: ./run-device.sh [device-name]
# Example: ./run-device.sh "iPhone Beng"

set -e

SCHEME="Tester One"
PROJECT="Tester One.xcodeproj"
BUNDLE_ID="co.id.LangitMerah.Tester-One"
TARGET_NAME="${1:-}"

echo "📱 Checking for connected devices..."

# Get list of connected devices
ALL_DEVICES=$(xcrun xctrace list devices 2>/dev/null | grep -E "iPhone|iPad" | grep -v "Simulator" || true)

if [ -z "$ALL_DEVICES" ]; then
    echo "❌ No physical device found!"
    echo ""
    echo "Please:"
    echo "  1. Connect your iPhone/iPad via USB"
    echo "  2. Trust this computer on your device"
    echo "  3. Make sure the device is unlocked"
    exit 1
fi

echo "Found devices:"
echo "$ALL_DEVICES"
echo ""

# If target name provided, find matching device
if [ -n "$TARGET_NAME" ]; then
    echo "🔍 Looking for device: $TARGET_NAME"
    DEVICE_LINE=$(echo "$ALL_DEVICES" | grep -i "$TARGET_NAME" | head -1)
    
    if [ -z "$DEVICE_LINE" ]; then
        echo "❌ Device '$TARGET_NAME' not found!"
        echo "Available devices:"
        echo "$ALL_DEVICES"
        exit 1
    fi
    
    echo "✅ Found matching device: $DEVICE_LINE"
else
    # Use first available device
    DEVICE_LINE=$(echo "$ALL_DEVICES" | head -1)
    echo "Using first available device: $DEVICE_LINE"
fi

# Extract device ID (UUID in parentheses)
DEVICE_ID=$(echo "$DEVICE_LINE" | grep -oE '\([A-Fa-f0-9\-]+\)' | tr -d '()' | head -1)

if [ -z "$DEVICE_ID" ]; then
    echo "❌ Could not extract device ID from: $DEVICE_LINE"
    exit 1
fi

echo "Device ID: $DEVICE_ID"
echo ""

echo "🔨 Building for device..."

# Build for device
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -sdk iphoneos \
  -destination "platform=iOS,id=$DEVICE_ID" \
  build

echo "✅ Build successful!"
echo ""

# Find the built app
BUILD_PATH="$(xcodebuild -project "$PROJECT" -scheme "$SCHEME" -sdk iphoneos -configuration Debug -showBuildSettings 2>/dev/null | grep -E '^\s*CONFIGURATION_BUILD_DIR' | sed 's/.*= //' | head -1 | xargs)"
APP_PATH="$BUILD_PATH/Tester One.app"

if [ ! -d "$APP_PATH" ]; then
    echo "⚠️ Could not find app at: $APP_PATH"
    echo "Trying alternative path..."
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Tester One.app" -type d 2>/dev/null | head -1)
fi

if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo "❌ Could not find built app"
    echo "Please install manually through Xcode"
    exit 1
fi

echo "📦 Found app at: $APP_PATH"
echo ""
echo "🚀 Installing on device..."

# Try to install using devicectl (Xcode 15+) or ios-deploy
echo "Attempting to install..."

# Method 1: Using devicectl (Xcode 15+)
if xcrun devicectl device install app --device "$DEVICE_ID" "$APP_PATH" 2>/dev/null; then
    echo "✅ Installed successfully!"
    echo ""
    echo "🚀 Launching app..."
    
    # Wait a moment for the app to be registered by the system
    sleep 1
    
    # Try to launch the app, capture error for debugging
    LAUNCH_OUTPUT=$(xcrun devicectl device launch app --device "$DEVICE_ID" "$BUNDLE_ID" 2>&1) || {
        echo "⚠️ Launch command failed"
        echo ""
        echo "Debug info:"
        echo "$LAUNCH_OUTPUT" | head -5
        echo ""
        echo "Common causes:"
        echo "   • Device is locked - unlock your iPhone/iPad"
        echo "   • iOS 17+ security restriction - tap the app icon manually"
        echo "   • App needs to be trusted in Settings → VPN & Device Management"
        echo ""
        echo "Please tap the app icon on your device to launch"
    }
    
    if [ -n "$LAUNCH_OUTPUT" ]; then
        echo "$LAUNCH_OUTPUT" | grep -E "(success|launched)" || true
    fi
    
# Method 2: Using ios-deploy if available (better for debugging)
elif command -v ios-deploy &> /dev/null; then
    echo "Using ios-deploy..."
    ios-deploy --id "$DEVICE_ID" --bundle "$APP_PATH" --debug
else
    echo "⚠️ Auto-install methods failed."
    echo ""
    echo "Please install manually:"
    echo "   1. Open Xcode"
    echo "   2. Select your device ($DEVICE_LINE) as target"
    echo "   3. Press Cmd+R"
    echo ""
    echo "Or install ios-deploy for better device support:"
    echo "   brew install ios-deploy"
fi

echo ""
echo "✨ Done!"
