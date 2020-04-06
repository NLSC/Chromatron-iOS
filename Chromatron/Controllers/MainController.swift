//
//  MainController.swift
//  Chromatron
//
//  Created by SwanCurve on 03/26/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit
import Combine

let panelHeight: CGFloat = 120
let panelEdge: CGFloat = 20


@objc
class MainController: UIViewController {
    
    var hud: HUDController?
    var content: ViewController?
    var panel: PanelController?
    
    var collector: Set<AnyCancellable> = []
    var levelSelectCanceller: AnyCancellable?
    
    @IBOutlet var hudView: UIView!
    
    var placeCoordinator: PlaceCoordinator!
    var placeCollector: Set<AnyCancellable> = []
    
    //
    var levelManager: LevelManager!
    
    private var _impactFeedback: Any?
    @available(iOS 10.0, *)
    private var impactFeedback: UIImpactFeedbackGenerator {
        if _impactFeedback == nil {
            _impactFeedback = UIImpactFeedbackGenerator(style: .light)
        }
        return _impactFeedback as! UIImpactFeedbackGenerator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .darkGray
        
        levelManager = LevelManager()
        
        prepareContent()
        preparePanel()
        
        prepareEvents()
        
        selectLevel(0)
        hud?.level = 0
        hud?.prevEnabled = false
        hud?.nextEnabled = levelManager.levelAvailable(1)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.bringSubviewToFront(hudView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "S_VC_HUD":
            prepareHUD(segue.destination as? HUDController)
        default:
            break
        }
    }
    
    override func viewSafeAreaInsetsDidChange() {
    }
    
    func selectLevel(_ level: Int) {
        let level = levelManager.level(level)!
        
        content?.setGraph(level.placed.map { $0.copy() as! Responsible })
        
        panel?.setContent(level.availableSimple.map { ($0.item.copy() as! Responsible, $0.count) })
    }
}


// MARK: prepare views & controllers
fileprivate
extension MainController {
    func preparePanel() {
        panel = PanelController()
        guard let panel = panel else {
            assert(false)
            popError(message: "\(#file).\(#line) #\(#function)")
            return
        }
        view.addSubview(panel.view)
        
        // constraints
        let guide = view.safeAreaLayoutGuide
        panel.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            panel.view.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 0),
            panel.view.heightAnchor.constraint(equalToConstant: panelHeight),
            panel.view.widthAnchor.constraint(equalTo: guide.widthAnchor, constant: 0),
            panel.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        addChild(panel)
        didMove(toParent: self)
    }

    func prepareHUD(_ hud: HUDController?) {
        guard let hud = hud else {
            assert(false)
            popError(message: "\(#file).\(#line) #\(#function)")
            return
        }
        
        self.hud = hud
        
        // events
        hud.nextLevelPublisher.sink { [weak self] _ in
            guard let sself = self else {
                return
            }
            if sself.levelManager.levelAvailable(sself.hud!.level + 1) {
                sself.hud!.level += 1
                sself.hud!.prevEnabled = sself.levelManager.levelAvailable(sself.hud!.level - 1)
                sself.hud!.nextEnabled = sself.levelManager.levelAvailable(sself.hud!.level + 1)
                
                sself.selectLevel(sself.hud!.level)
            }
        }.store(in: &collector)
        
        hud.prevLevelPublisher.sink { [weak self] _ in
            guard let sself = self else {
                return
            }
            if sself.levelManager.levelAvailable(sself.hud!.level - 1) {
                sself.hud!.level -= 1
                sself.hud!.prevEnabled = sself.levelManager.levelAvailable(sself.hud!.level - 1)
                sself.hud!.nextEnabled = sself.levelManager.levelAvailable(sself.hud!.level + 1)
                
                sself.selectLevel(sself.hud!.level)
            }
        }.store(in: &collector)
        
        hud.levelPublisher.sink { [weak self] _ in
            guard let sself = self else {
                return
            }

            let config = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "config") as! ConfigController
            config.modalPresentationStyle = .overFullScreen
            
            config.levels = self?.levelManager.levels ?? []
            config.levels[sself.hud!.level].current = true
            
            sself.present(config, animated: true)
            
            sself.levelSelectCanceller = config.levelSelectionPublisher.sink { [weak self] indexPath in
                self?.selectLevel(indexPath.item)
                self?.hud?.level = indexPath.item
                config.dismiss(animated: true) {
                    self?.levelSelectCanceller = nil
                }
            }
        }.store(in: &collector)
    }

    func prepareContent() {
        content = ViewController()
        guard let content = content else {
            assert(false)
            popError(message: "\(#file).\(#line) #\(#function)")
            return
        }
        
        // constraints
        view.addSubview(content.view)
        
        addChild(content)
        didMove(toParent: self)
    }
    
    func prepareEvents() {
        placeCoordinator = PlaceCoordinator(container: self, content: content!, panel: panel!)
        
        // from panel
        panel!.longPressPublisher.filter { $0.state == .began } .sink { [weak self] _ in
            guard let sself = self else {
                return
            }
            
            if #available(iOS 10.0, *) {
                sself.impactFeedback.prepare()
                sself.impactFeedback.impactOccurred()
            }
            
            var context = try! sself.panel!.popPlaceData()
            context.start = sself.view.convert(context.start, from: sself.panel!.view)
            context.view.bounds.size = sself.view.convert(sself.content!.gridRect, from: sself.content!.view).size
            sself.placeCoordinator.context = context
            
            sself.panel!.longPressPublisher.filter { $0.state == .changed } .sink {
                try! sself.placeCoordinator.gestureChanged($0.gesture)
            }.store(in: &sself.placeCoordinator.collector)
            
            sself.panel!.longPressPublisher.filter { $0.state == .ended } .sink {
                try! sself.placeCoordinator.placeEnd($0.gesture)
            }.store(in: &sself.placeCoordinator.collector)
            
            sself.panel!.longPressPublisher.filter { $0.state == .cancelled } .sink {
                try! sself.placeCoordinator.placeCancelled($0.gesture)
            }.store(in: &sself.placeCoordinator.collector)
            
        }.store(in: &placeCollector)
        
        // from grid
        content!.longPressPublisher.filter { $0.state == .began } .sink { [weak self] _ in
//            Swift.print("moving from grid")
            guard let sself = self else {
                return
            }
            
            if #available(iOS 10.0, *) {
                sself.impactFeedback.prepare()
                sself.impactFeedback.impactOccurred()
            }
            
            var context = try! sself.content!.popPlaceData()
            context.start = sself.view.convert(context.start, from: sself.content!.view)
            context.view.bounds.size = sself.view.convert(sself.content!.gridRect, from: sself.content!.view).size
            sself.placeCoordinator.context = context
            
            sself.content!.longPressPublisher.filter { $0.state == .changed } .sink {
                try! sself.placeCoordinator.gestureChanged($0.gesture)
            }.store(in: &sself.placeCoordinator.collector)
            
            sself.content!.longPressPublisher.filter { $0.state == .ended } .sink {
                try! sself.placeCoordinator.placeEnd($0.gesture)
            }.store(in: &sself.placeCoordinator.collector)
            
            sself.content!.longPressPublisher.filter { $0.state == .cancelled } .sink {
                try! sself.placeCoordinator.placeCancelled($0.gesture)
            }.store(in: &sself.placeCoordinator.collector)
            
        }.store(in: &placeCollector)
    }
}


// MARK: other initialization
fileprivate
extension MainController {
    
}
