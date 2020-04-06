//
//  Generator.swift
//  Chromatron
//
//  Created by SwanCurve on 03/20/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit

class Laser: Excitator {
    
    var color: BeamColor
    
    var icon: UIImageView {
        let img = UIImageView(image: UIImage(named: "laser"))
        img.contentMode = .scaleAspectFit
        return img
    }
    
    var view: UIView? {
        let v = LaserView()
        v.color = color.color
        v.rotate(angle: CGFloat(angle.rawValue))
        return v
    }
    
    var id: String
    var description: String {
        return "Laser(id: \(id), angle: \(angle), location: \(location ?? .invalid), color: \(color))"
    }
    
    var excitation: Vector = .zero
    
    var location: Point?
    
    var angle: Angle {
        didSet { try! updataPossibleResponse() }
    }
    
    var possibleResponses: [Vector] = []
    
    func responses(for excitation: Vector) -> [Vector] {
        return []
    }
    
    required convenience init() {
        self.init(angle: .deg0, location: .invalid, color: .NoColor)
    }
    
    init(angle: Angle, location: Point, color: BeamColor, id: String = "") {
        self.angle = angle
        self.location = location
        self.id = id
        self.color = color
        
        try! updataPossibleResponse()
    }
}

extension Laser: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return Laser(angle: self.angle, location: self.location ?? .invalid, color: self.color, id: self.id)
    }
}

fileprivate
class LaserView: UIView {
    var color: UIColor = .white {
        didSet { setNeedsDisplay() }
    }
    
    private
    let img: UIImageView
    override init(frame: CGRect) {
        img = UIImageView(image: UIImage(named: "laser"))
        img.contentMode = .scaleAspectFit

        super.init(frame: frame)
        
        isOpaque = false
        addSubview(img)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        img.frame = CGRect(x: 4, y: 4, width: bounds.width - 8, height: bounds.height - 8)
    }
    
    required init?(coder: NSCoder) {
        img = UIImageView(image: UIImage(named: "laser"))
        img.contentMode = .scaleAspectFit
        
        super.init(coder: coder)
        addSubview(img)
    }
    
    override func draw(_ rect: CGRect) {
        let r = CGRect(x: rect.width * 0.1,
                       y: rect.height * 0.35,
                       width: rect.width * 0.8,
                       height: rect.height * 0.3)
        color.setFill()
        UIRectFill(r)
    }
}

extension Laser {
    func updataPossibleResponse() throws {
        guard let location = location else {
            throw GlobalError.impossibleError
        }
        var excitation: Vector?
        switch angle {
        case .deg0:     excitation = Vector(location: location, xBasis:  1, yBasis:  0)
        case .deg45:    excitation = Vector(location: location, xBasis:  1, yBasis:  1)
        case .deg90:    excitation = Vector(location: location, xBasis:  0, yBasis:  1)
        case .deg135:   excitation = Vector(location: location, xBasis: -1, yBasis:  1)
        case .deg180:   excitation = Vector(location: location, xBasis: -1, yBasis:  0)
        case .deg225:   excitation = Vector(location: location, xBasis: -1, yBasis: -1)
        case .deg270:   excitation = Vector(location: location, xBasis:  0, yBasis: -1)
        case .deg315:   excitation = Vector(location: location, xBasis:  1, yBasis: -1)
        }
        self.excitation = excitation!
        self.possibleResponses = [self.excitation]
    }
}
