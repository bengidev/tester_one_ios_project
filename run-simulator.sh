#!/bin/bash

# run-simulator.sh - Build and run Tester One on iOS Simulator (resilient device selection)

set -e

SCHEME="Tester One"
PROJECT="Tester One.xcodeproj"
BUNDLE_ID="co.id.LangitMerah.Tester-One"

pick_simulator_id() {
  local available
  available=$(xcrun simctl list devices available)

  for name in "iPhone 17 Pro" "iPhone 17" "iPhone 16 Plus Fresh" "iPhone 16e" "iPhone Air"; do
    local line
    line=$(echo "$available" | grep -m1 "$name" || true)
    if [ -n "$line" ]; then
      echo "$line" | sed -n 's/.*(\([A-F0-9-]\{36\}\)).*/\1/p'
      return 0
    fi
  done

  local any_iphone
  any_iphone=$(echo "$available" | grep -m1 "iPhone" || true)
  if [ -n "$any_iphone" ]; then
    echo "$any_iphone" | sed -n 's/.*(\([A-F0-9-]\{36\}\)).*/\1/p'
    return 0
  fi

  local any_device
  any_device=$(echo "$available" | grep -m1 -E "iPad|iPhone" || true)
  if [ -n "$any_device" ]; then
    echo "$any_device" | sed -n 's/.*(\([A-F0-9-]\{36\}\)).*/\1/p'
    return 0
  fi

  return 1
}

SIMULATOR_ID=$(pick_simulator_id)
if [ -z "$SIMULATOR_ID" ]; then
  echo "❌ No available simulator found."
  echo "Run: xcrun simctl list devices available"
  exit 1
fi

DESTINATION="platform=iOS Simulator,id=$SIMULATOR_ID"
echo "📱 Using simulator destination: $DESTINATION"

echo "🔨 Building $SCHEME for simulator..."

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination "$DESTINATION" \
  clean build

echo "✅ Build successful!"

if ! pgrep -x "Simulator" > /dev/null; then
  echo "📱 Launching Simulator..."
  open -a Simulator
  sleep 3
fi

echo "🚀 Installing and launching app..."
xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || true

BUILD_PATH="$(xcodebuild -project "$PROJECT" -scheme "$SCHEME" -sdk iphonesimulator -configuration Debug -showBuildSettings | grep -E '^\s*CONFIGURATION_BUILD_DIR' | sed 's/.*= //')"
APP_PATH="$BUILD_PATH/Tester One.app"

if [ -d "$APP_PATH" ]; then
  xcrun simctl install "$SIMULATOR_ID" "$APP_PATH" 2>/dev/null || echo "⚠️ Install may have failed, check manually"
  xcrun simctl launch "$SIMULATOR_ID" "$BUNDLE_ID" 2>/dev/null || echo "⚠️ Launch may have failed, check manually"
else
  echo "⚠️ App not found at expected path: $APP_PATH"
  echo "   Install and launch manually in Simulator"
fi

echo "✨ Done! Check the simulator."
