//
//  AppGroupStorage.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/24/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import AppSupport

@propertyWrapper
public struct AppGroupStorage<Value>: DynamicProperty where Value: UserDefaultPersistable {

    @AppStorage var storedValue: Data?

    public let key: String
    public let defaultValue: Value

    public var wrappedValue: Value {
        get {
            guard let data = storedValue else { return defaultValue }
            do {
                return try JSONDecoder().decode(Value.self, from: data)
            } catch {
                return defaultValue
            }
        }
        nonmutating set {
            let data = try? JSONEncoder().encode(newValue)
            storedValue = data
        }
    }

    public init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
        self._storedValue = .init(key, store: .appGroup)
    }

    public init(wrappedValue: Value, key: String, defaultValue: Value) {
        self.init(key: key, defaultValue: defaultValue)
        self.wrappedValue = wrappedValue
    }

    public init(key: String) where Value: DefaultValueProviding {
        self.init(key: key, defaultValue: Value.defaultValue)
    }

    public init(wrappedValue: Value, key: String) where Value: DefaultValueProviding {
        self.init(wrappedValue: wrappedValue, key: key, defaultValue: Value.defaultValue)
    }

}

public protocol DefaultValueProviding {

    static var defaultValue: Self { get }

}

extension Bool: DefaultValueProviding {

    public static var defaultValue: Bool { false }

}

extension CGFloat: DefaultValueProviding {

    public static var defaultValue: CGFloat { 0.0 }

}

extension Double: DefaultValueProviding {

    public static var defaultValue: Double { 0.0 }

}

extension Int: DefaultValueProviding {

    public static var defaultValue: Int { 0 }

}

extension Int8: DefaultValueProviding {

    public static var defaultValue: Int8 { 0 }

}

extension Int16: DefaultValueProviding {

    public static var defaultValue: Int16 { 0 }

}

extension Int32: DefaultValueProviding {

    public static var defaultValue: Int32 { 0 }

}

extension Int64: DefaultValueProviding {

    public static var defaultValue: Int64 { 0 }

}

extension Optional: DefaultValueProviding {

    public static var defaultValue: Optional<Wrapped> { .none }

}
