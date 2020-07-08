//
//  KeyboardObserver.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/7/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

public class KeyboardObserver: NSObject, ObservableObject, UIGestureRecognizerDelegate {

    @Published public private(set) var keyboardHeight: CGFloat = 0.0

    /// Space between keyboard and TextField or TextView
    private var spaceBetweenKeyboardAndInputField: CGFloat = 20.0

    private var actualKeyboardHeight: CGFloat?

    private var panRecognizer: UIPanGestureRecognizer?
    private var subscriptions = Set<AnyCancellable>()

    override init() {
        super.init()
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panRecognizer?.delegate = self
        UIApplication.shared.windows.first?.addGestureRecognizer(panRecognizer!)

        let keyboardWillShow = NotificationCenter
            .default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
            .eraseToAnyPublisher()

        let keyboardWillHide = NotificationCenter
            .default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0.0) }
            .eraseToAnyPublisher()

        keyboardWillShow.merge(with: keyboardWillHide)
            .sink { [weak self] height in
                self?.keyboardHeight = height
                self?.actualKeyboardHeight = height
        }
        .store(in: &subscriptions)

        NotificationCenter
            .default
            .publisher(for: UIResponder.keyboardDidShowNotification)
            .sink { [weak self] _ in
                self?.adjustScrollViewOffsetYIfPossible()
        }
        .store(in: &subscriptions)
    }

    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard case .changed = gestureRecognizer.state,
            let window = UIApplication.shared.windows.first,
            let actualKeyboardHeight = actualKeyboardHeight else {
                return
        }
        let originY = gestureRecognizer.location(in: window).y
        let screenHeight = UIScreen.main.bounds.height
        guard originY >= screenHeight - actualKeyboardHeight else {
            return
        }
        keyboardHeight = screenHeight - originY
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: gestureRecognizer.view)
        var view = gestureRecognizer.view?.hitTest(point, with: nil)
        while let candidate = view {
            if let scrollView = candidate as? UIScrollView {
                scrollView.keyboardDismissMode = .interactive
                return true
            }
            view = candidate.superview
        }
        return false
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureRecognizer === self.panRecognizer
    }

    private func adjustScrollViewOffsetYIfPossible() {
        let activeView: UIView?
        if let activeTextField = UIResponder.current() as? UITextField {
            activeView = activeTextField
        } else if let activeTextView = UIResponder.current() as? UITextView {
            activeView = activeTextView
        } else {
            return
        }

        guard let view = activeView else { return }

        // lookup for the parent scroll view
        var superview = view.superview
        var parentScrollView: UIScrollView?
        while superview != nil {
            if let _sv = superview as? UIScrollView {
                parentScrollView = _sv
                break
            }
            superview = superview?.superview
        }

        guard let scrollView = parentScrollView else { return }

        let targetFrame = view.convert(view.bounds, to: nil)
        let targetY = targetFrame.maxY
        let containerY = UIScreen.main.bounds.height - keyboardHeight

        if containerY < targetY {
            DispatchQueue.main.async {
                var newFrame = targetFrame
                newFrame.origin.y -= self.spaceBetweenKeyboardAndInputField
                scrollView.scrollRectToVisible(newFrame, animated: true)
            }
        }
    }

}

private extension UIResponder {

    private struct Static {
        static weak var responder: UIResponder?
    }

    static func current() -> UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.trap), to: nil, from: nil, for: nil)
        return Static.responder
    }

    @objc private func trap() {
        Static.responder = self
    }

}

