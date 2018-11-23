// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "DataMapper",
    products: [
        .library(
            name: "DataMapper",
            targets: ["DataMapper"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble.git", from: "7.0.1"),
        .package(url: "https://github.com/Quick/Quick.git", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "DataMapper",
            dependencies: [],
            path: "Source"),
        .testTarget(
            name: "DataMapperTests",
            dependencies: ["DataMapper", "Nimble", "Quick"],
            path: "Tests"),
    ]
)
