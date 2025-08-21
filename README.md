<div style="text-align: center;">
    <h1>iPadOS Menu Bar</h1>
    <a href="https://wakatime.com/badge/github/ELadrimonos/ipados_menu_bar">
        <img src="https://wakatime.com/badge/github/ELadrimonos/ipados_menu_bar.svg" alt="WakaTime">
    </a>
    <br><br>
    <p><strong>A custom PlatformMenuDelegate that adds iPadOS 26+ menu bar functionality to Flutter apps</strong></p>
</div>

---

<p align="center">
  <img src="https://github.com/ELadrimonos/ipados_menu_bar/blob/5d489028d0cbb6e75a2859e290ca3858c3f66dd6/preview.gif" width="80%" alt="iPad menu bar preview"/>
</p>

## 🚀 Features

Bring the native iPadOS menu bar experience to your Flutter applications with this custom `PlatformMenuDelegate`. This package provides seamless integration with iPadOS 26+ menu bar functionality, allowing users to access app features through the system menu bar.

## 📦 Installation

Add `ipados_menu_bar` to your `pubspec.yaml`:

```yaml
dependencies:
  ipados_menu_bar: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## 🏁 Getting Started

### Basic Setup

Initialize the iPadOS menu bar in your app's `main()` method:

```dart
import 'package:flutter/material.dart';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformMenuDelegate = IpadOSPlatformMenuDelegate();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iPadOS Menu Bar Demo',
      home: PlatformMenuBar(
        menus: [
          // Your custom menus here
          PlatformMenu(
            label: 'Actions',
            menus: [
              PlatformMenuItemGroup(
                members: [
                  PlatformMenuItem(
                    label: 'New Document',
                    onSelected: () {
                      // Handle action
                    },
                  ),
                  PlatformMenuItem(
                    label: 'Open Document',
                    onSelected: () {
                      // Handle action
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text('My App'),
          ),
          body: Center(
            child: Text('Hello iPadOS Menu Bar!'),
          ),
        ),
      ),
    );
  }
}
```

## 🎛️ Customization Options

### Hidden Default Menus

The package allows you to hide default system menu items that come with iPadOS:

- **File**: Hide file-related actions
- **Edit**: Hide editing actions (cut, copy, paste, etc.)
- **Format**: Hide text formatting options
- **View**: Hide view-related controls

You can customize default menu items behavior using the configureDefaultMenus method:

```dart
// Get instance of the Menu Delegate
_menuDelegate = WidgetsBinding.instance.platformMenuDelegate as IpadOSPlatformMenuDelegate;

// Hide default menus
await _menuDelegate.configureDefaultMenus({
    'hidden': ['format', 'edit'],
});

// Add custom items to the default iOS menu items
await _menuDelegate.configureDefaultMenus({
    'file': {
        'additionalItems': [
          {'id': 100, 'label': 'New Special File', 'enabled': true},
          {'id': 101, 'label': 'Open Special File', 'enabled': true},
        ],
    },
});
```

### Menu Structure

Create organized menu hierarchies with:
- `PlatformMenu`: Top-level menu categories
- `PlatformMenuItemGroup`: Grouped menu items with separators
- `PlatformMenuItem`: Individual menu actions with optional keyboard shortcuts

## 📱 Platform Support

This package is specifically designed for iPadOS 26+ and provides enhanced functionality when running on compatible devices. On other platforms, it gracefully falls back to standard Flutter menu behavior.

## 🔧 Feature Roadmap

| Feature | Status |
|---------|--------|
| Basic Menu Bar Integration | ✅ |
| Custom Menu Items | ✅ |
| Hide Default Menus (File, Edit, Format, View) | ✅ |
| Submenu Nesting | ✅ |
| Dynamic Menu Updates | ✅ |
| App Info custom children items | 🚧 |
| Menu Icons Support | ❌ |
| Custom Menu Items Placement | ❌ |
| Menu Separators | ❓ |

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📄 License

This package is licensed under [MIT License](LICENSE).
