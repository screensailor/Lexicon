// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Lexicon",
    platforms: [.macOS(.v11), .iOS(.v14)],
    products: [
        .library(name: "Lexicon", targets: ["Lexicon"]),
    ],
    dependencies: [
        .package(url: "https://github.com/screensailor/Hope.git", .branch("trunk")),
    ],
    targets: [
        .target(name: "Lexicon"),
        .testTarget(name: "LexiconTests", dependencies: ["Hope", "Lexicon"]),
    ]
)
