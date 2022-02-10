// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Lexicon",
    platforms: [
        .macOS(.v11),
        .iOS(.v14)
    ],
    products: [
        .library(name: "Lexicon", targets: ["Lexicon"]),
        .library(name: "LexiconGenerators", targets: ["LexiconGenerators"]),
        .library(name: "SwiftLexicon", targets: ["SwiftLexicon"]),
    ],
    dependencies: [
        .package(url: "https://github.com/screensailor/Hope", .branch("trunk")),
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
    ],
    targets: [
        
        // MARK: Lexicon
        
        .target(
            name: "Lexicon",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
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
        
        // MARK: LexiconGenerators
        
        .target(
            name: "LexiconGenerators",
            dependencies: [
                "Lexicon",
                "SwiftLexicon",
            ]
        ),
        
        // MARK: SwiftLexicon
        
        .target(
            name: "SwiftLexicon",
            dependencies: [
                "Lexicon",
            ]
        ),
        .testTarget(
            name: "SwiftLexiconTests",
            dependencies: [
                "Hope",
                "SwiftLexicon"
            ],
            resources: [
                .copy("Resources"),
            ]
        ),
    ]
)
