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
            url: "https://github.com/alastairapple/pocket-tts-spm/releases/download/0.4.3/PocketTTS.xcframework.zip",
            checksum: "72d143239d5518866687b0c39fc50069955376bf2969e319dbdf70cd39de3f03"
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
