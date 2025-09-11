import Foundation
import IsCameraOn

// Test built-in camera only
print("📷 Built-in camera status: \(isCameraOn() ? "ON" : "OFF")")

// Test all cameras (built-in + USB)
print("🔌 All cameras status: \(isCameraOn(includeExternal: true) ? "ON" : "OFF")")

print("\n➡️  Turn your camera ON (open FaceTime, Photo Booth, etc.) and press Enter...")
_ = readLine()

print("📷 Built-in camera status: \(isCameraOn() ? "ON" : "OFF")")
print("🔌 All cameras status: \(isCameraOn(includeExternal: true) ? "ON" : "OFF")")

print("\n➡️  Close camera apps and press Enter...")
_ = readLine()

print("📷 Built-in camera status: \(isCameraOn() ? "ON" : "OFF")")
print("🔌 All cameras status: \(isCameraOn(includeExternal: true) ? "ON" : "OFF")")
