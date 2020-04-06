//
//  Array + Extension.swift
//  Chromatron
//
//  Created by SwanCurve on 03/30/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation

extension Array where Element: NSCopying {
    func copied() -> Array<Element> {
        self.map{ $0.copy() as! Element }
    }
}

func *<T1, T2>(lhs: Array<T1>, rhs: Array<T2>) -> Array<(T1, T2)> {
    var res: Array<(T1, T2)> = []
    res.reserveCapacity(lhs.count * rhs.count)
    for i in lhs {
        for j in rhs {
            res.append((i, j))
        }
    }
    return res
}
