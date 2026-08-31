// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "PocketTTSKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "PocketTTSKit", targets: ["PocketTTSKit"])
    ],
    targets: [
        .binaryTarget(
            name: "PocketTTSBinary",
            url: "https://github.com/alastairapple/pocket-tts-spm/releases/download/0.4.1/PocketTTS.xcframework.zip",
            checksum: "60f91904720e227c8fab7ec64d389e75c1ec3294e3041b42a4df3f5f31c417d5"
        ),
        .target(
            name: "PocketTTSKit",
            dependencies: ["PocketTTSBinary"],
            path: "Sources/PocketTTSKit",
            // The UniFFI-generated bindings are not written for Swift 6 strict
            // concurrency; the public surface consumers touch is the
            // `PocketTTSSwift` actor.
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
