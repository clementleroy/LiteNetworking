// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [.iOS(.v10)],
    products: [
        .library(name: "Networking", targets: ["Networking"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "6.0.0")
    ],
    targets: [
        .target(
            name: "Networking",
            dependencies: ["RxSwift", .product(name: "RxCocoa", package: "RxSwift")]
        )
    ]
)

