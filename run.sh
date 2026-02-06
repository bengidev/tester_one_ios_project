#!/bin/bash

# run.sh - Universal build & run script for Tester One
# Usage: ./run.sh [auto|simulator|device] [device-name]
# Default: auto (prefer real device, fallback to simulator)

set -e

MODE="${1:-auto}"
DEVICE_NAME="${2:-}"

has_physical_device() {
  xcrun xctrace list devices 2>/dev/null \
    | grep -E "iPhone|iPad" \
    | grep -v "Simulator" \
    | grep -v "unavailable" >/dev/null
}

run_device_or_fallback() {
  if has_physical_device; then
    echo "📱 Physical device detected, targeting real device"
    if [ -n "$DEVICE_NAME" ]; then
      echo "Target device: $DEVICE_NAME"
      ./run-device.sh "$DEVICE_NAME"
    else
      ./run-device.sh
    fi
  else
    echo "📱 No physical device connected, falling back to simulator"
    ./run-simulator.sh
  fi
}

case "$MODE" in
  auto|a)
    run_device_or_fallback
    ;;
  simulator|sim|s)
    echo "📱 Running on Simulator mode"
    ./run-simulator.sh
    ;;
  device|dev|d)
    run_device_or_fallback
    ;;
  *)
    echo "Usage: ./run.sh [auto|simulator|device] [device-name]"
    echo ""
    echo "Options:"
    echo "  auto (default)     - Use connected real device; fallback to simulator"
    echo "  simulator          - Build and run on iOS Simulator"
    echo "  device             - Prefer real device, fallback to simulator"
    echo ""
    echo "Examples:"
    echo "  ./run.sh                      # Auto target selection"
    echo "  ./run.sh auto                 # Auto target selection"
    echo "  ./run.sh sim                  # Run on simulator (shorthand)"
    echo "  ./run.sh device               # Real device if connected, else simulator"
    echo "  ./run.sh device \"iPhone Beng\" # Match specific real device name"
    exit 1
    ;;
esac
