import IsCameraOn
import Foundation

print("=== AsyncSequence Camera Status Test ===")
print("This test demonstrates the async/await API")
print("")

func runAsyncTests() async {
	// Test 1: Basic monitoring
	print("📱 Starting basic camera monitoring (built-in only)...")
	let basicTask = Task {
		var changeCount = 0
		for await isOn in cameraStatusChanges() {
			changeCount += 1
			let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
			print("[\(timestamp)] Camera status changed (#\(changeCount)): \(isOn ? "📸 ON" : "📴 OFF")")
			
			// Stop after 5 changes for demo purposes
			if changeCount >= 5 {
				print("✅ Received 5 status changes, stopping basic monitoring")
				break
			}
		}
	}
	
	// Test 2: Monitoring with external cameras
	print("\n🔌 Starting extended monitoring (including external cameras)...")
	let extendedTask = Task {
		for await isOn in cameraStatusChanges(includeExternal: true) {
			let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
			print("[\(timestamp)] All cameras: \(isOn ? "🟢 ACTIVE" : "⚫ INACTIVE")")
			
			// Demo runs for 30 seconds
			try? await Task.sleep(nanoseconds: 100_000_000) // Small delay to avoid flooding
		}
	}
	
	// Let tests run for 30 seconds
	print("\n⏰ Tests will run for 30 seconds...")
	print("💡 Try opening/closing camera apps during this time!")
	print("   - Open Photo Booth, FaceTime, or Zoom")
	print("   - Connect/disconnect external cameras")
	print("")
	
	try? await Task.sleep(nanoseconds: 30_000_000_000)
	basicTask.cancel()
	extendedTask.cancel()
	print("\n✅ All tests completed!")
}

Task {
	await runAsyncTests()
	exit(0)
}

RunLoop.main.run()
