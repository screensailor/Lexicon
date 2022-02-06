// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Lexicon",
    platforms: [.macOS(.v11), .iOS(.v14)],
    products: [
        .library(name: "Lexicon", targets: ["Lexicon"]),
    ],
    dependencies: [
        .package(url: "https://github.com/screensailor/Hope", .branch("trunk")),
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Lexicon",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ],
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "LexiconTests",
            dependencies: [
                "Hope",
                "Lexicon"
            ],
            resources: [
                .copy("Resources")
            ]
        ),
    ]
)
