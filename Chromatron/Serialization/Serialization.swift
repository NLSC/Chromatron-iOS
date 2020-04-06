//
//  Serialization.swift
//  Chromatron
//
//  Created by SwanCurve on 03/26/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation

enum DeserializeError: Error {
    case UnexpectedEncoding
    case UnexpectedContent
}

func serialize() {
    
}

typealias ResponsibleData = (t: String, placed: Bool, color: BeamColor, angle: Angle, x: Int, y: Int)

class CDecode {
    static let shared = CDecode()
    
    private var factory: [String : ((ResponsibleData?) -> Responsible)] = [:]
    
    func register(_ type: String, ctor: @escaping (ResponsibleData?) -> Responsible) {
        guard factory[type] == nil else {
            assert(false)
            popError(message: "\(#file).\(#line) #\(#function)")
            return
        }
        
        factory[type] = ctor
    }
    
    fileprivate
    func decode(code: Substring) throws -> ResponsibleData {
        let begin = code.startIndex
        
        let type = code[begin]
        let angle = code[code.index(begin, offsetBy: 1)]
        let _color = code[code.index(begin, offsetBy: 2)]
        let x = code[code.index(begin, offsetBy: 3)]
        let y = code[code.index(begin, offsetBy: 4)]
        
        guard type.isLetter, angle.isLetter, _color.isLetter, x.isLetter, y.isLetter else {
            throw DeserializeError.UnexpectedContent
        }
        
        var color: BeamColor = .NoColor
        switch _color {
        case "R": color = .Red
        case "B": color = .Blue
        case "G": color = .Green
        case "C": color = .Cyan
        case "P": color = .Purple
        case "Y": color = .Yellow
        case "W": color = .White
        case "K": color = .Black
        default:
            break
        }
        
        return (
            type.uppercased(),
            type.isUppercase,
            color,
            Angle(rawValue: Int(angle.asciiValue! - Character("A").asciiValue!) * 45)!,
            Int(x.asciiValue! - Character("A").asciiValue!),
            Int(y.asciiValue! - Character("A").asciiValue!)
        )
    }

    func deserialize(fromData data: Data) throws -> [Responsible] {
        guard let string = String(data: data, encoding: .ascii) else {
            throw DeserializeError.UnexpectedEncoding
        }
        
        do {
            let items = try deserialize(fromString: string)
            return items
        } catch let err {
            throw err
        }
    }

    func deserialize(fromString string: String) throws -> [Responsible] {
        guard string.count % 5 == 0 else {
            throw DeserializeError.UnexpectedContent
        }
        
        var index = string.startIndex
        
        var items: [Responsible] = []
        
        while index != string.endIndex {
            let end = string.index(index, offsetBy: 5)
            do {
                let decoded = try decode(code: string[index..<end])
                if let ctor = factory[decoded.t] {
                    items.append(ctor(decoded))
                }
            } catch DeserializeError.UnexpectedContent {
                assert(false)
            }
            index = end
        }
        return items
    }
    
    func responsible(forType type: String) -> Responsible? {
        guard let ctor = factory[type] else {
            return nil
        }
        
        return ctor(nil)
    }
}
