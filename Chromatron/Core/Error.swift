//
//  Error.swift
//  Chromatron
//
//  Created by SwanCurve on 03/31/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit

enum GlobalError: Error {
    case impossibleError
}

func popError(message: String) {
//    let keyWindow = UIApplication.shared.connectedScenes.filter {
//        $0.activationState == .foregroundActive
//    } .map{
//        $0 as? UIWindowScene
//    } .compactMap {
//        $0
//    } .first?.windows.filter { $0.isKeyWindow } .first
    if let keyWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        keyWindow.rootViewController?.present(alert, animated: true)
    }
}
