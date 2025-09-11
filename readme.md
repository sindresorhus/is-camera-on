# is-camera-on

> Check if a Mac camera is on

Supports built-in cameras (FaceTime HD, iSight) and external USB cameras.

This module can be useful to check if the camera is already in use or notify you if it's turned on when you didn't intend it to be.

## Requirements

macOS 10.13+

## Install

Add the following to `Package.swift`:

```swift
.package(url: "https://github.com/sindresorhus/is-camera-on", from: "2.0.2")
```

[Or add the package in Xcode.](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)

## Usage

```swift
import IsCameraOn

// Check built-in camera only (default)
print(isCameraOn())
//=> true

// Check both built-in and external USB cameras
print(isCameraOn(includeExternal: true))
//=> true
```

## Testing

To run the manual test:

```swift
swift run TestCamera
```

## Related

- [node-is-camera-on](https://github.com/sindresorhus/node-is-camera-on) - Node.js wrapper for this module
- [is-camera-on-cli](https://github.com/sindresorhus/is-camera-on-cli) - CLI for this module
- [macos-wallpaper](https://github.com/sindresorhus/macos-wallpaper) - Manage the desktop wallpaper
- [do-not-disturb](https://github.com/sindresorhus/do-not-disturb) - Control the macOS `Do Not Disturb` feature
- [More…](https://github.com/search?q=user%3Asindresorhus+language%3Aswift+archived%3Afalse&type=repositories)
