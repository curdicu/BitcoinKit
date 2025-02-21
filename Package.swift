// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "BitcoinKit",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "BitcoinKit",
            targets: ["BitcoinKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/curdicu/BitcoinCore.git", .branch( "main")),
        .package(url: "https://github.com/curdicu/Hodler.git", .branch( "main")),
        .package(url: "https://github.com/curdicu/HdWalletKit.git", .branch( "main")),
        .package(url: "https://github.com/curdicu/HsToolKit.git", .branch( "main")),
    ],
    targets: [
        .target(
            name: "BitcoinKit",
            dependencies: [
                .product(name: "BitcoinCore", package: "BitcoinCore"),
                .product(name: "Hodler", package: "Hodler"),
                .product(name: "HdWalletKit", package: "HdWalletKit"),
                .product(name: "HsToolKit", package: "HsToolKit"),
            ]
        ),
    ]
)
