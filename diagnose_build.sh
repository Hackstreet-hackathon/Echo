#!/bin/bash
set -e

echo "🔍 Starting Build Diagnosis..."
echo "Killing stale processes..."
pkill -f dart || true
pkill -f flutter || true

echo "Cleaning build..."
rm -rf build .dart_tool android/app/build
rm -f pubspec.lock

echo "Getting dependencies..."
flutter pub get

echo "Building APK (Verbose)..."
flutter build apk --debug --verbose > build_diagnosis.log 2>&1

echo "✅ Diagnosis complete. Check build_diagnosis.log"
