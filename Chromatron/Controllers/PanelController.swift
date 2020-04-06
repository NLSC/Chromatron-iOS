//
//  PanelController.swift
//  Chromatron
//
//  Created by SwanCurve on 03/28/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit
import Combine

struct PlaceData {
    let view: UIView
    let type: Responsible
    var start: CGPoint
}

let maxWidth: CGFloat = 40
let space: CGFloat = 20

// MARK: - PanelController
@objc
class PanelController: UIViewController {
    var panelView: UIView?
    
    private var contentsData: [(item: Responsible, count: Int, view: UIView)] = []
    
    lazy private var panGesture: UIPanGestureRecognizer = {
        let g = UIPanGestureRecognizer()
        g.maximumNumberOfTouches = 1
        g.minimumNumberOfTouches = 1
        return g
    } ()
    lazy var longPressGesture: UILongPressGestureRecognizer = {
        let g = UILongPressGestureRecognizer()
        g.numberOfTouchesRequired = 1
        g.numberOfTapsRequired = 0
        g.delegate = self
        return g
    } ()
    
    var panPublisher: AnyPublisher<(gesture: UIPanGestureRecognizer, state: UIPanGestureRecognizer.State), Never> {
        panGesture.panPublisher
    }
    
    var longPressPublisher: AnyPublisher<(gesture: UILongPressGestureRecognizer, state: UIGestureRecognizer.State), Never> {
        longPressGesture.publisher
    }
    
    private var itemPlacing: PlaceData?
    
    private
    var contents = UIView()
    
    private
    var currentItem: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panelView = UIView()
        
        try! initPanelView()
    }
}

extension PanelController {
    
    func setContent(_ availableResponsibles: [(item: Responsible, count: Int)]) {
        // clear
        for (_, _, view) in contentsData {
            view.removeFromSuperview()
        }
        contentsData.removeAll()
        try! updatePanelContent(availableResponsibles)
    }
    
    private func updatePanelContent(_ availableResponsibles: [(item: Responsible, count: Int)]) throws {
        var left: UIView?
        
        for (_, (item, count)) in availableResponsibles.enumerated() {
            let itemView = PanelItemView(frame: .zero, content: item.icon)
            itemView.count = count

            contents.addSubview(itemView)
            contentsData.append((item: item, count: count, view: itemView))
            
            itemView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                itemView.topAnchor.constraint(equalTo: contents.topAnchor),
                left != nil ? itemView.leadingAnchor.constraint(equalTo: left!.trailingAnchor, constant: space)
                    : itemView.leadingAnchor.constraint(equalTo: contents.leadingAnchor),
                itemView.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth),
                itemView.heightAnchor.constraint(equalTo: itemView.widthAnchor, constant: 20)
            ])
            
            left = itemView
        }
    }
    
    private func pushPlaceData(_ data: PlaceData) {
        itemPlacing = data
    }
    
    func popPlaceData() throws -> PlaceData {
        guard let itemPlacing = itemPlacing else {
            throw GlobalError.impossibleError
        }
        defer {
            self.itemPlacing = nil
        }
        return itemPlacing
    }
    
    func placeAvailable(_ location: CGPoint) -> Bool {
        let onPanel = view.bounds.contains(location)
//            contents.frame.contains(contents.convert(location, from: view))
        return onPanel
    }
    
    func recycleItem(_ item: Responsible) {
        if let index = contentsData.firstIndex(where: { type(of: $0.item) == type(of: item) }) {
            contentsData[index].count += 1
        } else {
            let itemView = PanelItemView(frame: .zero, content: item.icon)
            itemView.count = 1
            contents.addSubview(itemView)
            
            itemView.translatesAutoresizingMaskIntoConstraints = false
            if let last = contentsData.last {
                NSLayoutConstraint.activate([
                    itemView.topAnchor.constraint(equalTo: contents.topAnchor),
                    itemView.leadingAnchor.constraint(equalTo: last.view.trailingAnchor, constant: space),
                    itemView.widthAnchor.constraint(equalToConstant: maxWidth),
                    itemView.heightAnchor.constraint(equalTo: itemView.widthAnchor, constant: 20)
                ])
            } else {
                NSLayoutConstraint.activate([
                    itemView.topAnchor.constraint(equalTo: contents.topAnchor),
                    itemView.leadingAnchor.constraint(equalTo: contents.leadingAnchor),
                    itemView.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth),
                    itemView.heightAnchor.constraint(equalTo: itemView.widthAnchor, constant: 20)
                ])
            }
            contentsData.append((
                item: item.copy() as! Responsible,
                count: 1,
                view: itemView
            ))
        }
    }
    
    func placeCancelled() {
        if currentItem != nil {
            currentItem = nil
        }
    }
    
    func placeEnd() {
        if let currentItem = currentItem {
            let item = contentsData[currentItem]
            if item.count > 1 {
                (item.view as! PanelItemView).count = item.count - 1
                contentsData[currentItem].count -= 1
            } else {
                item.view.removeFromSuperview()
                contentsData.remove(at: currentItem)
            }
            self.currentItem = nil
        }
    }
}

extension PanelController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === longPressGesture {
            let location = gestureRecognizer.location(in: contents)
            
            if let selectedIndex = contentsData.firstIndex(where: { $0.view.frame.contains(location) }) {
            
                let selected = contentsData[selectedIndex]
                currentItem = selectedIndex
                
                pushPlaceData(PlaceData(view: {
                    let v = selected.item.icon
                    v.bounds = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
                    return v
                } (), type: selected.item, start: view.convert(location, from: contents)))
                
                return true
            }
            return false
        }
        return false
    }
}

extension PanelController {
    private func initPanelView() throws {
            guard let panelView = panelView else {
                throw GlobalError.impossibleError
            }
            
//            panelView.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
            panelView.translatesAutoresizingMaskIntoConstraints = false
//            panelView.layer.cornerRadius = 24
//            panelView.layer.masksToBounds = true
            panelView.layer.shadowColor = UIColor.gray.cgColor
            panelView.layer.shadowRadius = 4
            panelView.layer.shadowOffset = CGSize(width: 2, height: 4)
            panelView.layer.shadowOpacity = 0.6
            
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            blur.translatesAutoresizingMaskIntoConstraints = false
//            blur.layer.cornerRadius = 24
//            blur.layer.masksToBounds = true
            
            panelView.addSubview(blur)
            view.addSubview(panelView)
            
            panelView.addGestureRecognizer(panGesture)
            panelView.addGestureRecognizer(longPressGesture)
            
            NSLayoutConstraint.activate([
                panelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                panelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                panelView.topAnchor.constraint(equalTo: view.topAnchor),
                panelView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                blur.leadingAnchor.constraint(equalTo: panelView.leadingAnchor),
                blur.trailingAnchor.constraint(equalTo: panelView.trailingAnchor),
                blur.topAnchor.constraint(equalTo: panelView.topAnchor),
                blur.bottomAnchor.constraint(equalTo: panelView.bottomAnchor)
            ])
            
            contents.translatesAutoresizingMaskIntoConstraints = false
            panelView.addSubview(contents)
            NSLayoutConstraint.activate([
                contents.heightAnchor.constraint(equalToConstant: 60),
                contents.centerXAnchor.constraint(equalTo: panelView.centerXAnchor),
                contents.topAnchor.constraint(equalTo: panelView.topAnchor, constant: 0),
                contents.widthAnchor.constraint(equalTo: panelView.widthAnchor, constant: -40)
            ])
        }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}


// MARK: - PanelItemView

fileprivate
class PanelItemView: UIView {
    var content: UIView
    
    var count: Int = 0 {
        didSet { label.text = "\(count)" }
    }
    private var label = UILabel()
    
    init(frame: CGRect, content: UIView) {
        self.content = content
        super.init(frame: frame)
        initContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PanelItemView {
    private func initContents() {
        
        content.rotate(angle: -15)
//        content.setContentCompressionResistancePriority(.init(rawValue: 1000), for: .vertical)
        content.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: self.topAnchor),
            content.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            content.heightAnchor.constraint(equalTo: content.widthAnchor)
        ])
        
        label.text = "\(0)"
        label.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(greaterThanOrEqualTo: content.bottomAnchor, constant: 4.0),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4.0),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 20)
        ])
    }
}
