//
//  main.swift
//  DatabaseValidator
//
//  Created by Daniel Byon on 12/4/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import CoreData
import Foundation

print("Hello, World!")

let container = Helper.loadContainer(removeExistingContainer: false)
let validator = Validator(container: container)
validator.validate()
