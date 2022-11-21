//
//  Persistable.swift
//  
//
//  Created by Daniel Byon on 11/4/22.
//

import CoreData
import Foundation

public protocol Persistable {

    associatedtype ModelType: NSManagedObject

    func makeModelObject(context: NSManagedObjectContext) -> ModelType

}
