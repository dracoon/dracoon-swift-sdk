// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "dracoon_sdk",
    platforms: [.iOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "dracoon_sdk",
            targets: ["dracoon_sdk"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.4.0"),
        .package(name: "crypto_sdk", url: "https://github.com/dracoon/dracoon-swift-crypto-sdk", branch: "develop")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "dracoon_sdk",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "crypto_sdk", package: "crypto_sdk")],
            path: "dracoon-sdk"),
        .testTarget(
            name: "dracoon_sdk_tests",
            dependencies: [
                .target(name: "dracoon_sdk"),
                .product(name: "Alamofire", package: "Alamofire")],
            path: "dracoon-sdk-tests",
            exclude: ["Info.plist"])
    ],
    swiftLanguageVersions: [.v5]
)
