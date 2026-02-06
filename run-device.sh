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

# Install app on selected device
if ! xcrun devicectl device install app --device "$DEVICE_ID" "$APP_PATH"; then
    echo "❌ Failed to install app on device $DEVICE_ID"
    exit 1
fi

echo "🚀 Launching app..."

# Launch app using selected device ID
if ! xcrun devicectl device process launch --device "$DEVICE_ID" "$BUNDLE_ID"; then
    echo "❌ Failed to launch app on device $DEVICE_ID"
    exit 1
fi

echo "✨ Done! App launched on real device."
