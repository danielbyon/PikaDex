//
//  AnyScheduler+AppQueues.swift
//  
//
//  Created by Daniel Byon on 10/27/22.
//

import CombineSchedulers
import Foundation

extension AnyScheduler
where Self.SchedulerOptions == DispatchQueue.SchedulerOptions,
      Self.SchedulerTimeType == DispatchQueue.SchedulerTimeType {

    public static var appHighPriority: Self {
        DispatchQueue.appHighPriority.eraseToAnyScheduler()
    }

    public static var appProcessing: Self {
        DispatchQueue.appProcessing.eraseToAnyScheduler()
    }

    public static var appMaintenance: Self {
        DispatchQueue.appMaintenance.eraseToAnyScheduler()
    }

}
