#!/bin/bash

# run-tests.sh - Run unit tests

set -e

SCHEME="Tester One"
PROJECT="Tester One.xcodeproj"
DESTINATION="platform=iOS Simulator,name=iPhone 16 Pro,OS=latest"

echo "🧪 Running tests..."

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  test

echo "✅ Tests completed!"
