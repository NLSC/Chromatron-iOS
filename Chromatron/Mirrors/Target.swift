//
//  Reciver.swift
//  Chromatron
//
//  Created by SwanCurve on 03/20/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit

class Target: Responsible {
    var id: String
    var description: String {
        return "Target(id: \(id), require: \(require), location: \(location ?? .invalid))"
    }
    
    var view: UIView? {
        let v = TargetView()
        v.color = require.color
        return v
    } 
    
    var location: Point?
    
    var angle: Angle 
    
    var color: BeamColor = .NoColor
    
    var require: BeamColor
    
    private
    var _possibleResponses: [Vector]
    var possibleResponses: [Vector] {
        return _possibleResponses
    }
    
    func responses(for excitation: Vector) -> [Vector] {
        // reciver is certainly placed
        return []
//        return [Vector(location: location!, xBasis: excitation.xBasis, yBasis: excitation.yBasis)]
    }
    
    var light: Bool {
        guard require != .NoColor else {
            return true
        }
        return require == color
    }
    
    required convenience init() {
        self.init(location: .invalid)
    }
    
    init(location: Point, require: BeamColor = .NoColor, id: String = "") {
        self.angle = .deg0
        self.location = location
        self.require = require
        self.id = id
        _possibleResponses = [
            Vector(location: location, xBasis: -1, yBasis:  0),
            Vector(location: location, xBasis: -1, yBasis: -1),
            Vector(location: location, xBasis:  0, yBasis: -1),
            Vector(location: location, xBasis:  1, yBasis: -1),
            Vector(location: location, xBasis:  1, yBasis:  0),
            Vector(location: location, xBasis:  1, yBasis:  1),
            Vector(location: location, xBasis:  0, yBasis:  1),
            Vector(location: location, xBasis: -1, yBasis:  1),
        ]
    }
    
    func blend(_ color: BeamColor) {
        self.color += color
    }
}

extension Target: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return Target(location: self.location ?? .invalid, require: self.require, id: self.id)
    }
}

fileprivate
class TargetView: UIView {
    var color: UIColor = .white {
        didSet {
            background.backgroundColor = color
            setNeedsDisplay()
        }
    }
    
    let _mask = UIImageView(image: UIImage(named: "target"))
    let background = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        background.mask = _mask
        background.backgroundColor = color
        addSubview(background)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rect = CGRect(x: 8, y: 8, width: bounds.width - 16, height: bounds.height - 16)
        _mask.frame = CGRect(origin: .zero, size: rect.size)
        background.frame = rect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
