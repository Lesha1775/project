// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "HomePharmacyModules",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "HomePharmacyModules", targets: ["HomePharmacyModules"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "HomePharmacyModules",
            dependencies: [],
            path: "HomePharmacy",
            exclude: ["App/HomePharmacyApp.swift"]
        )
    ]
)
