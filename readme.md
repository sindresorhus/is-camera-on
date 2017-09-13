# is-camera-on

> Check if the built-in Mac camera is on

The camera is commonly known as FaceTime HD or iSight.

This module can be useful to check if the camera is already in use or notify you if it's turned on when you didn't intend it to be.

## Requirements

- macOS 10.11+
- Xcode 13+
- Swift 5.5+

## Install

Add the following to `Package.swift`:

```swift
.package(url: "https://github.com/sindresorhus/is-camera-on", from: "2.0.0")
```

[Or add the package in Xcode.](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)

## Usage

```swift
import IsCameraOn

print(isCameraOn())
//=> true
```

## Related

- [node-is-camera-on](https://github.com/sindresorhus/node-is-camera-on) - Node.js wrapper for this module
- [is-camera-on-cli](https://github.com/sindresorhus/is-camera-on-cli) - CLI for this module
- [macos-wallpaper](https://github.com/sindresorhus/macos-wallpaper) - Manage the desktop wallpaper
- [do-not-disturb](https://github.com/sindresorhus/do-not-disturb) - Control the macOS `Do Not Disturb` feature
- [More…](https://github.com/search?q=user%3Asindresorhus+language%3Aswift)
