//
//  Responsible.swift
//  Chromatron
//
//  Created by SwanCurve on 03/20/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit

enum Angle: Int {
    case deg0   = 0
    case deg45  = 45
    case deg90  = 90
    case deg135 = 135
    case deg180 = 180
    case deg225 = 225
    case deg270 = 270
    case deg315 = 315
    
    static func +(_ lhs: Angle, _ rhs: Angle) -> Angle {
        return Angle.init(rawValue: (lhs.rawValue + rhs.rawValue) % 360)!
    }
    
    static func += (_ lhs: inout Angle, _ rhs: Angle) {
        lhs = lhs + rhs
    }
}

struct Point: Equatable, Hashable {
    var x: Int
    var y: Int
    
    static let zero: Point = Point(x: 0, y: 0)
    static let invalid: Point = Point(x: -1, y: -1)
}

protocol VectorProtocol {
    var location: Point { get set }
    var xBasis: Int { get set }
    var yBasis: Int { get set }
}

struct Vector: VectorProtocol & Equatable {
    static let zero = Vector(location: .zero, xBasis: 0, yBasis: 0)
    
    var location: Point
    var xBasis: Int
    var yBasis: Int
}

typealias Input = (vec: Vector, c: BeamColor)

protocol Responsible: CustomStringConvertible, NSCopying {
    var location: Point? { get set }
    var angle: Angle { get set }
    
    var view: UIView? { get }
    var icon: UIImageView { get }
    
    var color: BeamColor { get }
    
    var possibleResponses: [Vector] { get }
    
    func responses(for excitation: Vector) -> [Vector]
    
    func responses(for input: Input) -> [Input]
    
    func blend(_ color: BeamColor)
    
    init()
}

extension Responsible {
    var view: UIView? { nil }
    var icon: UIImageView { UIImageView() }
    func responses(for input: Input) -> [Input] {
        return responses(for: input.vec).map { ($0, input.c) }
    }
}

protocol Excitator: Responsible {
    var excitation: Vector { get }
}

extension Excitator {
    func blend(_ color: BeamColor) {}
}

