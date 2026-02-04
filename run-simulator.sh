#!/bin/bash

# run-simulator.sh - Build and run Tester One on iOS Simulator

set -e

SCHEME="Tester One"
PROJECT="Tester One.xcodeproj"
# Try newer simulators first, fall back to older ones
DESTINATION=""
for SIMULATOR in "iPhone 16 Pro" "iPhone 15 Pro" "iPhone 14 Pro"; do
    if xcrun simctl list devices available | grep -q "$SIMULATOR"; then
        DESTINATION="platform=iOS Simulator,name=$SIMULATOR,OS=latest"
        echo "📱 Found simulator: $SIMULATOR"
        break
    fi
done

if [ -z "$DESTINATION" ]; then
    echo "⚠️ No preferred simulator found, using default"
    DESTINATION="platform=iOS Simulator,name=iPhone 16 Pro,OS=latest"
fi

echo "🔨 Building $SCHEME for simulator..."

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination "$DESTINATION" \
  clean build

echo "✅ Build successful!"

# Extract simulator name from destination
SIMULATOR_NAME=$(echo "$DESTINATION" | sed 's/.*name=\([^,]*\),.*/\1/')

# Boot simulator if not running
if ! pgrep -x "Simulator" > /dev/null; then
    echo "📱 Launching Simulator..."
    open -a Simulator
    sleep 3
fi

echo "🚀 Installing and launching app..."
xcrun simctl boot "$SIMULATOR_NAME" 2>/dev/null || true

# Get the build path
BUILD_PATH="$(xcodebuild -project "$PROJECT" -scheme "$SCHEME" -sdk iphonesimulator -configuration Debug -showBuildSettings | grep -E '^\s*CONFIGURATION_BUILD_DIR' | sed 's/.*= //')"
APP_PATH="$BUILD_PATH/Tester One.app"

# Install and launch
if [ -d "$APP_PATH" ]; then
    xcrun simctl install booted "$APP_PATH" 2>/dev/null || echo "⚠️ Install may have failed, check manually"
    xcrun simctl launch booted "co.id.LangitMerah.Tester-One" 2>/dev/null || echo "⚠️ Launch may have failed, check manually"
else
    echo "⚠️ App not found at expected path: $APP_PATH"
    echo "   Install and launch manually in Simulator"
fi

echo "✨ Done! Check the simulator."
