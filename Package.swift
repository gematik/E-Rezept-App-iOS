// swift-tools-version:5.9
//
//  Copyright (Change Date see Readme), gematik GmbH
//
//  Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the
//  European Commission – subsequent versions of the EUPL (the "Licence").
//  You may not use this work except in compliance with the Licence.
//
//  You find a copy of the Licence in the "Licence" file or at
//  https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Licence is distributed on an "AS IS" basis,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either expressed or implied.
//  In case of changes by gematik find details in the "Readme" file.
//
//  See the Licence for the specific language governing permissions and limitations under the Licence.
//
//  *******
//
// For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
//

import PackageDescription

let package = Package(
    name: "eRpKit",
    defaultLocalization: "de",
    platforms: [
        .iOS(.v17), .macOS(.v13)
    ],
    products: [
        .library(name: "eRpFeatures", targets: ["eRpFeatures"]),
        .library(name: "AsyncHelpers", targets: ["AsyncHelpers"]),
        .library(name: "FeatureCardWall", targets: ["FeatureCardWall"]),
        .library(name: "FeatureCommunication", targets: ["FeatureCommunication"]),
        .library(name: "FeatureEURedeem", targets: ["FeatureEURedeem"]),
        .library(name: "FeatureHelpers", targets: ["FeatureHelpers"]),
        .library(name: "eRpStyleKit", targets: ["eRpStyleKit"]),
        .library(name: "eRpResources", targets: ["eRpResources"]),
        .library(name: "eRpKit", targets: ["eRpKit"]),
        .library(name: "eRpLocalStorage", targets: ["eRpLocalStorage"]),
        .library(name: "eRpRemoteStorage", targets: ["eRpRemoteStorage"]),
        .library(name: "ErxTaskRepository", targets: ["ErxTaskRepository"]),
        .library(name: "Pharmacy", targets: ["Pharmacy"]),
        .library(name: "FHIRVZD", targets: ["FHIRVZD"]),
        .library(name: "FHIRVZDLive", targets: ["FHIRVZDLive"]),
        .library(name: "BfArM", targets: ["BfArM"]),
        .library(name: "BfArMLive", targets: ["BfArMLive"]),
        .library(name: "IDP", targets: ["IDP"]),
        .library(name: "IDPLive", targets: ["IDPLive"]),
        .library(name: "FHIRClient", targets: ["FHIRClient"]),
        .library(name: "HTTPClient", targets: ["HTTPClient"]),
        .library(name: "HTTPClientLive", targets: ["HTTPClientLive"]),
        .library(name: "TestUtils", targets: ["TestUtils"]),
        .library(name: "TrustStore", targets: ["TrustStore"]),
        .library(name: "VAUClient", targets: ["VAUClient"]),
        .library(name: "Profiles", targets: ["Profiles"]),
        .library(name: "Settings", targets: ["Settings"]),
        .library(name: "ConsentService", targets: ["ConsentService"]),
        .library(name: "PushNotificationCrypto", targets: ["PushNotificationCrypto"])
    ],
    dependencies: [
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs", from: "9.1.0"),
        .package(url: "https://github.com/andyjohns/zxcvbn-ios", revision: "bf6083dc17df950c8bdfcf2063859ee1270015fd"),
        .package(url: "https://github.com/apple/FHIRModels", from: "0.9.3"),
        .package(url: "https://github.com/pointfreeco/combine-schedulers", from: "1.2.0"),
        .package(url: "https://github.com/rcasula/composable-core-location", revision: "0f3651bdaf95fcc44acef7de7d9aab0395cc2678"),
        .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.8.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.26.0"),
        .package(url: "https://github.com/pointfreeco/swift-clocks", from: "1.1.0"),
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.4.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.6.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.14.1"),
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.1.1"),
        .package(url: "https://github.com/pointfreeco/swift-sharing", from: "2.9.1"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.2"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.10.1"),
        .package(url: "https://github.com/Quick/Nimble", from: "14.0.0"),
        .package(url: "https://github.com/siteline/swiftui-introspect", from: "26.0.1"),
        .package(url: "https://github.com/zxing-cpp/zxing-cpp", from: "3.1.0"),
        .package(url: "https://github.com/gematik/ASN1Kit", from: "1.3.1"),
        .package(url: "https://github.com/gematik/OpenSSL-Swift", from: "4.6.1"),
        .package(url: "https://github.com/gematik/swift-gemPDFKit", from: "0.2.2"),
        .package(url: "https://github.com/gematik/ref-OpenHealthCardKit", from: "5.11.2"),
        .package(url: "https://github.com/apple/swift-asn1.git", .upToNextMajor(from: "1.7.1")),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.1.5"),
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2"),
        .package(path: "CodedError"), // local package, will be moved to separate repo
    ],
    targets: [
        .target(
            name: "eRpFeatures",
            dependencies: [
                "eRpStyleKit",
                "eRpRemoteStorage",
                "eRpKit",
                "eRpLocalStorage",
                "ErxTaskRepository",
                "Pharmacy",
                "FHIRVZD",
                "FHIRVZDLive",
                "BfArM",
                "BfArMLive",
                "IDP",
                "IDPLive",
                "HTTPClient",
                "HTTPClientLive",
                "FHIRClient",
                "TrustStore",
                "VAUClient",
                "FeatureCardWall",
                "FeatureCommunication",
                "FeatureEURedeem",
                "FeatureHelpers",
                "AsyncHelpers",
                "Settings",
                "Profiles",
                "ConsentService",
                "PushNotificationCrypto",
                .product(name: "CodedError", package: "CodedError"),
                .product(name: "ASN1Kit", package: "ASN1Kit"),
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "Zxcvbn", package: "zxcvbn-ios"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "ComposableCoreLocation", package: "composable-core-location"),
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
                .product(name: "OpenSSL-Swift", package: "OpenSSL-Swift"),
                .product(name: "GemPDFKit", package: "swift-gemPDFKit"),
                .product(name: "ZXingCpp", package: "zxing-cpp"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Sharing", package: "swift-sharing"),
            ],
            path: "Sources/eRpApp",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .unsafeFlags(["-enable-bare-slash-regex"]),
                .define("ENABLE_DEBUG_VIEW", .when(configuration: .debug)),
                .define("TEST_ENVIRONMENT", .when(configuration: .debug)),
                .enableUpcomingFeature("InferSendableFromCaptures"),
            ]
        ),
        .target(
            name: "FeatureCardWall",
            dependencies: [
                "eRpStyleKit",
                "eRpKit",
                "Profiles",
                "Settings",
                "IDPLive", // currently needed for X509 + JWTSignatureVerifier
                "FeatureHelpers",
                .product(name: "HealthCardAccess", package: "ref-openhealthcardkit"),
                .product(name: "HealthCardControl", package: "ref-openhealthcardkit"),
                .product(name: "NFCCardReaderProvider", package: "ref-openhealthcardkit"),
                .product(name: "Helper", package: "ref-openhealthcardkit"),
                .product(name: "CodedError", package: "CodedError"),
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
            ],
            path: "Sources/FeatureCardWall",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("InferSendableFromCaptures"),
            ]
        ),
        .target(
            name: "FeatureCommunication",
            dependencies: [
                "eRpStyleKit",
                "eRpKit",
                "Profiles",
                "Settings",
                "FeatureHelpers",
                "ErxTaskRepository",
                .product(name: "CodedError", package: "CodedError"),
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
            ],
            path: "Sources/FeatureCommunication",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "FeatureEURedeem",
            dependencies: [
                "ConsentService",
                "eRpStyleKit",
                "eRpKit",
                "ErxTaskRepository",
                "FeatureCardWall",
                "Pharmacy",
                "FeatureHelpers",
                "Profiles",
                .product(name: "CodedError", package: "CodedError"),
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ComposableCoreLocation", package: "composable-core-location"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
                .product(name: "ZXingCpp", package: "zxing-cpp"),
            ],
            path: "Sources/FeatureEURedeem",
            swiftSettings: [
                .enableUpcomingFeature("InferSendableFromCaptures"),
            ]
        ),
        .target(
            name: "FeatureHelpers",
            dependencies: [
                "eRpStyleKit",
                "AsyncHelpers",
                "eRpKit",
                .product(name: "CodedError", package: "CodedError"),
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
            path: "Sources/FeatureHelpers",
            swiftSettings: [
                .enableUpcomingFeature("InferSendableFromCaptures"),
            ]
        ),
        .target(
            name: "AsyncHelpers",
            dependencies: [
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "Clocks", package: "swift-clocks"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
            path: "Sources/AsyncHelpers"
        ),
        .plugin(
            name: "ErpAppPlugin",
            capability: .buildTool(),
            dependencies: ["EnvironmentParser"]
        ),
        .executableTarget(
            name: "EnvironmentParser"
        ),
        .target(
            name: "ErxTaskRepository",
            dependencies: [
                "FHIRClient",
                "eRpKit",
                .product(name: "CodedError", package: "CodedError"),
                .product(name: "OpenSSL-Swift", package: "OpenSSL-Swift"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "eRpStyleKit",
            dependencies: [
                "eRpResources",
                .product(name: "Sharing", package: "swift-sharing"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "eRpResources",
            dependencies: [],
            resources: [
                .process("Resources")
            ],
            plugins: [
              .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
            ]
        ),
        .target(
            name: "eRpKit",
            dependencies: [
                "IDP",
                "FHIRClient",
                .product(name: "CodedError", package: "CodedError"),
                .product(name: "OpenSSL-Swift", package: "OpenSSL-Swift"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
            ]
        ),
        .target(
            name: "eRpLocalStorage",
            dependencies: [
                "eRpKit",
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "Sharing", package: "swift-sharing"),
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
                .product(name: "CodedError", package: "CodedError"),
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "Sharing", package: "swift-sharing"),
            ]
        ),
        .target(
            name: "Pharmacy",
            dependencies: [
                "FHIRClient",
                "eRpKit",
                .product(name: "CodedError", package: "CodedError"),
                .product(name: "OpenSSL-Swift", package: "OpenSSL-Swift"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "FHIRVZD",
            dependencies: [
                "Pharmacy",
                "FHIRClient",
                "eRpKit",
                "IDP",
                .product(name: "CodedError", package: "CodedError"),
                // change to swift-sharing & dependencies after TCA update
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "OpenSSL-Swift", package: "OpenSSL-Swift"),
            ]
        ),
        .target(
            name: "FHIRVZDLive",
            dependencies: [
                "FHIRVZD",
                "HTTPClientLive",
                // change to swift-sharing & dependencies after TCA update
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "BfArM",
            dependencies: [
                "eRpKit",
                .product(name: "CodedError", package: "CodedError"),
                // change to swift-sharing & dependencies after TCA update
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "BfArMLive",
            dependencies: [
                "BfArM",
                "HTTPClientLive",
            ]
        ),
        .target(
            name: "IDP",
            dependencies: [
                "eRpResources",
                "AsyncHelpers",
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "Clocks", package: "swift-clocks"),
                .product(name: "CodedError", package: "CodedError"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "OpenSSL-Swift", package: "OpenSSL-Swift"),
            ]
        ),
        .target(
            name: "IDPLive",
            dependencies: [
                "HTTPClient",
                "IDP",
                "TrustStore",
                "AsyncHelpers",
                .product(name: "Clocks", package: "swift-clocks"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "CodedError", package: "CodedError"),
                .product(name: "ASN1Kit", package: "ASN1Kit"),
            ]
        ),
        .target(
            name: "FHIRClient",
            dependencies: [
                "AsyncHelpers",
                "HTTPClient",
                .product(name: "ModelsR4", package: "FHIRModels"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
            ]
        ),
        .target(
            name: "HTTPClient",
            dependencies:  [
                .product(name: "CodedError", package: "CodedError"),
            ]
        ),
        .target(
            name: "HTTPClientLive",
            dependencies: [
                "HTTPClient",
            ]
        ),
        .target(
            name: "TrustStore",
            dependencies: [
                "HTTPClient",
                .product(name: "CodedError", package: "CodedError"),
                .product(name: "OpenSSL-Swift", package: "OpenSSL-Swift"),
                .product(name: "SwiftASN1", package: "swift-asn1"),
            ]
        ),
        .target(
            name: "VAUClient",
            dependencies: [
                .product(name: "CasePaths", package: "swift-case-paths"),
                "HTTPClient",
                "TrustStore",
                "AsyncHelpers",
                .product(name: "Clocks", package: "swift-clocks"),
                .product(name: "CodedError", package: "CodedError"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "OpenSSL-Swift", package: "OpenSSL-Swift"),
            ]
        ),
        .target(
            name: "TestUtils",
            dependencies: [
                "HTTPClient",
                "VAUClient",
                "IDP",
                "IDPLive",
                "TrustStore",
                .product(name: "Nimble", package: "Nimble"),
                .product(name: "OpenSSL-Swift", package: "OpenSSL-Swift"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "CustomDump", package: "swift-custom-dump"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
        .target(
            name: "Profiles",
            dependencies: [
                "IDP",
                "eRpKit",
                "eRpLocalStorage",
                "VAUClient",
                "TrustStore",
                "Pharmacy",
                "eRpRemoteStorage",
                .product(name: "CodedError", package: "CodedError"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies")
            ]
        ),
        .target(
            name: "Settings",
            dependencies: [
                "eRpKit",
                "eRpRemoteStorage",
                "IDP",
                "TrustStore",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "Sharing", package: "swift-sharing"),
            ],
            swiftSettings: [
                .define("ENABLE_DEBUG_VIEW", .when(configuration: .debug)),
                .define("TEST_ENVIRONMENT", .when(configuration: .debug)),
            ],
            plugins: [
                .plugin(name: "ErpAppPlugin"),
            ]
        ),
        .target(
            name: "ConsentService",
            dependencies: [
                "eRpKit",
                "eRpLocalStorage",
                "FeatureCardWall",
                "FeatureHelpers",
                .product(name: "CodedError", package: "CodedError"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "Sharing", package: "swift-sharing"),
            ]
        ),
        .target(
            name: "PushNotificationCrypto",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "CodedError", package: "CodedError"),
            ]
        ),
        .testTarget(
            name: "PushNotificationCryptoTests",
            dependencies: [
                "PushNotificationCrypto",
                .product(name: "Dependencies", package: "swift-dependencies"),
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
                .copy("Resources/PDF.bundle"),
                .copy("Resources/JWT.bundle")
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
                "HTTPClientLive",
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
            name: "ErxTaskRepositoryTests",
            dependencies: [
                "ErxTaskRepository",
                "TestUtils",
                "eRpKit",
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
        .testTarget(
            name: "PharmacyTests",
            dependencies: [
                "HTTPClientLive",
                "TestUtils",
                "Pharmacy",
                "FHIRVZD",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "Nimble", package: "Nimble"),
            ],
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "FHIRVZDTests",
            dependencies: [
                "TestUtils",
                "FHIRVZD",
                "Pharmacy",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "Nimble", package: "Nimble"),
            ],
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "IDPTests",
            dependencies: [
                "HTTPClientLive",
                "IDP",
                "TestUtils",
                .product(name: "ASN1Kit", package: "ASN1Kit"),
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "Nimble", package: "Nimble"),
            ],
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "IDPLiveTests",
            dependencies: [
                "HTTPClientLive",
                "IDP",
                "IDPLive",
                "TestUtils",
                .product(name: "ASN1Kit", package: "ASN1Kit"),
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "Nimble", package: "Nimble"),
            ],
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "FHIRClientTests",
            dependencies: [
                "FHIRClient",
                "HTTPClientLive",
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
            name: "HTTPClientLiveTests",
            dependencies: [
                "HTTPClient",
                "HTTPClientLive",
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
                "HTTPClientLive",
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
            name: "VAUClientTests",
            dependencies: [
                "VAUClient",
                "TestUtils",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
        .testTarget(
            name: "AsyncHelpersTests",
            dependencies: [
                "AsyncHelpers",
                "TestUtils",
                .product(name: "Nimble", package: "Nimble"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
            ]
        ),
        .testTarget(
            name: "FeatureCardWallTests",
            dependencies: [
                "FeatureCardWall",
                "TestUtils",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "Nimble", package: "Nimble"),
            ],
            resources: [
                .copy("Resources/JWT.bundle")
            ]
        ),
        .testTarget(
            name: "FeatureCommunicationTests",
            dependencies: [
                "FeatureCommunication",
                "TestUtils",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "Nimble", package: "Nimble"),
            ],
            resources: [
            ]
        ),
        .testTarget(
            name: "FeatureEURedeemTests",
            dependencies: [
                "FeatureEURedeem",
                "TestUtils",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "Nimble", package: "Nimble"),
            ],
            resources: [
            ]
        )
    ]
)
