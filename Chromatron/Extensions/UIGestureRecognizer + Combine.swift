//
//  UIGestureRecognizer + Combine.swift
//  Chromatron
//
//  Created by SwanCurve on 03/26/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit
import Combine

// MARK: - Publisher
public extension Publishers {
    /// A publisher which wraps objects that use the Target & Action mechanism,
    /// for example - a UIBarButtonItem which isn't KVO-compliant and doesn't use UIControlEvent(s).
    ///
    /// Instead, you pass in a generic Control, and two functions:
    /// One to add a target action to the provided control, and a second one to
    /// remove a target action from a provided control.
    struct ControlTarget<Control: UIGestureRecognizer>: Publisher {
        public typealias Output = (gesture: Control,  state: UIGestureRecognizer.State)
        public typealias Failure = Never
        
        private let control: Control
        private let addTargetAction: (Control, AnyObject, Selector) -> Void
        private let removeTargetAction: (Control?, AnyObject, Selector) -> Void
        
        /// Initialize a publisher that emits a Void whenever the
        /// provided control fires an action.
        ///
        /// - parameter control: UI Control.
        /// - parameter addTargetAction: A function which accepts the Control, a Target and a Selector and
        ///                              responsible to add the target action to the provided control.
        /// - parameter removeTargetAction: A function which accepts the Control, a Target and a Selector and it
        ///                                 responsible to remove the target action from the provided control.
        public init(control: Control,
                    addTargetAction: @escaping (Control, AnyObject, Selector) -> Void,
                    removeTargetAction: @escaping (Control?, AnyObject, Selector) -> Void) {
            self.control = control
            self.addTargetAction = addTargetAction
            self.removeTargetAction = removeTargetAction
        }
        
        public func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            let subscription = Subscription(subscriber: subscriber,
                                            control: control,
                                            addTargetAction: addTargetAction,
                                            removeTargetAction: removeTargetAction)
            
            subscriber.receive(subscription: subscription)
        }
    }
}

// MARK: - Subscription
private extension Publishers.ControlTarget {
    private final class Subscription<S: Subscriber, Control: UIGestureRecognizer>: Combine.Subscription
    where S.Input == (gesture: Control, state: UIGestureRecognizer.State) {
        private var subscriber: S?
        weak private var control: Control?
        
        private let removeTargetAction: (Control?, AnyObject, Selector) -> Void
        private let action = #selector(handleAction)
        
        init(subscriber: S,
             control: Control,
             addTargetAction: @escaping (Control, AnyObject, Selector) -> Void,
             removeTargetAction: @escaping (Control?, AnyObject, Selector) -> Void) {
            self.subscriber = subscriber
            self.control = control
            self.removeTargetAction = removeTargetAction
            
            addTargetAction(control, self, action)
        }
        
        func request(_ demand: Subscribers.Demand) {
            // We don't care about the demand at this point.
            // As far as we're concerned - The control's target events are endless until it is deallocated.
        }
        
        func cancel() {
            subscriber = nil
            removeTargetAction(control, self, action)
        }
    
        @objc
        private func handleAction() {
            _ = subscriber?.receive((control!, control!.state))
        }
    }
}

// MARK: - Private Helpers

// A private generic helper function which returns the provided
// generic publisher whenever its specific event occurs.
private func gesturePublisher<Gesture: UIGestureRecognizer>(for gesture: Gesture) -> AnyPublisher<(gesture: Gesture, state: UIGestureRecognizer.State), Never> {
    Publishers.ControlTarget(control: gesture,
                             addTargetAction: { gesture, target, action in
                                gesture.addTarget(target, action: action)
                             },
                             removeTargetAction: { gesture, target, action in
                                gesture?.removeTarget(target, action: action)
                             })
//              .map { gesture }
              .eraseToAnyPublisher()
}

// MARK: - Gesture Publishers
public extension UITapGestureRecognizer {
    /// A publisher which emits when this Tap Gesture Recognizer is triggered
    var tapPublisher: AnyPublisher<(gesture: UITapGestureRecognizer, state: UIGestureRecognizer.State), Never> {
        gesturePublisher(for: self)
    }
}

public extension UILongPressGestureRecognizer {
    var publisher: AnyPublisher<(gesture: UILongPressGestureRecognizer, state: UIGestureRecognizer.State), Never> {
        gesturePublisher(for: self)
    }
}

public extension UIPanGestureRecognizer {
    /// A publisher which emits when this Pan Gesture Recognizer is triggered
    var panPublisher: AnyPublisher<(gesture: UIPanGestureRecognizer, state: UIGestureRecognizer.State), Never> {
        gesturePublisher(for: self)
    }
}
