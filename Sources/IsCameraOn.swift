import Foundation
import AVFoundation
import CoreMediaIO

private func getCameraProp() -> CMIOObjectID? {
	var opa = CMIOObjectPropertyAddress(
		mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyDevices),
		mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
		mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMaster)
	)

	var (dataSize, dataUsed) = (UInt32(0), UInt32(0))
	var result = CMIOObjectGetPropertyDataSize(CMIOObjectID(kCMIOObjectSystemObject), &opa, 0, nil, &dataSize)
	var devices: UnsafeMutableRawPointer? = nil

	repeat {
		if devices != nil {
			free(devices)
			devices = nil
		}
		devices = malloc(Int(dataSize))
		result = CMIOObjectGetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &opa, 0, nil, dataSize, &dataUsed, devices);
	} while result == OSStatus(kCMIOHardwareBadPropertySizeError)

	var cameraId: CMIOObjectID? = nil

	if let devices = devices {
		for offset in stride(from: 0, to: dataSize, by: MemoryLayout<CMIOObjectID>.size) {
			let current = devices.advanced(by: Int(offset)).assumingMemoryBound(to: CMIOObjectID.self)
			cameraId = current.pointee
		}
	}

	free(devices)

	return cameraId
}

public func isCameraOn() -> Bool {
	guard let camera = getCameraProp() else {
		return false
	}

	var opa = CMIOObjectPropertyAddress(
		mSelector: CMIOObjectPropertySelector(kCMIODevicePropertyDeviceIsRunningSomewhere),
		mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeWildcard),
		mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementWildcard)
	)

	var isUsed: Bool? = nil

	var (dataSize, dataUsed) = (UInt32(0), UInt32(0))
	var result = CMIOObjectGetPropertyDataSize(camera, &opa, 0, nil, &dataSize)
	if result == OSStatus(kCMIOHardwareNoError) {
		if let data = malloc(Int(dataSize)) {
			result = CMIOObjectGetPropertyData(camera, &opa, 0, nil, dataSize, &dataUsed, data)
			let on = data.assumingMemoryBound(to: UInt8.self)
			isUsed = on.pointee != 0
		}
	}

	return isUsed ?? false
}
