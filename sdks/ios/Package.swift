// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PairAiAssistant",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "PairAiAssistant",
            targets: ["PairAiAssistant"]
        ),
    ],
    targets: [
        .target(
            name: "PairAiAssistant",
            path: "Sources/PairAiAssistant"
        ),
        .testTarget(
            name: "PairAiAssistantTests",
            dependencies: ["PairAiAssistant"],
            path: "Tests/PairAiAssistantTests",
            resources: [
                .process("Fixtures"),
            ]
        ),
    ]
)
