//
//  Conduits.swift
//  Chromatron
//
//  Created by SwanCurve on 03/20/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit

class Conduits: Responsible {
    var id: String
    var description: String {
        return "Conduits(id: \(id), angle: \(angle), location: \(location ?? .invalid))"
    }
    
    var icon: UIImageView {
        let img = UIImageView(image: UIImage(named: "conduits"))
        img.contentMode = .scaleAspectFit
        return img
    }
    
    var view: UIView? {
        let v = ConduitsView()
        v.rotate(angle: CGFloat(angle.rawValue))
        return v
    }
    
    var location: Point?
    
    var angle: Angle {
        didSet { updatePossibleResponses() }
    }
    
    var color: BeamColor = .NoColor
    
    private
    var _possibleResponses: [Vector] = []
    var possibleResponses: [Vector] {
        return _possibleResponses
    }
    
    required convenience init() {
        self.init(angle: .deg0, location: .invalid)
    }
    
    init(angle: Angle, location: Point, id: String = "") {
        self.angle = angle
        self.location = location
        self.id = id
    }
    
    func blend(_ color: BeamColor) {
        self.color += color
    }
}

extension Conduits: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return Conduits(angle: self.angle, location: self.location ?? .invalid, id: self.id)
    }
}

fileprivate
class ConduitsView: UIView {
    let img = UIImageView(image: UIImage(named: "conduits"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        img.contentMode = .scaleAspectFit
        addSubview(img)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        img.frame = CGRect(x: 8, y: 8, width: bounds.width - 16, height: bounds.height - 16)
    }
}


// MARK: respond table
extension Conduits {
    func responses(for excitation: Vector) -> [Vector] {
        var pass = false
        switch angle {
        case .deg0:     fallthrough
        case .deg180:
            if (excitation.xBasis == 1 || excitation.xBasis == -1) && excitation.yBasis == 0 {
                pass = true
            }
        case .deg45:    fallthrough
        case .deg225:
            if (excitation.xBasis == 1 && excitation.yBasis == 1) ||
                (excitation.xBasis == -1 && excitation.yBasis == -1) {
                pass = true
            }
        case .deg90:    fallthrough
        case .deg270:
            if (excitation.xBasis == 0) && (excitation.yBasis == 1 || excitation.yBasis == -1) {
                pass = true
            }
        case .deg135:   fallthrough
        case .deg315:
            if (excitation.xBasis == 1 && excitation.yBasis == -1) ||
                (excitation.xBasis == -1 && excitation.yBasis == 1) {
                pass = true
            }
        }
        
        if pass {
            return [Vector(location: location!, xBasis: excitation.xBasis, yBasis: excitation.yBasis)]
        }
        
        return []
    }
    
    private func updatePossibleResponses() {
        guard let location = location else {
            assert(false)
            popError(message: "\(#file).\(#line) #\(#function)")
            return
        }
        
        switch angle {
        case .deg0:     fallthrough
        case .deg180:
            _possibleResponses = [
                Vector(location: location, xBasis: 1, yBasis: 0),
                Vector(location: location, xBasis: -1, yBasis: 0)
            ]
        case .deg45:    fallthrough
        case .deg225:
            _possibleResponses = [
                Vector(location: location, xBasis: 1, yBasis: 1),
                Vector(location: location, xBasis: -1, yBasis: -1)
            ]
        case .deg90:    fallthrough
        case .deg270:
            _possibleResponses = [
                Vector(location: location, xBasis: 0, yBasis: 1),
                Vector(location: location, xBasis: 0, yBasis: -1)
            ]
        case .deg135:   fallthrough
        case .deg315:
            _possibleResponses = [
                Vector(location: location, xBasis: 1, yBasis: -1),
                Vector(location: location, xBasis: -1, yBasis: 1)
            ]
        }
    }
}
