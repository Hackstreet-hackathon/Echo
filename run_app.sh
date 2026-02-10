echo "🚀 Cleaning build environment..."
# Kill any stale flutter processes
pkill -f 'flutter' || true
# Remove build artifacts to force a clean build
rm -rf build .dart_tool android/app/build

echo "📦 Installing dependencies..."
flutter pub get

echo "📱 Checking connected devices..."
adb devices

echo ""
echo "🔨 Building and running the app on device (WS9TIRRO6XTWTC7P)..."
# Run with verbose logging to catch any issues
flutter run -d WS9TIRRO6XTWTC7P -v
