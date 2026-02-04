#!/bin/bash

# build-and-format.sh - Format code and build

set -e

echo "🎨 Running SwiftFormat..."
swiftformat . || echo "⚠️ SwiftFormat not installed or failed"

echo "🔨 Building..."
xcodebuild \
  -project "Tester One.xcodeproj" \
  -scheme "Tester One" \
  -sdk iphonesimulator \
  -configuration Debug \
  build

echo "✅ Done!"
