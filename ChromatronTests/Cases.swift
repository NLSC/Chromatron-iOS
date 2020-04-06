//
//  Cases.swift
//  Chromatron
//
//  Created by SwanCurve on 03/26/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
@testable import Chromatron

let el_1_2: [Responsible] = [
    Laser(angle: .deg0, location: Point(x: 3, y: 6), color: .Red, id: "G1"),
    Laser(angle: .deg180, location: Point(x: 12, y: 8), color: .Blue, id: "G2"),
    Reflector(angle: .deg45, location: Point(x: 8, y: 6), id: "M1"),
    Reflector(angle: .deg45, location: Point(x: 10, y: 5), id: "M2"),
    Reflector(angle: .deg225, location: Point(x: 10, y: 8), id: "M3")
]

let el_1_3: [Responsible] = [
    Laser(angle: .deg315, location: Point(x: 0, y: 11), color: .Blue, id: "G1"),
    Laser(angle: .deg45, location: Point(x: 3, y: 0), color: .Green, id: "G2"),
    Laser(angle: .deg180, location: Point(x: 14, y: 3), color: .Red, id: "G3"),
    Reflector(angle: .deg0, location: Point(x: 6, y: 5), id: "M1"),
    Reflector(angle: .deg90, location: Point(x: 10, y: 7), id: "M2"),
    Reflector(angle: .deg315, location: Point(x: 7, y: 3), id: "M3"),
    Target(location: Point(x: 7, y: 10), id: "R3"),
    Target(location: Point(x: 7, y: 6), id: "R2"),
    Target(location: Point(x: 9, y: 8), id: "R1")
]

let el_1_5: [Responsible] = [
    Laser(angle: .deg0, location: Point(x: 1, y: 8), color: .Red, id: "G1"),
    Laser(angle: .deg0, location: Point(x: 1, y: 6), color: .Green, id: "G2"),
    
    Reflector(angle: .deg135, location: Point(x: 7, y: 8), id: "M1"),
    Splitter(angle: .deg135, location: Point(x: 7, y: 6), id: "S1"),
    Reflector(angle: .deg45, location: Point(x: 12, y: 6), id: "M2"),
    
    Target(location: Point(x: 7, y: 3), id: "T1"),
    Target(location: Point(x: 12, y: 7), id: "T2")
]

let el_1_6: [Responsible] = [
    Laser(angle: .deg0, location: Point(x: 1, y: 6), color: .Red, id: "G1"),
    Laser(angle: .deg180, location: Point(x: 13, y: 8), color: .Blue, id: "G2"),
    
    Splitter(angle: .deg45, location: Point(x: 4, y: 6), id: "S1"),
    Splitter(angle: .deg45, location: Point(x: 7, y: 6), id: "S2"),
    Splitter(angle: .deg45, location: Point(x: 7, y: 8), id: "S3"),
    Splitter(angle: .deg45, location: Point(x: 10, y: 8), id: "S4"),
    
    Target(location: Point(x: 4, y: 10), id: "T1"),
    Target(location: Point(x: 7, y: 12), id: "T2"),
    Target(location: Point(x: 10, y: 10), id: "T3"),
    
    Target(location: Point(x: 4, y: 4), id: "T4"),
    Target(location: Point(x: 7, y: 2), id: "T5"),
    Target(location: Point(x: 10, y: 4), id: "T6")
]

let el_1_8: [Responsible] = [
    Laser(angle: .deg0, location: Point(x: 3, y: 3), color: .Blue, id: "G1"),
    
    Splitter(angle: .deg0, location: Point(x: 6, y: 9), id: "S1"),
    Splitter(angle: .deg90, location: Point(x: 9, y: 6), id: "S2"),
    
    Bender(angle: .deg45, location: Point(x: 12, y: 3), id: "B1"),
    
    Target(location: Point(x: 2, y: 5), id: "T1"),
    Target(location: Point(x: 4, y: 11), id: "T2"),
    Target(location: Point(x: 12, y: 9), id: "T3")
]

let el_1_9: [Responsible] = {
    var els: [Responsible] = [
        Laser(angle: .deg90, location: Point(x: 0, y: 0), color: .Green, id: "G1"),
        Bender(angle: .deg180, location: Point(x: 0, y: 11), id: "B1")
    ]
    
    for i in 0..<15 {
        els.append(
            Conduits(angle: .deg135, location: Point(x: 1, y: i), id: "C\(i)")
        )
    }
    for i in 0..<15 {
        els.append(
            Conduits(angle: .deg135, location: Point(x: 4, y: i), id: "C\(i + 15)")
        )
    }
    for i in 0..<15 {
        els.append(
            Conduits(angle: .deg135, location: Point(x: 10, y: i), id: "C\(i + 30)")
        )
    }
    for i in 0..<15 {
        els.append(
            Conduits(angle: .deg135, location: Point(x: 13, y: i), id: "C\(i + 45)")
        )
    }
    
    els.append(contentsOf: [
        Target(location: Point(x: 2, y: 3), id: "T1"),
        Target(location: Point(x: 6, y: 9), id: "T2"),
        Target(location: Point(x: 12, y: 11), id: "T3"),
        Target(location: Point(x: 12, y: 1), id: "T4")
    ])
    
    return els
} ()
