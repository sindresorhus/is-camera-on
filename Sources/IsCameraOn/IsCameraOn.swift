import CoreMediaIO

/**
Checks if a Mac camera is currently on.

- Parameter includeExternal: If `true`, checks both built-in and external physical cameras. If `false` (default), only checks built-in cameras for backward compatibility.
- Returns: `true` if any camera matching the criteria is active, `false` otherwise.

## Examples

Check only built-in camera (default behavior):

```swift
isCameraOn() // Only built-in cameras
```

Check all physical cameras:

```swift
isCameraOn(includeExternal: true) // Built-in and external physical cameras
```
*/
public func isCameraOn(includeExternal: Bool = false) -> Bool {
	for deviceID in CMIOUtil.getAllDevices() {
		let device = CameraDevice(deviceID)
		
		if includeExternal {
			if
				device.isPhysical,
				device.isRunning
			{
				return true
			}
		} else {
			if
				device.isBuiltIn,
				device.isRunning
			{
				return true
			}
		}
	}
	
	return false
}

/**
Returns an AsyncStream that emits camera status changes in real-time.

- Note: Emits the current status immediately, then only on changes.
- Note: The stream does not complete unless cancelled or the monitor stops. You must cancel the task or break from the loop to stop monitoring.
- Returns: An AsyncStream that yields `true` when any camera is on, `false` when all are off.

```swift
Task {
    for await isOn in cameraStatusChanges() {
        print("Camera is now: \(isOn ? "ON" : "OFF")")
    }
}
```
*/ // TODO: Use AsyncSequence when targeting macOS 15.
public func cameraStatusChanges(includeExternal: Bool = false) -> AsyncStream<Bool> {
	AsyncStream<Bool> { continuation in
		let monitor = CameraMonitor(
			includeExternal: includeExternal,
			continuation: continuation
		)

		continuation.onTermination = { _ in
			Task { @MainActor in
				await monitor.stop()
			}
		}

		Task { @MainActor in
			await monitor.start()
		}
	}
}

/**
Internal monitor that manages camera device listeners and hot-plug detection.
*/
private actor CameraMonitor {
	private let includeExternal: Bool
	private let continuation: AsyncStream<Bool>.Continuation
	private var devices = Set<CMIOObjectID>()
	private var listenerBlocks = [CMIOObjectID: CMIOObjectPropertyListenerBlock]()
	private var isMonitoring = false
	private var lastStatus: Bool?
	private var deviceListenerBlock: CMIOObjectPropertyListenerBlock?
	
	init(
		includeExternal: Bool,
		continuation: AsyncStream<Bool>.Continuation
	) {
		self.includeExternal = includeExternal
		self.continuation = continuation
	}
	
	deinit {
		// Cleanup will be handled by the cancellation handler
	}
	
	func start() {
		guard !isMonitoring else {
			return
		}

		isMonitoring = true
		
		// Monitor for device additions/removals
		setupDeviceListListener()
		
		// Setup initial devices
		refreshDevices()
		
		// Send initial status
		checkAndEmitStatus()
	}
	
	func stop() {
		guard isMonitoring else {
			return
		}

		// Set flag first to prevent re-entrancy during teardown
		isMonitoring = false
		
		// Remove all device listeners
		for deviceID in devices {
			removePropertyListener(for: deviceID)
		}
		
		// Remove device list listener
		if let deviceListenerBlock = deviceListenerBlock {
			var address = CMIOUtil.hardwareDevicesAddress
			
			let status = CMIOObjectRemovePropertyListenerBlock(
				CMIOUtil.systemObject,
				&address,
				DispatchQueue.main,
				deviceListenerBlock
			)

			if status != noErr {
				#if DEBUG
				print("Warning: Failed to remove device list listener: \(status)")
				#endif
			}

			self.deviceListenerBlock = nil
		}
		
		devices.removeAll()
		listenerBlocks.removeAll()
		continuation.finish()
	}
	
	private func setupDeviceListListener() {
		var address = CMIOUtil.hardwareDevicesAddress
		
		let listenerBlock: CMIOObjectPropertyListenerBlock = { [weak self] _, _ in
			Task { [weak self] in
				await self?.handleDeviceListChange()
			}
		}
		
		deviceListenerBlock = listenerBlock
		
		let status = CMIOObjectAddPropertyListenerBlock(
			CMIOUtil.systemObject,
			&address,
			DispatchQueue.main,
			listenerBlock
		)

		if status != noErr {
			#if DEBUG
			print("Warning: Failed to add device list listener: \(status)")
			#endif
		}
	}
	
	private func handleDeviceListChange() {
		guard isMonitoring else {
			return
		}

		refreshDevices()
		checkAndEmitStatus()
	}
	
	private func refreshDevices() {
		let allDeviceIDs = Set(CMIOUtil.getAllDevices())
		
		// Remove listeners for disconnected devices
		let removedDevices = devices.subtracting(allDeviceIDs)
		for deviceID in removedDevices {
			removePropertyListener(for: deviceID)
		}
		
		// Add listeners for new devices
		let newDevices = allDeviceIDs.subtracting(devices)
		for deviceID in newDevices {
			let device = CameraDevice(deviceID)
			if shouldMonitorDevice(device) {
				addPropertyListener(for: deviceID)
			}
		}
		
		// Update tracked devices
		let monitoredDevices = allDeviceIDs.filter { deviceID in
			let device = CameraDevice(deviceID)
			return shouldMonitorDevice(device)
		}
		devices = Set(monitoredDevices)
	}
	
	private func shouldMonitorDevice(_ device: CameraDevice) -> Bool {
		includeExternal ? device.isPhysical : device.isBuiltIn
	}
	
	private func addPropertyListener(for deviceID: CMIOObjectID) {
		var address = CMIOUtil.deviceIsRunningAddress
		
		let listenerBlock: CMIOObjectPropertyListenerBlock = { [weak self] _, _ in
			Task { [weak self] in
				await self?.checkAndEmitStatus()
			}
		}
		
		let status = CMIOObjectAddPropertyListenerBlock(
			deviceID,
			&address,
			DispatchQueue.main,
			listenerBlock
		)
		if status != noErr {
			#if DEBUG
			print("Warning: Failed to add device listener: \(status)")
			#endif
		}
		
		// Only store block if listener was successfully added
		if status == noErr {
			listenerBlocks[deviceID] = listenerBlock
		}
	}
	
	private func removePropertyListener(for deviceID: CMIOObjectID) {
		guard let listenerBlock = listenerBlocks[deviceID] else {
			return
		}

		var address = CMIOUtil.deviceIsRunningAddress
		
		let status = CMIOObjectRemovePropertyListenerBlock(
			deviceID,
			&address,
			DispatchQueue.main,
			listenerBlock
		)
		// Always remove from dictionary to keep it in sync with reality
		listenerBlocks.removeValue(forKey: deviceID)
		
		if status != noErr {
			#if DEBUG
			print("Warning: Failed to remove device listener: \(status)")
			#endif
		}
	}
	
	private func checkAndEmitStatus() {
		guard isMonitoring else {
			return
		}

		let currentStatus = devices.contains { deviceID in
			CameraDevice(deviceID).isRunning
		}
		
		// Only emit if status actually changed
		if lastStatus != currentStatus {
			lastStatus = currentStatus
			continuation.yield(currentStatus)
		}
	}
}
