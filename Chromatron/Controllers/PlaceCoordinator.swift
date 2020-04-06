//
//  PlaceCoordinator.swift
//  Chromatron
//
//  Created by SwanCurve on 04/01/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit
import Combine

struct PlaceCoordinator {
    private weak var container: MainController!
    private weak var content: ViewController!
    private weak var panel: PanelController!
    
    private var _context: PlaceData?
    var context: PlaceData? {
        set {
            _context = newValue
            try! updateViews()
        }
        get {
            _context
        }
    }
    
    var collector: Set<AnyCancellable> = []
    
    init(container: MainController, content: ViewController, panel: PanelController) {
        self.container = container
        self.content = content
        self.panel = panel
    }
    
    private func updateViews() throws {
        guard let context = context else {
            throw GlobalError.impossibleError
        }
        
        container.view.addSubview(context.view)
    }
    
    func gestureChanged(_ gesture: UILongPressGestureRecognizer) throws {
        guard context != nil else {
            throw GlobalError.impossibleError
        }
        
        let location = gesture.location(in: container.view)
        if content.view.frame.contains(location) {
            content.hovering(gesture)
        }

        if let loc = content.convertIndicatorLocationFrom(content.view.convert(location, from: container.view)) {            
            context!.view.center = loc
            if context!.view.isHidden {
                context!.view.isHidden = false
            }
        } else {
            context!.view.isHidden = true
        }
        
//        Swift.print("changed: \(location)")
    }
    
    private mutating func sweep() {
        collector.removeAll()
        _context = nil
    }
    
    mutating func placeCancelled(_ gesture: UILongPressGestureRecognizer) throws {
        guard context != nil else {
            throw GlobalError.impossibleError
        }
        defer {
            sweep()
        }
//        Swift.print("place cancelled")
        context?.view.removeFromSuperview()
        
        panel.placeCancelled()
        content.placeCancelled()
    }
    
    mutating func placeEnd(_ gesture: UILongPressGestureRecognizer) throws {
        // placeEnd may call more than once
        guard context != nil else {
            throw GlobalError.impossibleError
        }
        defer {
            sweep()
        }
        
        context?.view.removeFromSuperview()
        
        let location = gesture.location(in: container.view)
        
        if content.placeAvailable(content.view.convert(location, from: container.view)) {
            content.place(item: context!.type, at: content.view.convert(location, from: container.view))
//            Swift.print("place end")
        } else if panel.placeAvailable(panel.view.convert(location, from: container.view)) {
            panel.recycleItem(context!.type)
//            Swift.print("recycle item")
        } else {
            content.placeCancelled()
            panel.placeCancelled()
//            Swift.print("place empty")
        }
        
        panel.placeEnd()
        content.placeEnd()
    }
}
