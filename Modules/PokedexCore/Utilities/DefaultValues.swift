//
//  DefaultValues.swift
//  Database
//
//  Created by Daniel Byon on 12/18/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Foundation

#if DEBUG
public let _missingString = "🤬 MISSING WTF 🤬"
#else
public let _missingString = ""
#endif

public let _missingInt = -1001
public let _missingInt32: Int32 = -1001
public let _missingInt64: Int64 = -1001
public let _missingDouble = -1001.0
