//
//  Laser.swift
//  Chromatron
//
//  Created by SwanCurve on 03/20/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit

struct BeamColor: OptionSet, CustomStringConvertible {
    let rawValue: Int
    
    static let NoColor = BeamColor(rawValue: 0)
    
    static let Red   = BeamColor(rawValue: 1 << 0)
    static let Blue  = BeamColor(rawValue: 1 << 1)
    static let Green = BeamColor(rawValue: 1 << 2)
    
    static let Purple: BeamColor = [.Red, .Blue]
    static let Yellow: BeamColor = [.Red, .Green]
    static let Cyan: BeamColor   = [.Blue, .Green]
    static let White: BeamColor  = [.Red, .Green, .Blue]
    
    static let Black = BeamColor(rawValue: 1 << 4)
    
    var description: String {
        switch self {
        case .Red: return "Red"
        case .Blue: return "Blue"
        case .Green: return "Green"
        case .Purple: return "Purple"
        case .Cyan: return "Cyan"
        case .Yellow: return "Yellow"
        case .White: return "White"
        case .NoColor: return " "
        default:
            assert(false)
            popError(message: "\(#file).\(#line) #\(#function)")
        }
        return ""
    }
    
    static func +(lhs: BeamColor, rhs: BeamColor) -> BeamColor {
        return lhs.union(rhs)
    }
    
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.insert(rhs)
    }
    
    var color: UIColor {
        switch self {
        case .Red:      return UIColor.red
        case .Blue:     return UIColor.blue
        case .Green:    return UIColor.green
        case .Purple:   return UIColor.purple
        case .Cyan:     return UIColor.cyan
        case .Yellow:   return UIColor.yellow
        case .White:    return UIColor.white
        case .NoColor:  fallthrough
        default:
            return UIColor.black
        }
    }
}

struct Beam: CustomStringConvertible {
    var description: String {
        return "[(\(p1.x), \(p1.y)) - (\(p2.x), \(p2.y)) (\(color))]"
    }
    
    var p1: Point
    var p2: Point
    
    var infinite = false
    
    var color: BeamColor
    
    init(p1: Point, p2: Point, color: BeamColor) {
        self.p1 = p1
        self.p2 = p2
        self.color = color
    }
    
    static func +(lhs: Beam, rhs: Beam) -> Beam {
        assert((lhs.p1 == rhs.p1 && lhs.p2 == rhs.p2) ||
            (lhs.p1 == rhs.p2 && lhs.p2 == rhs.p1))
        return Beam(p1: lhs.p1, p2: lhs.p2, color: lhs.color + rhs.color)
    }
    
    static func +=(lhs: inout Beam, rhs: Beam) {
        lhs.color += rhs.color
    }
}
