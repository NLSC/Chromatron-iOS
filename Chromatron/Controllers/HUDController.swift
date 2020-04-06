//
//  HUDController.swift
//  Chromatron
//
//  Created by SwanCurve on 03/28/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit
import Combine

class HUDController: UIViewController {
    
    // next level button
    @IBOutlet var nextBtn: UIView!
    @IBOutlet private var nextImage: UIImageView!
    private let nextGesture = UITapGestureRecognizer()
    var nextLevelPublisher: AnyPublisher<UITapGestureRecognizer, Never> {
        nextGesture.tapPublisher.map { $0.gesture }.eraseToAnyPublisher()
    }
    
    // previous level button
    @IBOutlet var prevBtn: UIView!
    @IBOutlet private var prevImage: UIImageView!
    private let prevGesture = UITapGestureRecognizer()
    var prevLevelPublisher: AnyPublisher<UITapGestureRecognizer, Never> {
        prevGesture.tapPublisher.map { $0.gesture }.eraseToAnyPublisher()
    }
    
    @IBOutlet var labelContainer: UIView!
    @IBOutlet var label: UILabel!
    private let levelGesture = UITapGestureRecognizer()
    var levelPublisher: AnyPublisher<UITapGestureRecognizer, Never> {
        levelGesture.tapPublisher.map{ $0.gesture }.eraseToAnyPublisher()
    }
    
    var level: Int = 0 {
        didSet {
            label.text = "\(level + 1)"
        }
    }
    
    // button style
    private lazy var lightArrow = UIImage(named: "arrow-light")
    private lazy var darkArrow = UIImage(named: "arrow-dark")
    var nextEnabled: Bool = false {
        didSet {
            if oldValue != nextEnabled {
                nextImage.image = nextEnabled ? lightArrow : darkArrow
                nextImage.setNeedsDisplay()
            }
        }
    }
    var prevEnabled: Bool = false {
        didSet {
            if oldValue != prevEnabled {
                prevImage.image = prevEnabled ? lightArrow : darkArrow
                prevImage.setNeedsDisplay()
            }
        }
    }
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor().withAlphaComponent(0)
        
        prevBtn.transform = .init(rotationAngle: CGFloat.pi)
        
        labelContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        labelContainer.layer.cornerRadius = 10
        labelContainer.layer.masksToBounds = true
        labelContainer.addGestureRecognizer(levelGesture)
        
        prevImage.image = darkArrow
        nextImage.image = darkArrow
        
        nextBtn.addGestureRecognizer(nextGesture)
        prevBtn.addGestureRecognizer(prevGesture)
    }
}
