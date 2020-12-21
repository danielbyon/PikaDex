//
//  WidgetAdapter.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/19/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import UIKit
import Combine
import WidgetKit

final class WidgetAdapter {

    private let notificationCenter: NotificationCenter

    private var shouldPerformUpdate = false
    private var cancellables: Set<AnyCancellable> = []

    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
        notificationCenter.publisher(for: TeamBuilderViewModel.teamsUpdatedNotification)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.scheduleWidgetUpdate()
            }
            .store(in: &cancellables)
        notificationCenter.publisher(for: UIApplication.willResignActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.performWidgetUpdateIfNecessary()
            }
            .store(in: &cancellables)
    }

    private func scheduleWidgetUpdate() {
        shouldPerformUpdate = true
    }

    private func performWidgetUpdateIfNecessary() {
        guard shouldPerformUpdate else { return }
        WidgetCenter.shared.reloadTimelines(ofKind: "TeamWidget")
        shouldPerformUpdate = false
    }

}
