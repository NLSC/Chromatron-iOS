//
//  LevelManager.swift
//  Chromatron
//
//  Created by SwanCurve on 03/29/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit

// MARK: - LevelInfo
struct LevelInfo {
    var index: Int
    var current: Bool = false
    var locked: Bool = true
}

struct Keys {
    static let Version = "version"
    static let List = "list"
    static let Placed = "placed"
    static let Available = "available"
        static let AvailableType = "type"
        static let AvailableCount = "count"
}

// MARK:
fileprivate
struct RawLevelData {
    let placed: String
    let available: [(type: String, count: Int)]
}

struct LevelData {
    var placed: [Responsible]
    var available: [Responsible]
    var availableSimple: [(item: Responsible, count: Int)]
}

// MARK: - LevelManager
struct LevelManager {
    var levels: [LevelInfo] {
        return rawLevels.enumerated().map { (idx, raw) in
            LevelInfo(index: idx, current: false, locked: false)
        }
    }
    
    private var cache: [LevelData?] = []
    private var rawLevels: [RawLevelData] = []
    
    init() {
        prepare()
    }
    
    private mutating func prepare() {
        guard let dataPath = Bundle.main.path(forResource: "data", ofType: "json") else {
            return
        }
        do {
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: dataPath))
            
            let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [String: Any]
            
            let _ = json[Keys.Version]
            let levels = (json[Keys.List] as! [ [String: Any] ]).map { (raw: [String: Any]) -> RawLevelData in
                let placed = raw[Keys.Placed] as! String
                let availables = (raw[Keys.Available] as! [ [String: Any] ]).map {
                    (type: $0[Keys.AvailableType] as! String, count: $0[Keys.AvailableCount] as! Int)
                }
                return RawLevelData(placed: placed, available: availables)
            }
            
            self.rawLevels = levels
            self.cache = [LevelData?](repeating: nil, count: levels.count)
        } catch let err {
            print("reading data.json error: \(err)")
        }
    }
    
    mutating func level(_ index: Int) -> LevelData? {
        guard index < rawLevels.count else {
            assert(false)
            popError(message: "\(#file).\(#line) #\(#function)")
            return nil
        }
        if cache[index] == nil {
            let rawData = rawLevels[index]
            cache[index] = LevelData(placed: deserializePlaced(rawData.placed),
                                     available: deserializeAvailable(rawData.available),
                                     availableSimple: deserializeAvailableSimple(rawData.available))
        }
        return cache[index]
    }
    
    func levelAvailable(_ level: Int) -> Bool {
        guard !rawLevels.isEmpty else {
            return false
        }
        let available = level >= 0 && level < rawLevels.count
        return available
    }
}

extension LevelManager {
    
    private func deserializePlaced(_ code: String) -> [Responsible] {
        do {
            return try CDecode.shared.deserialize(fromString: code)
        } catch {
            assert(false)
        }
        return []
    }
    
    private func deserializeAvailable(_ available: [(type: String, count: Int)]) -> [Responsible] {
        var items: [Responsible?] = []
        for i in available {
            for _ in 0..<i.count {
                items.append(CDecode.shared.responsible(forType: i.type))
            }
        }
        return items.compactMap({ $0 })
    }
    
    private func deserializeAvailableSimple(_ available: [(type: String, count: Int)]) -> [(item: Responsible, count: Int)] {
        var items: [(item: Responsible, count: Int)] = []
        for i in available {
            items.append((CDecode.shared.responsible(forType: i.type)!, i.count))
        }
        return items
    }
}
