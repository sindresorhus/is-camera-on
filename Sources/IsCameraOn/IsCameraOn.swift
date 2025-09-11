import CoreMediaIO

private enum TransportType: UInt32 {
	case builtIn = 0x626C746E // 'bltn'
	case virtual = 0x76697274 // 'virt'
}

private struct CameraDevice {
	let id: CMIOObjectID

	init(_ id: CMIOObjectID) {
		self.id = id
	}

	var transportType: TransportType? {
		guard
			let rawValue = CoreMediaIO.getProperty(
				from: id,
				selector: CMIOObjectPropertySelector(kCMIODevicePropertyTransportType),
				as: UInt32.self
			)
		else {
			return nil
		}

		return TransportType(rawValue: rawValue)
	}

	var isRunning: Bool {
		let runningStatus = CoreMediaIO.getProperty(
			from: id,
			selector: CMIOObjectPropertySelector(kCMIODevicePropertyDeviceIsRunningSomewhere),
			as: UInt8.self
		)

		return runningStatus == 1
	}

	var isBuiltIn: Bool {
		transportType == .builtIn
	}
}

private enum CoreMediaIO {
	static let systemObject = CMIOObjectID(kCMIOObjectSystemObject)

	static func getProperty<T>(
		from objectID: CMIOObjectID,
		selector: CMIOObjectPropertySelector,
		as: T.Type
	) -> T? {
		var address = CMIOObjectPropertyAddress(selector)
		var dataSize: UInt32 = 0

		guard CMIOObjectGetPropertyDataSize(objectID, &address, 0, nil, &dataSize) == noErr else {
			return nil
		}

		return withUnsafeTemporaryAllocation(of: T.self, capacity: 1) { buffer in
			var dataUsed: UInt32 = 0
			guard
				CMIOObjectGetPropertyData(objectID, &address, 0, nil, dataSize, &dataUsed, buffer.baseAddress) == noErr
			else {
				return nil
			}

			return buffer.first
		}
	}

	static func getAllDevices() -> [CMIOObjectID] {
		var address = CMIOObjectPropertyAddress(
			mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyDevices),
			mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
			mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMaster)
		)

		var dataSize: UInt32 = 0
		guard
			CMIOObjectGetPropertyDataSize(systemObject, &address, 0, nil, &dataSize) == noErr,
			dataSize > 0
		else {
			return []
		}

		let count = Int(dataSize) / MemoryLayout<CMIOObjectID>.size

		return withUnsafeTemporaryAllocation(of: CMIOObjectID.self, capacity: count) { buffer in
			var dataUsed: UInt32 = 0
			guard
				CMIOObjectGetPropertyData(systemObject, &address, 0, nil, dataSize, &dataUsed, buffer.baseAddress) == noErr
			else {
				return []
			}

			return Array(buffer.prefix(count))
		}
	}
}

private extension CMIOObjectPropertyAddress {
	init(_ selector: CMIOObjectPropertySelector) {
		self.init(
			mSelector: selector,
			mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeWildcard),
			mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementWildcard)
		)
	}
}

/**
Checks if the built-in Mac camera is currently on.

Returns `true` if any built-in camera is active, `false` otherwise.
*/
public func isCameraOn() -> Bool {
	CoreMediaIO.getAllDevices()
		.map(CameraDevice.init)
		.filter(\.isBuiltIn)
		.contains(where: \.isRunning)
}
