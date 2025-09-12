// swift-tools-version:5.9
import PackageDescription

let package = Package(
	name: "IsCameraOn",
	platforms: [
		.macOS(.v10_15)
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
		),
		.executableTarget(
			name: "TestCamera",
			dependencies: [
				"IsCameraOn"
			]
		),
		.executableTarget(
			name: "TestAsyncCamera",
			dependencies: [
				"IsCameraOn"
			]
		)
	]
)
