//
//  ChromatronTests.swift
//  ChromatronTests
//
//  Created by SwanCurve on 03/10/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import XCTest
@testable import Chromatron

class ChromatronTests: XCTestCase {
    
    var graph: Graph?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let elements: [Responsible] = el_1_9

        graph = Graph(width: 15, height: 15, elements: elements)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func measure(repeats: Int, f: ()->()) {
        let start = CACurrentMediaTime()
        var t = 0
        repeat {
            f()
            t += 1
        } while (t < repeats)
        let end = CACurrentMediaTime()
        print("time spent：\((end - start) / Double(repeats))")
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        graph?.printAdjacencyList()
        graph?.printGraph()
        graph?.printRespondChain()
        graph?.printBeamList()
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        
        self.measure {
            // Put the code you want to measure the time of here.
            let elements: [Responsible] = el_1_9.shuffled()

            let _ = Graph(width: 15, height: 15, elements: elements)
        }
    }

}
