#!/bin/bash

# Script to run vyuh_node_flow spike tests
# Requires Flutter SDK to be installed and in PATH

echo "=== Vyuh Node Flow Spike Test Runner ==="
echo ""

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter SDK not found in PATH"
    echo "Please install Flutter and add it to your PATH"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found"
    echo "Please run this script from the flutter_workflow_editor directory"
    exit 1
fi

echo "✅ Flutter SDK found: $(flutter --version | head -1)"
echo "✅ Working directory: $(pwd)"
echo ""

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to get dependencies"
    exit 1
fi
echo "✅ Dependencies resolved"
echo ""

# Run the automated tests
echo "🧪 Running automated tests..."
flutter test test/vyuh_node_flow_spike_test.dart
TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
    echo "✅ All tests passed!"
else
    echo "❌ Some tests failed"
fi
echo ""

# Run the test widget (optional)
echo "🎨 To run the visual test widget, use:"
echo "   flutter run -t lib/test_vyuh_node_flow.dart"
echo ""

echo "=== Test Summary ==="
echo "Test files created:"
echo "  - lib/test_vyuh_node_flow.dart (visual test widget)"
echo "  - test/vyuh_node_flow_spike_test.dart (automated tests)"
echo "  - VYUH_NODE_FLOW_SPIKE_REPORT.md (spike report)"
echo ""

echo "Next steps:"
echo "1. Review test results"
echo "2. Run visual test widget to evaluate UI"
echo "3. Update spike report with findings"
echo "4. Make integration decision"
echo ""

exit $TEST_RESULT