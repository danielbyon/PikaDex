//
//  AppStorage+AppSetting.swift
//  
//
//  Created by Daniel Byon on 9/22/22.
//

import SwiftUI

extension AppStorage {

    // MARK: String

    public init(wrappedValue: Value, _ appSetting: AppSetting<Value>, store: UserDefaults? = .appGroup) where Value == String {
        self.init(wrappedValue: wrappedValue, appSetting.key, store: store)
    }

    public init(_ appSetting: AppSetting<Value>, store: UserDefaults? = .appGroup) where Value == String? {
        self.init(appSetting.key, store: store)
    }

    // MARK: RawRepresentable Int

    public init(wrappedValue: Value, _ appSetting: AppSetting<Value>, store: UserDefaults? = .appGroup) where Value: RawRepresentable, Value.RawValue == Int {
        self.init(wrappedValue: wrappedValue, appSetting.key, store: store)
    }

    public init<R>(_ appSetting: AppSetting<Value>, store: UserDefaults? = .appGroup) where Value == R?, R: RawRepresentable, R.RawValue == Int {
        self.init(appSetting.key, store: store)
    }

    // MARK: Data

    public init(wrappedValue: Value, _ appSetting: AppSetting<Value>, store: UserDefaults? = .appGroup) where Value == Data {
        self.init(wrappedValue: wrappedValue, appSetting.key, store: store)
    }

    public init(_ appSetting: AppSetting<Value>, store: UserDefaults? = .appGroup) where Value == Data? {
        self.init(appSetting.key, store: store)
    }

    // MARK: Int

    public init(wrappedValue: Value, _ appSetting: AppSetting<Value>, store: UserDefaults? = .appGroup) where Value == Int {
        self.init(wrappedValue: wrappedValue, appSetting.key, store: store)
    }

    public init(_ appSetting: AppSetting<Value>, store: UserDefaults? = .appGroup) where Value == Int? {
        self.init(appSetting.key, store: store)
    }

    // MARK: RawRepresentable String

    public init(wrappedValue: Value, _ appSetting: AppSetting<Value>, store: UserDefaults? = .appGroup) where Value: RawRepresentable, Value.RawValue == String {
        self.init(wrappedValue: wrappedValue, appSetting.key, store: store)
    }

    public init<R>(_ appSetting: AppSetting<Value>, store: UserDefaults? = .appGroup) where Value == R?, R: RawRepresentable, R.RawValue == String {
        self.init(appSetting.key, store: store)
    }

    // MARK: URL

    public init(wrappedValue: Value, _ appSetting: AppSetting<Value>, store: UserDefaults? = .appGroup) where Value == URL {
        self.init(wrappedValue: wrappedValue, appSetting.key, store: store)
    }

    public init(_ appSetting: AppSetting<Value>, store: UserDefaults? = .appGroup) where Value == URL? {
        self.init(appSetting.key, store: store)
    }

    // MARK: Double

    public init(wrappedValue: Value, _ appSetting: AppSetting<Value>, store: UserDefaults? = .appGroup) where Value == Double {
        self.init(wrappedValue: wrappedValue, appSetting.key, store: store)
    }

    public init(_ appSetting: AppSetting<Value>, store: UserDefaults? = .appGroup) where Value == Double? {
        self.init(appSetting.key, store: store)
    }

    // MARK: Bool

    public init(wrappedValue: Value, _ appSetting: AppSetting<Value>, store: UserDefaults? = .appGroup) where Value == Bool {
        self.init(wrappedValue: wrappedValue, appSetting.key, store: store)
    }

    public init(_ appSetting: AppSetting<Value>, store: UserDefaults? = .appGroup) where Value == Bool? {
        self.init(appSetting.key, store: store)
    }

}
