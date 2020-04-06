//
//  GridView.swift
//  Chromatron
//
//  Created by SwanCurve on 03/10/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import Combine

class GridView: UIView {
    var gridSize: CGFloat = 0
    
    fileprivate
    var cancellers: Set<AnyCancellable> = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func draw(_ rect: CGRect) {
        let cgCtx = UIGraphicsGetCurrentContext()!
        
        cgCtx.saveGState()
//        cgCtx.setFillColor(UIColor.lightGray.withAlphaComponent(0.2).cgColor)
//        cgCtx.fill(rect)
        cgCtx.restoreGState()
        cgCtx.saveGState()
        
        let w = self.bounds.width
        let h = self.bounds.height
        
        cgCtx.beginPath()
        
        cgCtx.setStrokeColor(UIColor.gray.cgColor)
        cgCtx.setLineWidth(1.0)
        
        for idx in 0...15 {
            let col = gridSize * CGFloat(idx)
            if col > w {
                break;
            }
            cgCtx.move(to: CGPoint(x: col, y: 0))
            cgCtx.addLine(to: CGPoint(x: col, y: h))
        }
        
        for idx in 0...15 {
            let row = gridSize * CGFloat(idx)
            if row > h {
                break;
            }
            cgCtx.move(to: CGPoint(x: 0, y: row))
            cgCtx.addLine(to: CGPoint(x: w, y: row))
        }
        
        cgCtx.strokePath()
        
        cgCtx.restoreGState()
    }
}

extension GridView {
    fileprivate func commonInit() {
        clipsToBounds = true
        
        gridSize = bounds.width / 15.0
        
        publisher(for: \GridView.bounds, options: .new).sink { [weak self] bounds in
            self?.gridSize = bounds.width / 15.0
            self?.setNeedsDisplay()
        }.store(in: &cancellers)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.0)
    }
}
