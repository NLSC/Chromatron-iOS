//
//  BeamView.swift
//  Chromatron
//
//  Created by SwanCurve on 03/22/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit

@objc
class BeamView: UIView, ReusableView {
    var beam: Beam? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var unit: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white.withAlphaComponent(0.0)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private
    func converted() -> (p1: CGPoint, p2: CGPoint) {
        guard let beam = beam else {
            assert(false)
            popError(message: "\(#file).\(#line) #\(#function)")
            return (.zero, .zero)
        }
        let ori = Point(x: min(beam.p1.x, beam.p2.x), y: max(beam.p1.y, beam.p2.y))
        
        let p1_ = Point(x: beam.p1.x - ori.x, y: ori.y - beam.p1.y)
        let p2_ = Point(x: beam.p2.x - ori.x, y: ori.y - beam.p2.y)
        
        var p1 = CGPoint()
        var p2 = CGPoint()
        
        p1.x = CGFloat(p1_.x) * unit + 0.5 * unit
        p2.x = CGFloat(p2_.x) * unit + 0.5 * unit

        p1.y = CGFloat(p1_.y) * unit + 0.5 * unit
        p2.y = CGFloat(p2_.y) * unit + 0.5 * unit
    
        return (p1, p2)
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), let beam = beam else {
            return;
        }
        
        let (p1, p2) = converted()
        
        assert((p1.x > 0 && p1.x < rect.width) && (p2.x > 0 && p2.x < rect.width))
        assert((p1.y > 0 && p1.y < rect.height) && (p2.y > 0 && p2.y < rect.height))
                
        ctx.saveGState()
        
        // set ctx
        ctx.setStrokeColor(beam.color.color.cgColor)
        ctx.setLineWidth(2.0)
        ctx.setShadow(offset: .zero, blur: 5, color: beam.color.color.cgColor)
        
        // draw
        ctx.move(to: p1)
        ctx.addLine(to: p2)
        
        ctx.strokePath()
        
        ctx.restoreGState()
    }
    
    func prepareForReuse() {
        beam = nil
    }
}
