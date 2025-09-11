import Foundation
import IsCameraOn

print("📷 Camera status: \(isCameraOn() ? "ON" : "OFF")")

print("\n➡️  Turn your camera ON (open FaceTime, Photo Booth, etc.) and press Enter...")
_ = readLine()
print("📷 Camera status: \(isCameraOn() ? "ON" : "OFF")")

print("\n➡️  Close camera apps and press Enter...")
_ = readLine()
print("📷 Camera status: \(isCameraOn() ? "ON" : "OFF")")
