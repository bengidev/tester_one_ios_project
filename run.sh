#!/bin/bash

# run.sh - Universal build & run script for Tester One
# Usage: ./run.sh [simulator|device] [device-name]
# Default: simulator

set -e

SCHEME="Tester One"
PROJECT="Tester One.xcodeproj"
BUNDLE_ID="co.id.LangitMerah.Tester-One"
MODE="${1:-simulator}"
DEVICE_NAME="${2:-}"

case "$MODE" in
  simulator|sim|s)
    echo "📱 Running on Simulator mode"
    ./run-simulator.sh
    ;;
  device|dev|d)
    echo "📱 Running on Real Device mode"
    if [ -n "$DEVICE_NAME" ]; then
        echo "Target device: $DEVICE_NAME"
        ./run-device.sh "$DEVICE_NAME"
    else
        ./run-device.sh
    fi
    ;;
  *)
    echo "Usage: ./run.sh [simulator|device] [device-name]"
    echo ""
    echo "Options:"
    echo "  simulator (default) - Build and run on iOS Simulator"
    echo "  device             - Build and install on connected iPhone/iPad"
    echo ""
    echo "Examples:"
    echo "  ./run.sh                      # Run on simulator"
    echo "  ./run.sh sim                  # Run on simulator (shorthand)"
    echo "  ./run.sh device               # Run on first available device"
    echo "  ./run.sh device \"iPhone Beng\" # Run on specific device"
    exit 1
    ;;
esac
