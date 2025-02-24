# Installation

Add UmbraCore to your project using Swift Package Manager.

## Adding the Package Dependency

1. In Xcode, select File > Add Package Dependencies
2. Enter the package URL: `https://github.com/your-org/UmbraCore.git`
3. Click Next and select the version you want to use

## Swift Package Manager Integration

You can also add UmbraCore directly in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/UmbraCore.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["UmbraCore"]
    )
]
```

## Requirements

- macOS 14.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Post-Installation Setup

1. Import the framework in your source files:
```swift
import UmbraCore
```

2. Configure the framework in your app's initialization:
```swift
UmbraCore.configure()
```

## Verification

To verify the installation:

1. Build your project (⌘B)
2. Check that there are no build errors
3. Try importing and using a basic UmbraCore feature

## Troubleshooting

If you encounter any issues during installation:

1. Clean the build folder (⇧⌘K)
2. Clean the package cache:
```bash
rm -rf ~/Library/Caches/org.swift.swiftpm/
```
3. Update the package dependencies
4. Rebuild the project
