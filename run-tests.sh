#!/bin/bash

# run-tests.sh - Run tests with resilient simulator selection

set -e

SCHEME="Tester One"
PROJECT="Tester One.xcodeproj"

pick_simulator_id() {
  local available
  available=$(xcrun simctl list devices available)

  # Preferred iPhone simulators (newest first)
  for name in "iPhone 17 Pro" "iPhone 17" "iPhone 16 Plus Fresh" "iPhone 16e" "iPhone Air"; do
    local line
    line=$(echo "$available" | grep -m1 "$name" || true)
    if [ -n "$line" ]; then
      echo "$line" | sed -n 's/.*(\([A-F0-9-]\{36\}\)).*/\1/p'
      return 0
    fi
  done

  # Fallback: any available iPhone
  local any_iphone
  any_iphone=$(echo "$available" | grep -m1 "iPhone" || true)
  if [ -n "$any_iphone" ]; then
    echo "$any_iphone" | sed -n 's/.*(\([A-F0-9-]\{36\}\)).*/\1/p'
    return 0
  fi

  # Last resort: any available simulator device
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

echo "🧪 Running tests on destination: $DESTINATION"

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  test

echo "✅ Tests completed!"
