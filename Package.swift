// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "eRpKit",
    defaultLocalization: "de",
    platforms: [
        .iOS(.v15), .macOS(.v12)
    ],
    products: [
        .library(name: "eRpFeatures", targets: ["eRpFeatures"]),
        .library(name: "eRpStyleKit", targets: ["eRpStyleKit"]),
        .library(name: "eRpKit", targets: ["eRpKit"]),
        .library(name: "eRpLocalStorage", targets: ["eRpLocalStorage"]),
        .library(name: "eRpRemoteStorage", targets: ["eRpRemoteStorage"]),
        .library(name: "Pharmacy", targets: ["Pharmacy"]),
        .library(name: "AVS", targets: ["AVS"]),
        .library(name: "IDP", targets: ["IDP"]),
        .library(name: "FHIRClient", targets: ["FHIRClient"]),
        .library(name: "HTTPClient", targets: ["HTTPClient"]),
        .library(name: "TestUtils", targets: ["TestUtils"]),
        .library(name: "TrustStore", targets: ["TrustStore"]),
        .library(name: "VAUClient", targets: ["VAUClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ContentSquare/CS_iOS_SDK.git", from: "4.16.0"),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs", from: "9.1.0"),
        .package(url: "https://github.com/andyjohns/zxcvbn-ios", revision: "bf6083dc17df950c8bdfcf2063859ee1270015fd"),
        .package(url: "https://github.com/apple/FHIRModels", from: "0.4.0"),
        .package(url: "https://github.com/gematik/ref-GemCommonsKit.git", from: "1.3.0"),
        .package(url: "https://github.com/pointfreeco/combine-schedulers", from: "0.5.3"),
        .package(url: "https://github.com/pointfreeco/composable-core-location", from: "0.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "0.7.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.59.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.11.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.6.0"),
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "0.8.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.10.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.9.0"),
        .package(url: "https://github.com/Quick/Nimble", from: "9.2.0"), // 10.0.0
        .package(url: "https://github.com/siteline/SwiftUI-Introspect", from: "0.1.3"),
        // higher minor versions result into: "contains unsafe build flags"
        .package(url: "https://github.com/zxingify/zxingify-objc", exact: "3.6.7"),
        .package(url: "https://github.com/SwiftCommon/DataKit", from: "1.1.0"),
        .package(url: "https://github.com/gematik/ASN1Kit", from: "1.2.0"),
        .package(url: "https://github.com/gematik/OpenSSL-Swift", from: "4.1.0"),
        .package(url: "https://github.com/gematik/swift-gemPDFKit", from: "0.1.0"),
        .package(url: "https://github.com/gematik/ref-OpenHealthCardKit", from: "5.3.0"),
    ],
    targets: [
        .target(
            name: "eRpFeatures",
            dependencies: [
                "eRpStyleKit",
                "eRpRemoteStorage",
                "eRpKit",
                "eRpLocalStorage",
                "Pharmacy",
                "IDP",
                "HTTPClient",
                "FHIRClient",
                "TrustStore",
                "VAUClient",
                "AVS",
                .product(name: "ASN1Kit", package: "ASN1Kit"),
                .product(name: "DataKit", package: "DataKit"),
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "ContentsquareModule", package: "CS_iOS_SDK"),
                .product(name: "Zxcvbn", package: "zxcvbn-ios"),
                .product(name: "GemCommonsKit", package: "ref-GemCommonsKit"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "ComposableCoreLocation", package: "composable-core-location"),
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
                .product(name: "Introspect", package: "SwiftUI-Introspect"),
                .product(name: "OpenSSL-Swift", package: "OpenSSL-Swift"),
                .product(name: "GemPDFKit", package: "swift-gemPDFKit"),
                .product(name: "ZXingObjC", package: "zxingify-objc"),
                .product(name: "HealthCardAccess", package: "ref-openhealthcardkit"),
                .product(name: "HealthCardControl", package: "ref-openhealthcardkit"),
                .product(name: "NFCCardReaderProvider", package: "ref-openhealthcardkit"),
                .product(name: "Helper", package: "ref-openhealthcardkit"),
            ],
            path: "Sources/eRpApp",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .unsafeFlags(["-enable-bare-slash-regex"]),
                .define("ENABLE_DEBUG_VIEW", .when(configuration: .debug)),
                .define("TEST_ENVIRONMENT", .when(configuration: .debug))
            ]
        ),
        .target(
            name: "eRpStyleKit",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "eRpKit",
            dependencies: [
                "IDP",
                "FHIRClient",
                .product(name: "OpenSSL-Swift", package: "OpenSSL-Swift"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
            ]
        ),
        .target(
            name: "eRpLocalStorage",
            dependencies: [
                "eRpKit",
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "GemCommonsKit", package: "ref-GemCommonsKit"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
            ],
            swiftSettings: [
                .define("ENABLE_DEBUG_VIEW", .when(configuration: .debug))
            ]
        ),
        .target(
            name: "eRpRemoteStorage",
            dependencies: [
                "HTTPClient",
                "FHIRClient",
                "eRpKit",
                .product(name: "ModelsR4", package: "FHIRModels"),
            ]
        ),
        .target(
            name: "Pharmacy",
            dependencies: [
                "HTTPClient",
                "FHIRClient",
                "eRpKit",
                .product(name: "DataKit", package: "DataKit"),
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "OpenSSL-Swift", package: "OpenSSL-Swift"),
            ]
        ),
        .target(
            name: "AVS",
            dependencies: [
                "HTTPClient",
                .product(name: "OpenSSL-Swift", package: "OpenSSL-Swift"),
                .product(name: "ASN1Kit", package: "ASN1Kit"),
            ]
        ),
        .target(
            name: "IDP",
            dependencies: [
                "HTTPClient",
                "TrustStore",
                .product(name: "ASN1Kit", package: "ASN1Kit"),
                .product(name: "DataKit", package: "DataKit"),
                .product(name: "GemCommonsKit", package: "ref-GemCommonsKit"),
                .product(name: "OpenSSL-Swift", package: "OpenSSL-Swift"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
            ]
        ),
        .target(
            name: "FHIRClient",
            dependencies: [
                "HTTPClient",
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
            ]
        ),
        .target(
            name: "HTTPClient",
            dependencies: [
                .product(name: "GemCommonsKit", package: "ref-GemCommonsKit"),
            ]
        ),
        .target(
            name: "TrustStore",
            dependencies: [
                "HTTPClient",
                .product(name: "DataKit", package: "DataKit"),
                .product(name: "OpenSSL-Swift", package: "OpenSSL-Swift"),
                .product(name: "GemCommonsKit", package: "ref-GemCommonsKit"),
            ]
        ),
        .target(
            name: "VAUClient",
            dependencies: [
                "HTTPClient",
                "TrustStore",
                .product(name: "DataKit", package: "DataKit"),
                .product(name: "OpenSSL-Swift", package: "OpenSSL-Swift"),
            ]
        ),
        .target(
            name: "TestUtils",
            dependencies: [
                "HTTPClient",
                "VAUClient",
                "IDP",
                "TrustStore",
                .product(name: "Nimble", package: "Nimble"),
                .product(name: "OpenSSL-Swift", package: "OpenSSL-Swift"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ]
        ),
        .testTarget(
            name: "eRpFeaturesTests",
            dependencies: [
                "eRpFeatures",
                "TestUtils",
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "Nimble", package: "Nimble"),
            ],
            path: "Tests/eRpAppTests",
            resources: [
                .copy("Resources/PDF.bundle")
            ]
        ),
        .testTarget(
            name: "eRpStyleKitTests",
            dependencies: [
                "eRpStyleKit",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
        .testTarget(
            name: "eRpKitTests",
            dependencies: [
                "eRpKit",
                "TestUtils",
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
        .testTarget(
            name: "eRpLocalStorageTests",
            dependencies: [
                "eRpLocalStorage",
                "eRpRemoteStorage",
                "TestUtils",
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
        .testTarget(
            name: "eRpRemoteStorageTests",
            dependencies: [
                "eRpRemoteStorage",
                "TestUtils",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "Nimble", package: "Nimble"),
                .product(name: "GemCommonsKit", package: "ref-GemCommonsKit"),
            ],
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "PharmacyTests",
            dependencies: [
                "TestUtils",
                "Pharmacy",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "Nimble", package: "Nimble"),
                .product(name: "GemCommonsKit", package: "ref-GemCommonsKit"),
            ],
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "AVSTests",
            dependencies: [
                "AVS",
                "TestUtils",
                .product(name: "DataKit", package: "DataKit"),
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
        .testTarget(
            name: "IDPTests",
            dependencies: [
                "IDP",
                "TestUtils",
                .product(name: "ASN1Kit", package: "ASN1Kit"),
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "Nimble", package: "Nimble"),
                .product(name: "GemCommonsKit", package: "ref-GemCommonsKit"),
            ],
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "FHIRClientTests",
            dependencies: [
                "FHIRClient",
                "TestUtils",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "Nimble", package: "Nimble"),
                .product(name: "GemCommonsKit", package: "ref-GemCommonsKit"),
            ],
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "HTTPClientTests",
            dependencies: [
                "HTTPClient",
                "TestUtils",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "Nimble", package: "Nimble"),
            ],
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "TrustStoreTests",
            dependencies: [
                "TrustStore",
                "TestUtils",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
                .product(name: "GemCommonsKit", package: "ref-GemCommonsKit"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "Nimble", package: "Nimble"),
            ],
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "VAUClientTests",
            dependencies: [
                "VAUClient",
                "TestUtils",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
    ]
)
