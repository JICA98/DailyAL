#!/bin/bash
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Change to script directory so relative paths work correctly
cd "$SCRIPT_DIR"

# Define paths
BUILD_DIR="$ROOT_DIR/build/linux/x64/release/bundle"
APP_DIR="AppDir"
OUTPUT_NAME="DailyAL-x86_64.AppImage"

# Check if build exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: Build directory not found at $BUILD_DIR"
    echo "Please run 'flutter build linux --release' from the project root first."
    exit 1
fi

# Clean previous AppDir
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/usr/bin"
mkdir -p "$APP_DIR/usr/lib"
mkdir -p "$APP_DIR/usr/share/icons/hicolor/256x256/apps"

# Copy bundle to usr/lib/dailyanimelist to keep structure intact
mkdir -p "$APP_DIR/usr/lib/dailyanimelist"
cp -r "$BUILD_DIR/"* "$APP_DIR/usr/lib/dailyanimelist/"

# Link executable from usr/lib to usr/bin
ln -s "../lib/dailyanimelist/dailyanimelist" "$APP_DIR/usr/bin/dailyanimelist"

# Copy Icon
# Assuming we have an icon in assets.
# Using 'assets/images/mal-icon.png' as hinted by pubspec.yaml
cp "$ROOT_DIR/assets/images/mal-icon.png" "$APP_DIR/daily_al.png"
cp "$ROOT_DIR/assets/images/mal-icon.png" "$APP_DIR/usr/share/icons/hicolor/256x256/apps/daily_al.png"

# Setup Desktop file
cp daily_al.desktop "$APP_DIR/"

# Setup AppRun
cp AppRun "$APP_DIR/"
chmod +x "$APP_DIR/AppRun"

# Update AppRun to point to correct location if needed
# Current AppRun: exec ./usr/bin/dailyanimelist "$@"
# This invokes the symlink, which should work.

# Check for appimagetool
if [ ! -f "appimagetool.AppImage" ]; then
    echo "appimagetool not found. Downloading..."
    wget "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage" -O appimagetool.AppImage
    chmod +x appimagetool.AppImage
fi

# Generate AppImage
rm -f "$OUTPUT_NAME"
./appimagetool.AppImage "$APP_DIR" "$OUTPUT_NAME"

echo "AppImage created: $OUTPUT_NAME"
