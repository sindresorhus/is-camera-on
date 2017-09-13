// swift-tools-version:5.5
import PackageDescription

let package = Package(
	name: "IsCameraOn",
	platforms: [
		.macOS(.v10_11)
	],
	products: [
		.library(
			name: "IsCameraOn",
			targets: [
				"IsCameraOn"
			]
		)
	],
	targets: [
		.target(
			name: "IsCameraOn"
		)
	]
)
