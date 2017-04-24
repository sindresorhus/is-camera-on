# is-camera-on

> Check if the built-in Mac camera is on

The camera is commonly known as FaceTime HD or iSight.

This module can be useful to check if the camera is already in use or notify you if it's turned on when you didn't intend it to be.


## Requirements

- Xcode 8+
- macOS 10.11+


## Install

With [SPM](https://swift.org/package-manager/):

```swift
.Package(url: "https://github.com/sindresorhus/is-camera-on", majorVersion: 1)
```


## Usage

```swift
import IsCameraOn

print(isCameraOn())
//=> true
```


## Related

- [node-is-camera-on](https://github.com/sindresorhus/node-is-camera-on) - Node.js wrapper for this module
- [is-camera-on-cli](https://github.com/sindresorhus/is-camera-on-cli) - CLI for this module


## License

MIT © [Sindre Sorhus](https://sindresorhus.com)
