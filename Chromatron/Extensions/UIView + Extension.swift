//
//  UIView + Extension.swift
//  Chromatron
//
//  Created by SwanCurve on 03/30/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func rotate(angle: CGFloat) {
        self.transform = self.transform.rotated(by: -angle / 180 * .pi)
    }
}
