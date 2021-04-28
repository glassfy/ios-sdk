// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Glassfy",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "Glassfy", targets: ["Glassfy"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "Glassfy",
                path: "Source",
                exclude: ["Info.plist"],
                publicHeadersPath: "Public" )
    ]
)
