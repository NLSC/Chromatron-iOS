//
//  Transition.swift
//  Chromatron
//
//  Created by SwanCurve on 03/28/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Transition &Animation
class TransitionManager: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Animator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return Interactor()
    }
}

class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.75
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) as? ConfigController,
            let _ = transitionContext.viewController(forKey: .from) as? MainController else {
                assert(false)
                popError(message: "\(#file).\(#line) #\(#function)")
                return
        }
        
        transitionContext.containerView.addSubview(toVC.view)
        toVC.view.alpha = 0
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: {
                        // animations
                        toVC.view.alpha = 1
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    
}

class Interactor: UIPercentDrivenInteractiveTransition {
}
