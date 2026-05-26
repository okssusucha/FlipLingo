// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FlipLingo",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "FlipLingo",
            path: "Sources"
        )
    ]
)
