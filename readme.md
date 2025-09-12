# is-camera-on

> Check if a Mac camera is on

Supports built-in cameras (FaceTime HD, iSight) and external physical cameras (USB, Thunderbolt, Continuity Camera, etc.).

This module can be useful to check if the camera is already in use or notify you if it's turned on when you didn't intend it to be.

## Requirements

macOS 10.15+

## Install

Add the following to `Package.swift`:

```swift
.package(url: "https://github.com/sindresorhus/is-camera-on", from: "2.0.2")
```

[Or add the package in Xcode.](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)

## Usage

### Checking camera status

```swift
import IsCameraOn

// Check built-in camera only (default)
print(isCameraOn())
//=> true

// Check both built-in and external physical cameras
print(isCameraOn(includeExternal: true))
//=> true
```

### Monitoring camera status changes

```swift
import IsCameraOn

// Monitor camera status changes with async/await
Task {
	for await isOn in cameraStatusChanges() {
		print("Camera status: \(isOn ? "ON" : "OFF")")
	}
}
```

Notes:
- Emits the current status immediately, then only on changes
- Automatically handles device hot-plugging (cameras being connected/disconnected)
- Uses property listeners for real-time updates (not polling)

## Testing

To run the manual test:

```swift
swift run TestCamera
```

```swift
swift run TestAsyncCamera
```

## Related

- [node-is-camera-on](https://github.com/sindresorhus/node-is-camera-on) - Node.js wrapper for this module
- [is-camera-on-cli](https://github.com/sindresorhus/is-camera-on-cli) - CLI for this module
- [macos-wallpaper](https://github.com/sindresorhus/macos-wallpaper) - Manage the desktop wallpaper
- [do-not-disturb](https://github.com/sindresorhus/do-not-disturb) - Control the macOS `Do Not Disturb` feature
- [More…](https://github.com/search?q=user%3Asindresorhus+language%3Aswift+archived%3Afalse&type=repositories)
