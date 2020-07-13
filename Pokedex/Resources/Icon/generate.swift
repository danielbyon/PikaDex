//
//  generate.swift
//
//  Created by Zac White.
//  Copyright © 2020 Velos Mobile LLC / https://velosmobile.com / All rights reserved.
//

import Foundation

func resetAssetStorage(at url: URL) {
    try? FileManager.default.removeItem(at: url)
    try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
}

func writeManifest(_ manifest: IconManifest, to url: URL) {
    let encoded = try! JSONEncoder().encode(manifest)
    try! encoded.write(to: url.appendingPathComponent("Contents.json"))
}

func renderAppIcon(assetCatalogURL: URL) {
    let iconSetURL = assetCatalogURL.appendingPathComponent("AppIcon.appiconset", isDirectory: true)
    resetAssetStorage(at: iconSetURL)

    let mobileSet = IconSet(idioms: [.iPhone, .iPad, .marketing], view: MobileIcon())
    try! mobileSet.write(to: iconSetURL)

    let macSet = IconSet(idioms: [.mac], view: MacIcon())
    try! macSet.write(to: iconSetURL)

    let iconManifest = IconManifest(images: mobileSet.images + macSet.images)
    writeManifest(iconManifest, to: iconSetURL)
}

func renderLaunchIcon(assetCatalogURL: URL) {
    let iconSetURL = assetCatalogURL.appendingPathComponent("LaunchIcon.imageset", isDirectory: true)
    resetAssetStorage(at: iconSetURL)

    let iconSet = IconSet(idioms: [.universal], view: LaunchIcon())
    try! iconSet.write(to: iconSetURL)

    let iconManifest = IconManifest(images: iconSet.images)
    writeManifest(iconManifest, to: iconSetURL)
}

let env = ProcessInfo.processInfo.environment

guard let deviceFamily = env["TARGETED_DEVICE_FAMILY"],
    let projectPath = env["PROJECT_DIR"],
    let project = env["PROJECT"] else {
        exit(1)
}

let assetCatalogURL = URL(fileURLWithPath: projectPath)
    .appendingPathComponent(project)
    .appendingPathComponent("Resources")
    .appendingPathComponent("Icon.xcassets")

renderAppIcon(assetCatalogURL: assetCatalogURL)
renderLaunchIcon(assetCatalogURL: assetCatalogURL)
