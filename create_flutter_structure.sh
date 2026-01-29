#!/bin/bash

# Flutter Project Structure Generator for Transliner Cruiser
# Creates the complete directory structure without file content


# Create lib directory and subdirectories
mkdir -p lib/{models,providers,services,screens,widgets,utils}

# Create screens subdirectories
mkdir -p lib/screens/{auth,home,trip,settings,operations}

echo "📁 Creating directory structure..."

# Create all directories
mkdir -p lib/models
mkdir -p lib/providers  
mkdir -p lib/services
mkdir -p lib/screens/auth
mkdir -p lib/screens/home
mkdir -p lib/screens/trip
mkdir -p lib/screens/settings
mkdir -p lib/screens/operations
mkdir -p lib/widgets
mkdir -p lib/utils

echo "📄 Creating empty files..."

# Create main entry point
touch lib/main.dart

# Create model files
touch lib/models/user_model.dart
touch lib/models/trip_model.dart

# Create provider files
touch lib/providers/auth_provider.dart
touch lib/providers/trip_provider.dart
touch lib/providers/app_settings_provider.dart

# Create service files
touch lib/services/api_service.dart

# Create screen files
touch lib/screens/auth/login_screen.dart
touch lib/screens/home/main_screen.dart
touch lib/screens/home/home_content.dart
touch lib/screens/trip/trip_detail_screen.dart
touch lib/screens/trip/seat_selection_screen.dart
touch lib/screens/trip/payment_screen.dart
touch lib/screens/settings/app_settings_screen.dart
touch lib/screens/operations/operations_screen.dart

# Create widget files
touch lib/widgets/trip_card.dart
touch lib/widgets/seat_widget.dart
touch lib/widgets/loading_widget.dart
touch lib/widgets/error_widget.dart

# Create utility files
touch lib/utils/constants.dart

# Create additional Flutter project files
touch pubspec.yaml
touch README.md

# Create test directories
mkdir -p test/{unit,widget,integration}
touch test/widget_test.dart

# Create integration test directory
mkdir -p integration_test
touch integration_test/app_test.dart

# Create assets directories
mkdir -p assets/{images,icons,fonts}

# Create android and ios directories (Flutter standard)
mkdir -p android/app/src/main
mkdir -p ios/Runner

echo "✅ Flutter project structure created successfully!"
echo ""
echo "📊 Project Structure:"
echo "transliner_cruiser/"
echo "├── lib/"
echo "│   ├── main.dart"
echo "│   ├── models/"
echo "│   │   ├── user_model.dart"
echo "│   │   └── trip_model.dart"
echo "│   ├── providers/"
echo "│   │   ├── auth_provider.dart"
echo "│   │   ├── trip_provider.dart"
echo "│   │   └── app_settings_provider.dart"
echo "│   ├── services/"
echo "│   │   └── api_service.dart"
echo "│   ├── screens/"
echo "│   │   ├── auth/"
echo "│   │   │   └── login_screen.dart"
echo "│   │   ├── home/"
echo "│   │   │   ├── main_screen.dart"
echo "│   │   │   └── home_content.dart"
echo "│   │   ├── trip/"
echo "│   │   │   ├── trip_detail_screen.dart"
echo "│   │   │   ├── seat_selection_screen.dart"
echo "│   │   │   └── payment_screen.dart"
echo "│   │   ├── settings/"
echo "│   │   │   └── app_settings_screen.dart"
echo "│   │   └── operations/"
echo "│   │       └── operations_screen.dart"
echo "│   ├── widgets/"
echo "│   │   ├── trip_card.dart"
echo "│   │   ├── seat_widget.dart"
echo "│   │   ├── loading_widget.dart"
echo "│   │   └── error_widget.dart"
echo "│   └── utils/"
echo "│       └── constants.dart"
echo "├── test/"
echo "├── integration_test/"
echo "├── assets/"
echo "├── pubspec.yaml"
echo "└── README.md"
echo ""
echo "🎯 Next Steps:"
echo "1. cd transliner_cruiser"
echo "2. flutter create . (to initialize Flutter project)"
echo "3. Copy the provided file contents to respective files"
echo "4. flutter pub get"
echo "5. flutter run"
echo ""
echo "📝 Note: This script creates the directory structure and empty files."
echo "You'll need to copy the actual file contents from the provided files."