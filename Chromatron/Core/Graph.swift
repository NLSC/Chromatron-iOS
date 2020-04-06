//
//  Graph.swift
//  Chromatron
//
//  Created by SwanCurve on 03/19/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit
import os

//  MARK: LinkedList
fileprivate
struct LinkedList<Element>: Sequence {
    class Node {
        let element: Element
        var next: Node?
        
        init(_ element: Element) {
            self.element = element
        }
    }
    
    struct LinkedListIterator: IteratorProtocol {
        var current: Node?
        mutating func next() -> Element? {
            guard let current = current else {
                return nil
            }
            let el = current.element
            self.current = current.next
            return el
        }
    }
    
    __consuming func makeIterator() -> LinkedList<Element>.LinkedListIterator {
        return LinkedListIterator(current: head)
    }
    
    var head: Node?
    var tail: Node?
    
    var size: Int = 0
    
    init(element: Element) {
        head = Node(element)
        tail = head
        size += 1
    }
    
    init() {
        head = nil
        tail = nil
    }
    
    mutating func append(_ newElement: Element) {
        let n = Node(newElement)

        if head == nil {
            head = n
            tail = n
        } else {
            tail!.next = n
            tail = n
        }
        size += 1
    }
}

// MARK: Helper
fileprivate
func location(_ point: Point, onDirectionOf vector: VectorProtocol) -> Bool {
    if point.x == Int.max && point.y == Int.max {
        return true
    }
    let st = (x: point.x - vector.location.x, y: point.y - vector.location.y)
    
    let xBasis = vector.xBasis
    let yBasis = vector.yBasis
    
    if st.x == 0 && st.y == 0 {
        return false
    }
    
    if xBasis == 0 {
        guard st.x == 0 else { return false }
        return yBasis.signum() == st.y.signum()
    }
    
    if yBasis == 0 {
        guard st.y == 0 else { return false }
        return xBasis.signum() == st.x.signum()
    }
    
    return ((st.x.signum() == xBasis.signum()) && (st.y.signum() == yBasis.signum())) &&
        ((Float(st.x) / Float(xBasis)) == (Float(st.y) / Float(yBasis)))
}

fileprivate
func location(_ point1: Point, isCloserThan point2: Point, to point: Point) -> Bool {
    if point1.x != point2.x {
        return abs(point1.x - point.x) < abs(point2.x - point.x)
    } else if point1.y != point2.y {
        return abs(point1.y - point.y) < abs(point2.y - point.y)
    } else {
        return false
    }
}

// MARK: edge
class Infinite: Responsible {
    var location: Point?
    
    var angle: Angle = .deg0
    
    var color: BeamColor = .NoColor
    
    var possibleResponses: [Vector] = []
    
    func responses(for excitation: Vector) -> [Vector] {
        return []
    }
    
    var description: String {
        guard let location = location else {
            return "E (unused)"
        }
        return "E(\(location.x), \(location.y))"
    }
    
    required convenience init() {
        self.init(location: .zero)
    }
    
    init(location: Point) {
        self.location = location
    }
    
    func blend(_ color: BeamColor) {
        self.color = self.color + color
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Infinite(location: self.location ?? .invalid)
    }
}

// MARK: Graph
class Graph {
    var width: Int = 0
    var height: Int = 0
    private var concurrent: Bool = false
    
    fileprivate
    var rows: [LinkedList<Int>] = []
    
    fileprivate
    var adjacencyList: [LinkedList<Int>] = []
    
    fileprivate
    var respondChain: [LinkedList<Int>?] = []
    
    fileprivate
    var beamList: [Beam] = []
    
    var beams: [Beam] {
        return beamList
    }
    
    var elements: [Responsible] {
        set {
            reset()
            vertexes = newValue
            
            if concurrent {
                updateAdjacencyListConcurrent()
                updateGraphConcurrent()
            } else {
                updateAdjacencyList()
                updateGraph3()
            }
        }
        get {
            return vertexes
        }
    }
    
    fileprivate
    var vertexes: [Responsible]
    var infinites: [Responsible] = []
    
    init(width: Int, height: Int, concurrent: Bool = false, elements: [Responsible] = []) {
        self.width = width
        self.height = height
        self.concurrent = concurrent
        
        vertexes = elements
        
        
        if self.concurrent {
            updateAdjacencyListConcurrent()
            updateGraphConcurrent()
        } else {
            updateAdjacencyList()
            updateGraph3()
        }
    }
    
    func addInfinite(for vector: Vector) -> Int {
        infinites.append(Infinite(location:
            Point(x: vector.location.x + vector.xBasis * width,
                  y: vector.location.y + vector.yBasis * height))
        )
        return -1 * (infinites.count)
    }
    
    func infinite(for index: Int) -> Responsible {
        return infinites[index * -1 - 1]
    }
    
    private
    func reset() {
        rows.removeAll()
        adjacencyList.removeAll()
        respondChain.removeAll()
        vertexes.removeAll()
        infinites.removeAll()
        beamList.removeAll()
    }
}

// MARK: make graph

fileprivate
extension Graph {
    
    func responder(for index: Int) -> Responsible {
        guard index >= 0 else {
            return infinite(for: index)
        }
        return vertexes[index]
    }
    
    func updateAdjacencyList() {
        for (i, vertex) in vertexes.enumerated() {
            // init rows
            rows.append(LinkedList())
            respondChain.append(nil)
            
            var row = LinkedList<Int>()
            
            let possible = vertex.possibleResponses
            
            for vec in possible {
                var neighbor: Int?
                var point: Point?
                
                for (j, resp) in vertexes.enumerated() {
                    guard i != j else { continue }
                    guard resp.location != nil else {
                        // not placed
                        continue
                    }
                    
                    if location(resp.location!, onDirectionOf: vec) {
                        if resp is Target {
                            row.append(j)
                            continue
                        }
                        if neighbor == nil || location(resp.location!, isCloserThan: point!, to: vec.location) {
                            neighbor = j
                            point = resp.location
                        }
                    }
                }
                
                if let neighbor = neighbor {
                    row.append(neighbor)
                } else {
                    row.append(addInfinite(for: vec))
                }
            }
            
            adjacencyList.append(row)
        }
    }
    
    func updateAdjacencyListConcurrent() {
        
        let groupQueue = DispatchQueue(label: "com.chromatron.groupQueue", attributes: .concurrent)
        let group = DispatchGroup()
        
        var lock = os_unfair_lock()
        
        for (i, vertex) in vertexes.enumerated() {
            // init rows
            rows.append(LinkedList())
            respondChain.append(nil)
            
            var row = LinkedList<Int>()
            
            groupQueue.async(group: group, qos: .default, flags: []) {
                let possible = vertex.possibleResponses
                
                for vec in possible {
                    var neighbor: Int?
                    var point: Point?
                    
                    for (j, resp) in self.vertexes.enumerated() {
                        guard i != j else { continue }
                        guard resp.location != nil else {
                            // not placed
                            continue
                        }
                        
                        if location(resp.location!, onDirectionOf: vec) {
                            if resp is Target {
                                os_unfair_lock_lock(&lock)
                                row.append(j)
                                os_unfair_lock_unlock(&lock)
                                continue
                            }
                            if neighbor == nil || location(resp.location!, isCloserThan: point!, to: vec.location) {
                                neighbor = j
                                point = resp.location
                            }
                        }
                    }
                    
                    if let neighbor = neighbor {
                        os_unfair_lock_lock(&lock)
                        row.append(neighbor)
                        os_unfair_lock_unlock(&lock)
                    } else {
                        os_unfair_lock_lock(&lock)
                        row.append(self.addInfinite(for: vec))
                        os_unfair_lock_unlock(&lock)
                    }
                }
            }
            group.wait()
            adjacencyList.append(row)
        }
    }
    
    @available(*, deprecated, message: "")
    func updateGraph() {
        var mark: [Bool] = [Bool](repeating: false, count: vertexes.count)
        var currentInput: Int!
        
        func dfs(input: Vector, responderIdx: Int) {
            
            let outputs = self.vertexes[responderIdx].responses(for: input)
            let nextPossibleRespondables = self.adjacencyList[responderIdx]
            guard nextPossibleRespondables.size > 0 else {
                rows[responderIdx].append(-1)
                return
            }
            
            for nextResponderIdx in nextPossibleRespondables {
                
                if nextResponderIdx < 0 {
                    // infinite
                    for output in outputs {
                        if location(infinite(for: nextResponderIdx).location!, onDirectionOf: output) {
                            rows[responderIdx].append(nextResponderIdx)
                            respondChain[currentInput]!.append(nextResponderIdx)
                            break;
                        }
                    }
                } else {
                    // to responder
                    if mark[nextResponderIdx] {
                        continue
                    }
                    
                    var respondForOutput: Vector?
                    for output in outputs {
                        if location(self.vertexes[nextResponderIdx].location!, onDirectionOf: output) {
                            respondForOutput = output
                            break;
                        }
                    }
                    
                    guard respondForOutput != nil else {
                        continue
                    }
                    
                    mark[nextResponderIdx] = true
                    Swift.print("-> \(vertexes[nextResponderIdx])\n")
                    rows[responderIdx].append(nextResponderIdx)
                    respondChain[currentInput]!.append(nextResponderIdx)
                    dfs(input: respondForOutput!, responderIdx: nextResponderIdx)
                    mark[nextResponderIdx] = false
                }
            }
        }
        
        for (i, vertex) in vertexes.enumerated() {
            guard let generator = vertex as? Excitator else {
                continue
            }
            
            Swift.print("from \(vertexes[i])\n")
            
            mark[i] = true
            currentInput = i
            respondChain[i] = LinkedList()
            let input = generator.excitation
            
            for responder in adjacencyList[i] {
                if responder < 0 {
                    rows[i].append(responder)
                    respondChain[currentInput]!.append(responder)
                } else {
                    mark[responder] = true
                    Swift.print("-> \(vertexes[responder])\n")
                    rows[i].append(responder)
                    respondChain[currentInput]!.append(responder)
                    dfs(input: input, responderIdx: responder)
                    mark[responder] = false
                }
            }
            mark[i] = false
        }
    }
    
    @available(*, deprecated, message: "")
    func updateGraph2() {
        
        var memo: [Bool] = [Bool](repeating: false, count: vertexes.count)

        var currentInput = 0
        
        var _beamList: [Beam] = []
        
        var queue: [(Vector, Responsible)] = []
        
        func addBeam(_ newBeam: Beam) {
            if let i = _beamList.firstIndex(where: {
                ($0.p1 == newBeam.p1 && $0.p2 == newBeam.p2) ||
                    ($0.p1 == newBeam.p2 && $0.p2 == newBeam.p1) }) {
                _beamList[i] += newBeam
            } else {
                _beamList.append(newBeam)
            }
        }
        
        func dupBeam(_ beam: Beam) -> Bool {
            return _beamList.contains { $0.p1 == beam.p1 && $0.p2 == beam.p2 && $0.color.contains(beam.color) }
        }
        
        func withMemo(mark index: Int, closure: () -> Void) {
            memo[index] = true
            closure()
            memo[index] = false
        }
        
        func dfs(input: Input, responderIndexes: [Int]) {
            for responderIndex in responderIndexes {
//                guard responderIndex < 0 || !memo[responderIndex] else {
//                    continue
//                }
                
                let responder = self.responder(for: responderIndex)
                
                guard location(responder.location!, onDirectionOf: input.vec) else {
                    continue
                }
                
                if let target = responder as? Target {
                    target.blend(input.c)
                    continue
                }
                
                if dupBeam(Beam(p1: input.vec.location, p2: responder.location!, color: input.c)) {
                    continue
                }
                
                if responderIndex < 0 {
                    addBeam(
                        Beam(p1: input.vec.location, p2: responder.location!, color: input.c)
                    )
//                } else if memo[responderIndex] {
//                    addBeam(
//                        Beam(p1: input.vec.location, p2: responder.location!, color: input.c)
//                    )
                } else {
                    addBeam(
                        Beam(p1: input.vec.location, p2: responder.location!, color: input.c)
                    )
                    
                    let outputs = responder.responses(for: input)

                    withMemo(mark: responderIndex) {
                        for output in outputs {
                            dfs(input: output, responderIndexes: Array(adjacencyList[responderIndex]))
                        }
                    }
                }
            }
        }
        
        for (i, vertex) in vertexes.enumerated() {
            guard let generator = vertex as? Excitator else {
                continue
            }
            
            let input: Input = (generator.excitation, generator.color)

            withMemo(mark: i) {
                dfs(input: input, responderIndexes: Array(adjacencyList[i]))
                assert(memo.filter({ $0 }).count == 1 && memo.firstIndex(where: { $0 }) == i)
            }
        }
        
        func printBeamList2() {
            var desc = "beam list2:\n"
            for b in _beamList {
                desc += "\(b)\n"
            }
            desc += "\n"
            Swift.print(desc)
        }
        printBeamList2()
        beamList = _beamList
    }
    
    func updateGraph3() {

        var currentInput = 0
        
        var _beamList: [Beam] = []
        
        func addBeam(_ newBeam: Beam) {
            if let i = _beamList.firstIndex(where: {
                ($0.p1 == newBeam.p1 && $0.p2 == newBeam.p2) ||
                    ($0.p1 == newBeam.p2 && $0.p2 == newBeam.p1) }) {
                _beamList[i] += newBeam
            } else {
                _beamList.append(newBeam)
            }
        }
        
        func dupBeam(_ beam: Beam) -> Bool {
            return _beamList.contains { $0.p1 == beam.p1 && $0.p2 == beam.p2 && $0.color.contains(beam.color) }
        }
        
        func dfs(input: Input, responderIndexes: [Int]) {
            for responderIndex in responderIndexes {
                
                let responder = self.responder(for: responderIndex)
                
                guard location(responder.location!, onDirectionOf: input.vec) else {
                    continue
                }
                
                if let target = responder as? Target {
                    target.blend(input.c)
                    continue
                }
                
                let beam = Beam(p1: input.vec.location, p2: responder.location!, color: input.c)
                
                if dupBeam(beam) {
                    continue
                }
                
                if responderIndex < 0 {
                    addBeam(beam)
                } else {
                    addBeam(beam)
                    
                    let outputs = responder.responses(for: input)

                    for output in outputs {
                        dfs(input: output, responderIndexes: Array(adjacencyList[responderIndex]))
                    }
                }
            }
        }
        
        for (i, vertex) in vertexes.enumerated() {
            guard let generator = vertex as? Excitator else {
                continue
            }
            
            let input: Input = (generator.excitation, generator.color)

            dfs(input: input, responderIndexes: Array(adjacencyList[i]))
        }
        
        func printBeamList2() {
            var desc = "beam list2:\n"
            for b in _beamList {
                desc += "\(b)\n"
            }
            desc += "\n"
            Swift.print(desc)
        }
//        printBeamList2()
        beamList = _beamList
    }

    func updateGraphConcurrent() {
        
        var currentInput = 0
        
        var _beamList: [Beam] = []
        
        var level: [(input: Input, responderIndex: Int)] = []
        
        let groupQueue = DispatchQueue(label: "com.chromatron.groupQueue", attributes: .concurrent)
        let group = DispatchGroup()
        
        var beamLock = os_unfair_lock()
        var levelLock = os_unfair_lock()
        func addBeam(_ newBeam: Beam) {
            os_unfair_lock_lock(&beamLock)
                if let i = _beamList.firstIndex(where: {
                    ($0.p1 == newBeam.p1 && $0.p2 == newBeam.p2) ||
                        ($0.p1 == newBeam.p2 && $0.p2 == newBeam.p1) }) {
                    _beamList[i] += newBeam
                } else {
                    _beamList.append(newBeam)
                }
            os_unfair_lock_unlock(&beamLock)
        }
        
        func dupBeam(list: [Beam], _ beam: Beam) -> Bool {
            os_unfair_lock_lock(&beamLock)
            defer {
                os_unfair_lock_unlock(&beamLock)
            }
            return list.contains { $0.p1 == beam.p1 && $0.p2 == beam.p2 && $0.color.contains(beam.color) }
        }
        
        @inline(__always)
        func bfs() {
            while !level.isEmpty {
                var next: [(input: Input, responderIndex: Int)] = []
                
                let copied = _beamList
                for (input, responderIndex) in level {
                    groupQueue.async(group: group, qos: .default, flags: []) {
                        let responder = self.responder(for: responderIndex)
                        
                        guard location(responder.location!, onDirectionOf: input.vec) else {
                            return
                        }
                        
                        if let target = responder as? Target {
                            target.blend(input.c)
                            return
                        }
                        
                        let beam = Beam(p1: input.vec.location, p2: responder.location!, color: input.c)
                        
                        if dupBeam(list: copied, beam) {
                            return
                        }
                        
                        if responderIndex < 0 {
                            addBeam(beam)
                        } else {
                            addBeam(beam)
                            
                            let outputs = responder.responses(for: input)
                            os_unfair_lock_lock(&levelLock)
                            next.append(contentsOf: outputs * Array(self.adjacencyList[responderIndex]))
                            os_unfair_lock_unlock(&levelLock)
                        }
                    }
                }
                group.wait()
                level = next
            }
        }
        
        for (i, vertex) in vertexes.enumerated() {
            guard let generator = vertex as? Excitator else {
                continue
            }
            
            let input: Input = (generator.excitation, generator.color)
            let l = [input] * Array(self.adjacencyList[i])
            level.append(contentsOf: l)
        }
        bfs()
        
        
        func printBeamList2() {
            var desc = "beam list2:\n"
            for b in _beamList {
                desc += "\(b)\n"
            }
            desc += "\n"
            Swift.print(desc)
        }
//        printBeamList2()
        beamList = _beamList
    }
    
    @available(*, deprecated, message: "")
    func coloring() {
        var _beamList: [Beam] = []
        func addBeam(_ newBeam: Beam) {
            if let _ = _beamList.firstIndex(where: {
                ($0.p1 == newBeam.p1 && $0.p2 == newBeam.p2) ||
                    ($0.p1 == newBeam.p2 && $0.p2 == newBeam.p1) }) {
//                _beamList[i] += newBeam
            } else {
                _beamList.append(newBeam)
            }
        }
        
        for (i, chain) in respondChain.enumerated() {
            guard let chain = chain else {
                continue
            }
            
            let input = vertexes[i] as! Excitator
            
            for (_, respIdx) in chain.enumerated() {
                if respIdx < 0 {
                    infinite(for: respIdx).blend(input.color)
                } else if let target = vertexes[respIdx] as? Target {
                    vertexes[respIdx].blend(input.color)
                } else {
                    vertexes[respIdx].blend(input.color)
                }
            }
        }
        
        func validLocation(_ location: Point, isInfinite: Bool = false) -> Point {
            let p = location
//            p.x = max(min(p.x, width - 1), 0)
//            p.y = max(min(p.y, height - 1), 0)
            return p
        }
        
        for (i, row) in rows.enumerated() {
            let input = vertexes[i]
            
            for respIdx in row {
                let resp = respIdx < 0 ? infinite(for: respIdx) : vertexes[respIdx]
                
                if !(resp is Target) {
                    var beam = Beam(p1: validLocation(input.location!),
                                    p2: validLocation(resp.location!), color: input.color)
                    beam.infinite = (respIdx < 0)
                    addBeam(beam)
                }
            }
        }
        beamList = _beamList
    }

}

//  MARK: Debug
extension Graph {
    func printAdjacencyList() {
        var desc = "adjacencyList:\n"
        for (rowIdx, row) in adjacencyList.enumerated() {
            desc.append("\(vertexes[rowIdx])")
            for p in row {
                if p < 0 {
                    desc.append(" -> \(infinite(for: p))")
                } else {
                    desc.append(" -> \(vertexes[p])")
                }
            }
            desc.append("\n")
        }
        Swift.print(desc)
    }
    
    func printGraph() {
        var desc = "graph:\n"
        for (rowIdx, row) in rows.enumerated() {
            desc.append("\(vertexes[rowIdx])(\(vertexes[rowIdx].color))")
            for r in row {
                if r < 0 {
                    desc.append(" -> \(infinite(for: r))(\(infinite(for: r).color))")
                } else {
                    desc.append(" -> \(vertexes[r])(\(vertexes[r].color))")
                }
            }
            desc.append("\n")
        }
        Swift.print(desc)
    }
    
    func printRespondChain() {
        var desc = "respond:\n"
        for (rowIdx, row) in respondChain.enumerated() {
            guard let row = row else {
                continue
            }
            desc.append("\(vertexes[rowIdx])(\(vertexes[rowIdx].color))")
            for r in row {
                if r < 0 {
                    desc.append(" -> \(infinite(for: r))(\(infinite(for: r).color))")
                } else {
                    desc.append(" -> \(vertexes[r])(\(vertexes[r].color))")
                }
            }
            desc.append("\n")
        }
        Swift.print(desc)
    }
    
    func printBeamList() {
        var desc = "beam list:\n"
        for b in beamList {
            desc += "\(b)\n"
        }
        desc += "\n"
        Swift.print(desc)
    }
}

extension Graph: CustomStringConvertible {
    var description: String {
        var desc = ""
        for row in adjacencyList {
            for (idx, p) in row.enumerated() {
                if idx != 0 {
                    desc.append(" -> ")
                }
                desc.append("\(vertexes[p])")
            }
            desc.append("\n")
        }
        return desc
    }
}
