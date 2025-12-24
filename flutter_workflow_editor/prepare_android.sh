#!/bin/bash
# Script to prepare Flutter module for integration with the Android app

echo "🔧 Preparing Flutter workflow editor for Android integration..."

# Change to the Flutter module directory
cd "$(dirname "$0")"

# Check if Flutter SDK is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter SDK not found in PATH"
    echo "Please ensure Flutter is installed and available in your PATH"
    exit 1
fi

# Get Flutter SDK path
FLUTTER_SDK=$(which flutter | sed 's|/bin/flutter||')
echo "📱 Flutter SDK found at: $FLUTTER_SDK"

# Create/update local.properties with Flutter SDK path
echo "📝 Updating local.properties..."
cat > .android/local.properties << EOF
flutter.sdk=$FLUTTER_SDK
EOF

# Get Flutter project info
echo "📦 Getting Flutter project info..."
flutter --version

echo "✅ Flutter module preparation complete!"
echo ""
echo "Next steps:"
echo "1. Run 'flutter pub get' to install dependencies"
echo "2. Build the Android app with the Flutter module included"
