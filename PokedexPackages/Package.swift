// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var package = Package(
    name: "PokedexPackages",
    platforms: [.iOS(.v16), .macOS(.v13)],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "git@github.com:danielbyon/AppSupport.git", from: "0.1.0"),
        .package(url: "https://github.com/pointfreeco/combine-schedulers", from: "0.8.0")
    ]
)

var products: [Product] = []
var targets: [Target] = []

// MARK: Helper Functions

func addFeature(name: String) {
    let featureName = name + "Feature"
    products.append(
        .library(
            name: featureName,
            targets: [featureName]
        )
    )
    targets.append(contentsOf: [
        .target(
            name: featureName,
            dependencies: [
                "DesignSystem",
                "PokedexCore",
                "PokedexUI",
                .product(name: "CombineSchedulers", package: "combine-schedulers")
            ]
        ),
        .testTarget(
            name: featureName + "Tests",
            dependencies: [
                .target(name: featureName),
                .product(name: "CombineSchedulers", package: "combine-schedulers")
            ]
        ),
    ])
}

// MARK: - Foundational Modules

// MARK: DesignSystem
products.append(
    .library(
        name: "DesignSystem",
        targets: ["DesignSystem"]
    )
)
targets.append(contentsOf: [
    .target(
        name: "DesignSystem",
        dependencies: [
            "PokedexCore"
        ],
        resources: [
            .process("Resources"),
        ]
    ),
    .testTarget(
        name: "DesignSystemTests",
        dependencies: ["DesignSystem"]
    ),
])

// MARK: PokedexCore
products.append(
    .library(
        name: "PokedexCore",
        targets: ["PokedexCore"]
    )
)
targets.append(contentsOf: [
    .target(
        name: "PokedexCore",
        dependencies: [
            "AppSupport",
            .product(name: "CombineSchedulers", package: "combine-schedulers")
        ],
        resources: [
            .process("Resources")
        ]
    ),
    .testTarget(
        name: "PokedexCoreTests",
        dependencies: ["PokedexCore"]
    )
])

// MARK: PokedexUI
products.append(
    .library(
        name: "PokedexUI",
        targets: ["PokedexUI"]
    )
)
targets.append(contentsOf: [
    .target(
        name: "PokedexUI",
        dependencies: [
            "DesignSystem",
            "PokedexCore",
            .product(name: "CombineSchedulers", package: "combine-schedulers")
        ]
    ),
    .testTarget(
        name: "PokedexUITests",
        dependencies: ["PokedexUI"]
    ),
])

// MARK: - Feature Modules
[
    "Ability",
    "BattleAssistant",
    "DualType",
    "Item",
    "Location",
    "Machine",
    "Move",
    "Nature",
    "Pokemon",
    "Team",
    "Type"
]
    .forEach(addFeature)

package.products = products
package.targets = targets
