import CoreMediaIO

enum TransportType: UInt32 {
	case builtIn = 0x626C746E // 'bltn'
	case usb = 0x75736220 // 'usb '
	case virtual = 0x76697274 // 'virt'
}

struct CameraDevice {
	let id: CMIOObjectID

	init(_ id: CMIOObjectID) {
		self.id = id
	}

	var transportType: TransportType? {
		guard
			let rawValue = CMIOUtil.getProperty(
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
		let raw: UInt32? = CMIOUtil.getProperty(
			from: id,
			selector: CMIOObjectPropertySelector(kCMIODevicePropertyDeviceIsRunningSomewhere),
			as: UInt32.self
		)

		return (raw ?? 0) != 0
	}

	var isBuiltIn: Bool {
		transportType == .builtIn
	}
	
	// Anything not virtual is considered "physical".
	// This covers USB, Thunderbolt/PCIe bridges, Bluetooth/Wi-Fi bridges, etc.
	// Conservative: treat unknown transport types as not physical to avoid misclassifying virtual devices
	var isPhysical: Bool {
		transportType.map { $0 != .virtual } ?? false
	}
	
	var isExternal: Bool {
		isPhysical && !isBuiltIn
	}
}

enum CMIOUtil {
	static let systemObject = CMIOObjectID(kCMIOObjectSystemObject)
	
	// Common property addresses
	static let deviceIsRunningAddress = CMIOObjectPropertyAddress(
		mSelector: CMIOObjectPropertySelector(kCMIODevicePropertyDeviceIsRunningSomewhere),
		mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeWildcard),
		mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementWildcard)
	)
	
	static let hardwareDevicesAddress = CMIOObjectPropertyAddress(
		mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyDevices),
		mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
		mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMaster)
	)

	static func hasProperty(
		objectID: CMIOObjectID,
		selector: CMIOObjectPropertySelector
	) -> Bool {
		var address = CMIOObjectPropertyAddress(selector)
		return CMIOObjectHasProperty(objectID, &address)
	}
	
	static func getProperty<T>(
		from objectID: CMIOObjectID,
		selector: CMIOObjectPropertySelector,
		as: T.Type
	) -> T? {
		guard hasProperty(objectID: objectID, selector: selector) else {
			return nil
		}
		
		var address = CMIOObjectPropertyAddress(selector)
		var dataSize: UInt32 = 0

		guard CMIOObjectGetPropertyDataSize(objectID, &address, 0, nil, &dataSize) == noErr else {
			return nil
		}
		
		guard dataSize > 0 else {
			return nil
		}

		return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: Int(dataSize)) { buffer -> T? in
			var dataUsed: UInt32 = 0
			guard
				CMIOObjectGetPropertyData(objectID, &address, 0, nil, dataSize, &dataUsed, buffer.baseAddress) == noErr
			else {
				return nil
			}
			
			// Validate that we got the expected amount of data
			guard dataUsed == dataSize, dataUsed == UInt32(MemoryLayout<T>.size) else {
				return nil
			}
			
			// Safe to bind memory now
			guard let baseAddress = buffer.baseAddress else { return nil }
			return baseAddress.withMemoryRebound(to: T.self, capacity: 1) { ptr in
				ptr.pointee
			}
		}
	}

	static func getAllDevices() -> [CMIOObjectID] {
		var address = hardwareDevicesAddress

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
			
			// Validate we got the expected data size
			let expectedSize = count * MemoryLayout<CMIOObjectID>.size
			guard dataUsed == UInt32(expectedSize) else {
				return []
			}

			return Array(buffer.prefix(count))
		}
	}
}

extension CMIOObjectPropertyAddress {
	init(_ selector: CMIOObjectPropertySelector) {
		self.init(
			mSelector: selector,
			mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeWildcard),
			mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementWildcard)
		)
	}
}
