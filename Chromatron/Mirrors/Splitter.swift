//
//  Splitter.swift
//  Chromatron
//
//  Created by SwanCurve on 03/20/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit

class Splitter: Responsible {
    var id: String
    
    var description: String {
        return "Splitter(id: \(id), angle: \(angle), location: \(location ?? .invalid))"
    }
    
    var icon: UIImageView {
        let img = UIImageView(image: UIImage(named: "splitter"))
        img.contentMode = .scaleAspectFit
        return img
    }
    
    var view: UIView? {
        let v = SplitterView()
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
        
        updatePossibleResponses()
    }
    
    func blend(_ color: BeamColor) {
        self.color += color
    }
}

extension Splitter: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return Splitter(angle: self.angle, location: self.location ?? .invalid, id: self.id)
    }
}

fileprivate
class SplitterView: UIView {
    let img = UIImageView(image: UIImage(named: "splitter"))
    
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
extension Splitter {
    func responses(for excitation: Vector) -> [Vector] {
        guard let location = self.location else {
            return []
        }
        
        let input = (excitation.xBasis, excitation.yBasis)
        
        switch angle {
        case .deg0:     fallthrough
        case .deg180:
            if input == (-1, -1) {
                return [
                    Vector(location: location, xBasis: -1, yBasis: -1),
                    Vector(location: location, xBasis: -1, yBasis: 1)
                ]
            } else if input == (0, -1) {
                return [
                    Vector(location: location, xBasis: 0, yBasis: -1)
                ]
            } else if input == (1, -1) {
                return [
                    Vector(location: location, xBasis: 1, yBasis: -1),
                    Vector(location: location, xBasis: 1, yBasis: 1)
                ]
            } else if input == (1, 1) {
                return [
                    Vector(location: location, xBasis: 1, yBasis: 1),
                    Vector(location: location, xBasis: 1, yBasis: -1)
                ]
            } else if input == (0, 1) {
                return [
                    Vector(location: location, xBasis: 0, yBasis: 1)
                ]
            } else if input == (-1, 1) {
                return [
                    Vector(location: location, xBasis: -1, yBasis: 1),
                    Vector(location: location, xBasis: -1, yBasis: -1)
                ]
            }
        case .deg45:    fallthrough
        case .deg225:
            if input == (-1, 0) {
                return [
                    Vector(location: location, xBasis: -1, yBasis: 0),
                    Vector(location: location, xBasis: 0, yBasis: -1)
                ]
            } else if input == (0, -1) {
                return [
                    Vector(location: location, xBasis: 0, yBasis: -1),
                    Vector(location: location, xBasis: -1, yBasis: 0)
                ]
            } else if input == (1, -1) {
                return [
                    Vector(location: location, xBasis: 1, yBasis: -1)
                ]
            } else if input == (1, 0) {
                return [
                    Vector(location: location, xBasis: 1, yBasis: 0),
                    Vector(location: location, xBasis: 0, yBasis: 1)
                ]
            } else if input == (0, 1) {
                return [
                    Vector(location: location, xBasis: 0, yBasis: 1),
                    Vector(location: location, xBasis: 1, yBasis: 0)
                ]
            } else if input == (-1, 1) {
                return [
                    Vector(location: location, xBasis: -1, yBasis: 1)
                ]
            }
        case .deg90:    fallthrough
        case .deg270:
            if input == (-1, 0) {
                return [
                    Vector(location: location, xBasis: -1, yBasis: 0)
                ]
            } else if input == (-1, -1) {
                return [
                    Vector(location: location, xBasis: -1, yBasis: -1),
                    Vector(location: location, xBasis: 1, yBasis: -1)
                ]
            } else if input == (1, -1) {
                return [
                    Vector(location: location, xBasis: 1, yBasis: -1),
                    Vector(location: location, xBasis: -1, yBasis: -1)
                ]
            } else if input == (1, 0) {
                return [
                    Vector(location: location, xBasis: 1, yBasis: 0)
                ]
            } else if input == (1, 1) {
                return [
                    Vector(location: location, xBasis: 1, yBasis: 1),
                    Vector(location: location, xBasis: -1, yBasis: 1)
                ]
            } else if input == (-1, 1) {
                return [
                    Vector(location: location, xBasis: -1, yBasis: 1),
                    Vector(location: location, xBasis: 1, yBasis: 1)
                ]
            }
        case .deg135:   fallthrough
        case .deg315:
            if input == (-1, 0) {
                return [
                    Vector(location: location, xBasis: -1, yBasis: 0),
                    Vector(location: location, xBasis: 0, yBasis: 1)
                ]
            } else if input == (-1, -1) {
                return [
                    Vector(location: location, xBasis: -1, yBasis: -1)
                ]
            } else if input == (0, -1) {
                return [
                    Vector(location: location, xBasis: 0, yBasis: -1),
                    Vector(location: location, xBasis: 1, yBasis: 0)
                ]
            } else if input == (1, 0) {
                return [
                    Vector(location: location, xBasis: 1, yBasis: 0),
                    Vector(location: location, xBasis: 0, yBasis: -1)
                ]
            } else if input == (1, 1) {
                return [
                    Vector(location: location, xBasis: 1, yBasis: 1)
                ]
            } else if input == (0, 1) {
                return [
                    Vector(location: location, xBasis: 0, yBasis: 1),
                    Vector(location: location, xBasis: -1, yBasis: 0)
                ]
            }
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
                Vector(location: location, xBasis: -1, yBasis: -1),
                Vector(location: location, xBasis: -1, yBasis: 1),
                Vector(location: location, xBasis: 0, yBasis: -1),
                Vector(location: location, xBasis: 1, yBasis: -1),
                Vector(location: location, xBasis: 1, yBasis: 1),
                Vector(location: location, xBasis: 0, yBasis: 1)
            ]
        case .deg45:    fallthrough
        case .deg225:
            _possibleResponses = [
                Vector(location: location, xBasis: -1, yBasis: 0),
                Vector(location: location, xBasis: 0, yBasis: -1),
                Vector(location: location, xBasis: 1, yBasis: -1),
                Vector(location: location, xBasis: 1, yBasis: 0),
                Vector(location: location, xBasis: 0, yBasis: 1),
                Vector(location: location, xBasis: -1, yBasis: 1)
            ]
        case .deg90:    fallthrough
        case .deg270:
            _possibleResponses = [
                Vector(location: location, xBasis: -1, yBasis: 0),
                Vector(location: location, xBasis: 1, yBasis: -1),
                Vector(location: location, xBasis: -1, yBasis: -1),
                Vector(location: location, xBasis: 1, yBasis: 0),
                Vector(location: location, xBasis: -1, yBasis: 1),
                Vector(location: location, xBasis: 1, yBasis: 1)
            ]
        case .deg135:   fallthrough
        case .deg315:
            _possibleResponses = [
                Vector(location: location, xBasis: -1, yBasis: -1),
                Vector(location: location, xBasis: 1, yBasis: 0),
                Vector(location: location, xBasis: 0, yBasis: -1),
                Vector(location: location, xBasis: 1, yBasis: 1),
                Vector(location: location, xBasis: 0, yBasis: 1),
                Vector(location: location, xBasis: -1, yBasis: 0)
            ]
        }
    }
}
