//
//  Helpers.swift
//  DatabaseLoader
//
//  Created by Daniel Byon on 1/3/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData
import PokedexCore

// MARK: Global Helpers
let validNameCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "♂♀"))
func sanitizedName(_ name: String) -> String {
    String(name.lowercased().unicodeScalars.filter { validNameCharacters.contains($0) })
}
func sanitizedItemName(_ name: String) -> String {
    sanitizedName(name)
}
func sanitizedMoveName(_ moveName: String) -> String {
    var sanitized = sanitizedName(moveName)
    if sanitized == "faintattack" {
        sanitized = "feintattack"
    } else if sanitized == "hijumpkick" {
        sanitized = "highjumpkick"
    } else if sanitized == "smellingsalt" {
        sanitized = "smellingsalts"
    } else if sanitized == "vicegrip" {
        sanitized = "visegrip"
    }
    return sanitized
}

// MARK: - Core Data
private class PersistentContainer: NSPersistentContainer {

    override class func defaultDirectoryURL() -> URL {
        let configURL = Bundle.main.url(forResource: "Config", withExtension: "txt")!
        let config = try! String(contentsOf: configURL, encoding: .utf8).replacingOccurrences(of: "\n", with: "")
        let directoryURL = URL(fileURLWithPath: config, isDirectory: true).appendingPathComponent("Modules/PokedexCore/Resources/Database", isDirectory: true)
        try! FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        return directoryURL
    }

}

enum Helper {

    static func loadContainer(removeExistingContainer: Bool = true) -> NSPersistentContainer {
        let model = NSManagedObjectModel(contentsOf: Bundle.pokedexCore.url(forResource: "Pokedex", withExtension: "momd")!)!
        var container = PersistentContainer(name: "Pokedex", managedObjectModel: model)

        if removeExistingContainer {
            let url = container.persistentStoreDescriptions.first!.url!
            try! container.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
            container = PersistentContainer(name: "Pokedex", managedObjectModel: model)
        }

        container.loadPersistentStores { (description, error) in
            print(description.configuration ?? "")
            print(description.options)
            print(description.type)
            print(description.url?.absoluteString ?? "")
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
        return container
    }

    static func loadJSONData(from filename: String) -> Data {
        let fileURL = Bundle.main.url(forResource: filename, withExtension: nil)!
        let data = try! Data(contentsOf: fileURL)
        return data
    }

    static func loadJSON(from filename: String) -> Any {
        let data = loadJSONData(from: filename)
        let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
        return json
    }

    static func loadTSV(from filename: String) -> [[String: String]] {
        let delimiter = "\t"

        func sanitizeLine(_ line: String) -> String {
            line
//            return line.replacingOccurrences(of: "\",\"", with: delimiter)
//                .replacingOccurrences(of: ",\"", with: delimiter)
//                .replacingOccurrences(of: "\",", with: delimiter)
//                .replacingOccurrences(of: ",", with: delimiter)
//                .replacingOccurrences(of: "\"", with: "")
        }

        let fileURL = Bundle.main.url(forResource: filename, withExtension: nil)!
        let file = try! String(contentsOf: fileURL)

        let lines = file.replacingOccurrences(of: "\r", with: "\n").replacingOccurrences(of: "\n\n", with: "\n").components(separatedBy: .newlines)
        assert(lines.count > 1)

        var retVal = [[String: String]]()
        retVal.reserveCapacity(lines.count)

        let header = sanitizeLine(lines[lines.startIndex]).components(separatedBy: delimiter)
        for i in lines.startIndex.advanced(by: 1)..<lines.count {
            let line = sanitizeLine(lines[i])
            guard line != "" else { continue }
            let components = line.components(separatedBy: delimiter)

            assert(components.count == header.count)

            var dict = [String: String]()
            zip(header, components).forEach { dict[$0.0] = $0.1 }
            retVal.append(dict)
        }

        return retVal
    }

    static func loadExternalLinksTSV(from filename: String) -> [String: [String: String]] {
        let file = Helper.loadTSV(from: filename)
        var retVal: [String: [String: String]] = [:]
        for dict in file {
            let name = dict["name"]!
            retVal[sanitizedMoveName(name)] = dict
        }
        return retVal
    }

    static func sanitizedURL(from string: String) -> URL? {
        let sanitized = string.replacingOccurrences(of: "\"", with: "")
        let components = URLComponents(string: sanitized)
        return components?.url
    }

}

extension String {

    func removingQuotes() -> String {
        self.replacingOccurrences(of: "\"", with: "")
    }

    mutating func removeQuotes() {
        self = self.removingQuotes()
    }

    func removingDiacritics() -> String {
        folding(options: .diacriticInsensitive, locale: .current)
    }

}
