//
//  ViewController.swift
//  Chromatron
//
//  Created by SwanCurve on 03/10/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit
import Combine

protocol ReusableView {
    func prepareForReuse()
}

fileprivate
struct ReuseViewManager<T: UIView> where T: ReusableView {
    var queue: [T] = []
    var inUse: [T] = []
    
    mutating func dequeue() -> T {
        if queue.isEmpty {
            let v = T()
            inUse.append(v)
            return v
        }
        let v = queue.popLast()!
        v.prepareForReuse()
        inUse.append(v)
        return v
    }
    
    mutating func cycleAll() {
        inUse.forEach { $0.removeFromSuperview() }
        queue.append(contentsOf: inUse)
        inUse.removeAll()
    }
    
    private mutating func enqueue(_ view: T) {
        assert(view.superview != nil)
        view.removeFromSuperview()
        queue.append(view)
    }
}

fileprivate
extension CGPoint {
    func offset(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y + y)
    }
}


//  MARK: - ViewController
class ViewController: UIViewController {

    var bg: GridView?
    
    var scrollView: UIScrollView?
    
    var graph: Graph!
    
    var beamViewsQueue: [BeamView] = []
    
    private var itemMoving: PlaceData?
    
    lazy var longPressGesture: UILongPressGestureRecognizer = {
        let g = UILongPressGestureRecognizer()
        g.numberOfTouchesRequired = 1
        g.numberOfTapsRequired = 0
        g.delegate = self
        return g
    } ()
    var longPressPublisher: AnyPublisher<(gesture: UILongPressGestureRecognizer, state: UIGestureRecognizer.State), Never> {
        longPressGesture.publisher
    }
    
    private var beamViews: ReuseViewManager<BeamView> = ReuseViewManager()
    
    private var loc2ActiveViews: [Point : UIView] = [:]
    private var loc2FixedViews: [Point : UIView] = [:]
    
    private var elementsFixed: [Responsible] = []
    private var elementsActive: [Responsible] = []
    
    private var item2View: [(item: Responsible, view: UIView)] = []
    
    private var unit: CGFloat = 0
    
    private var indicator: (view: UIView, location: Point, placed: Bool)!
    private var inMoving: (index: Int, item: Responsible, view: UIView)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        graph = Graph(width: 15, height: 15, concurrent: false)
    }
    
    func setGraph(_ elements: [Responsible], _ placed: [Responsible] = []) {
        
        // reset
        elementsFixed.removeAll()
        elementsActive.removeAll()
        
        loc2FixedViews.forEach { $0.value.removeFromSuperview() }
        loc2FixedViews.removeAll()
        
        loc2ActiveViews.forEach { $0.value.removeFromSuperview() }
        loc2ActiveViews.removeAll()
        
        item2View.removeAll()
        
        beamViews.cycleAll()
        
        //
        elementsFixed = elements
        elementsActive = placed
        
        resetGraph()
    }
    
    private func resetGraph() {
        
        var elements = elementsFixed
        for el in elements {
            guard let view = el.view else {
                assert(false)
                popError(message: "\(#file).\(#line) #\(#function)")
                return
            }
            view.center = CGPoint(x: CGFloat(el.location!.x) * unit + unit / 2,
                                  y: CGFloat(15 - el.location!.y) * unit - unit / 2)
            view.bounds.size = CGSize(width: unit, height: unit)
            
            loc2FixedViews[el.location!] = view
            
            item2View.append((el, view))
        }
        
        elements = elementsActive
        for el in elements {
            guard let view = el.view else {
                assert(false)
                popError(message: "\(#file).\(#line) #\(#function)")
                return
            }
            view.center = CGPoint(x: CGFloat(el.location!.x) * unit + unit / 2,
                                  y: CGFloat(15 - el.location!.y) * unit - unit / 2)
            view.bounds.size = CGSize(width: unit, height: unit)
            
            loc2ActiveViews[el.location!] = view
            
            item2View.append((el, view))
        }
        
        updateGraph()
    }
    
    func place(item: Responsible, at location: CGPoint) {
        
        let bgLocation = optimizedLocationFrom(bg!.convert(location, from: view))
        
        let p = Point(x: Int(floor(bgLocation.x / unit)),
                      y: 14 - Int(floor(bgLocation.y / unit)))
        
//        Swift.print("placed at \(p)")
        
        let item = item.copy() as! Responsible
        item.location = p
        item.angle = .deg0
        
        setGraph(elementsFixed, elementsActive + [item])
    }
    
    private func updateGraph() {
        let elements = elementsFixed + elementsActive
        
        graph.elements = elements
        
        // debug
        if false {
            graph.printAdjacencyList()
            graph.printRespondChain()
            graph.printGraph()
            graph.printBeamList()
        }
        
        let beams = graph.beams
        beamViews.cycleAll()
        
        if let bg = bg {
            for beam in beams {
                let view = beamViews.dequeue()
                view.unit = unit
                view.beam = beam
                view.frame = CGRect(x: CGFloat(min(beam.p1.x, beam.p2.x)) * unit,
                                    y: CGFloat(14 - max(beam.p1.y, beam.p2.y)) * unit,
                                    width: CGFloat(abs(beam.p1.x - beam.p2.x) + 1) * unit,
                                    height: CGFloat(abs(beam.p1.y - beam.p2.y) + 1) * unit)
                bg.addSubview(view)
            }
        }
        
        for (_, view) in item2View {
            bg?.addSubview(view)
        }
    }

    @objc
    func handleGridTap(_ gesture: UIGestureRecognizer) {
        let loc = gesture.location(in: bg!)
        
        let point = Point(x: Int(floor(loc.x / unit)), y: 15 - Int(floor(loc.y / unit)) - 1)
        
        var tapped = elementsFixed.first { $0.location == point }
        if tapped != nil {
            return
            let view = loc2FixedViews[point]!
            
            tapped!.angle += .deg45
            view.rotate(angle: CGFloat(Angle.deg45.rawValue))
            
            updateGraph()
            
            return
        }
        
        tapped = elementsActive.first { $0.location == point }
        if tapped != nil {
            let view = loc2ActiveViews[point]!
            
            tapped!.angle += .deg45
            view.rotate(angle: CGFloat(Angle.deg45.rawValue))
            
            updateGraph()
            return
        }
    }
}

// MARK: - actions
extension ViewController {
    var gridRect: CGRect {
        return view.convert(CGRect(origin: .zero, size: CGSize(width: unit, height: unit)), from: bg!)
    }
    
    func optimizedLocationFrom(_ location: CGPoint) -> CGPoint {
        return location.offset(x: -unit, y: -unit)
    }
    
    func convertIndicatorLocationFrom(_ location: CGPoint) -> CGPoint? {
        let loc = optimizedLocationFrom(bg!.convert(location, from: view))
        let p = CGPoint(x: (floor(loc.x / unit) + 0.5) * unit,
                        y: (floor(loc.y / unit) + 0.5) * unit)
        
        let gloc = Point(x: Int(floor(loc.x / unit)),
                         y: 14 - Int(floor(loc.y / unit)))
        guard !elementsFixed.contains(where: { $0.location == gloc }) else {
            return nil
        }
        
        return view.convert(p, from: bg!)
    }
    
    func insideGrid(_ gesture: UIGestureRecognizer) -> Bool {
        guard let bg = bg else {
            assert(false)
            popError(message: "\(#file).\(#line) #\(#function)")
            return false
        }
        return bg.bounds.contains(gesture.location(in: bg))
    }
    
    func hovering(_ gesture: UIGestureRecognizer) {
        guard let bg = bg else {
            assert(false)
            popError(message: "\(#file).\(#line) #\(#function)")
            return
        }
        let locationOnGrid = optimizedLocationFrom(gesture.location(in: bg))
        let inside = bg.bounds.contains(locationOnGrid)
        guard inside else {
            if indicator.placed {
                dismissIndicator()
            }
            return
        }
        
        let x = Int(floor(locationOnGrid.x / unit))
        let y = Int(floor(locationOnGrid.y / unit))
        
        if !indicator.placed {
            bg.addSubview(indicator.view)
            indicator.placed = true
        } else {
            let point = Point(x: x, y: 14 - y)
            if elementsFixed.contains(where: { $0.location == point }) ||
                elementsActive.contains(where: { $0.location == point }) {
                indicator.view.isHidden = true
            } else if indicator.view.isHidden {
                indicator.view.isHidden = false
            }
        }
        indicator.view.frame.origin = CGPoint(x: unit * CGFloat(x), y: unit * CGFloat(y))
    }
    
    func placeAvailable(_ location: CGPoint) -> Bool {
        let bgLoc = optimizedLocationFrom(bg!.convert(location, from: view)) 
        guard bg!.bounds.contains(bgLoc) else {
            return false
        }
        let point = Point(x: Int(floor(bgLoc.x / unit)),
                          y: 14 - Int(floor(bgLoc.y / unit)))
        guard !elementsFixed.contains(where: { $0.location == point }) &&
            !elementsActive.contains(where: { $0.location == point}) else {
            return false
        }
        return true
    }
    
    func placeEnd() {
        if inMoving != nil {
            inMoving = nil
        }
        dismissIndicator()
    }
    
    func placeCancelled() {
        if let inMoving = inMoving {
            elementsActive.insert(inMoving.item, at: inMoving.index)
            bg!.addSubview(inMoving.view)
            item2View.append((inMoving.item, inMoving.view))
            self.inMoving = nil
        }
        
        dismissIndicator()
    }
    
    private func dismissIndicator() {
        indicator.view.removeFromSuperview()
        indicator.location = .invalid
        indicator.placed = false
    }
}

extension ViewController {
    func saveState() {
        
    }
    
    func restoreState() {
        
    }
}

// MARK: - UIScrollViewDelegate
extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return bg
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
        
        bg!.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX,
                             y: scrollView.contentSize.height * 0.3 + offsetY);
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ViewController: UIGestureRecognizerDelegate {
    private func pushPlaceData(_ placeData: PlaceData) {
        self.itemMoving = placeData
    }
    
    func popPlaceData() throws -> PlaceData {
        guard let itemMoving = itemMoving else {
            throw GlobalError.impossibleError
        }
        defer {
            self.itemMoving = nil
        }
        return itemMoving
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === longPressGesture else {
            return false
        }
        
        let location = gestureRecognizer.location(in: bg!)
        let point = Point(x: Int(floor(location.x / unit)), y: 15 - Int(floor(location.y / unit)) - 1)
        
        if let selectedIndex = elementsActive.firstIndex(where: { $0.location == point }) {
            let selected = elementsActive[selectedIndex]
            let i = item2View.firstIndex(where: { $0.item === selected })!
            let itemView = item2View[i].view
            itemView.removeFromSuperview()
            inMoving = (selectedIndex, selected, itemView)
            elementsActive.remove(at: selectedIndex)
            item2View.remove(at: i)
            
            pushPlaceData(PlaceData(view: {
                let v = selected.icon
                return v
            } (), type: selected.copy() as! Responsible, start: itemView.convert(location, from: bg!)))
            return true
        }
        return false
    }
}


// MARK: - init
extension ViewController {
    func setup() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        // scroll view
        scrollView = UIScrollView(frame: CGRect(origin: CGPoint.zero, size: view.frame.size))
        guard let scrollView = scrollView else {
            return
        }
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        scrollView.delegate = self
        
        scrollView.maximumZoomScale = 1.0
        scrollView.minimumZoomScale = view.bounds.width / view.bounds.height
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.alwaysBounceVertical = true
        
        scrollView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        
        scrollView.decelerationRate = .init(rawValue: 0.6)
        
        // scene
        bg = GridView(frame: CGRect(x: 0, y: 0, width: view.frame.height, height: view.frame.height))
            
        scrollView.addSubview(bg!)
        scrollView.contentSize = bg!.frame.size
        
        bg!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGridTap(_:))))
        bg!.addGestureRecognizer(longPressGesture)
        
        unit = bg!.bounds.width / 15
        
        // indicator
        let v = UIView(frame: CGRect(x: 0, y: 0, width: unit, height: unit))
        v.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        indicator = (v,  Point(x: -1, y: -1), false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollView!.setZoomScale(scrollView!.minimumZoomScale, animated: false)
    }
}
