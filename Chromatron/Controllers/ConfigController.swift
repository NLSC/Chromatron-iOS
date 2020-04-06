//
//  ConfigController.swift
//  Chromatron
//
//  Created by SwanCurve on 03/28/20.
//  Copyright © 2020 SwanCurve. All rights reserved.
//

import Foundation
import UIKit
import Combine


// MARK: - Combine Extension
fileprivate
typealias SelectionHandler = (IndexPath) -> ()

fileprivate
extension Publishers {
    struct _CollectionViewSelect: Publisher {
        typealias Output = IndexPath
        typealias Failure = Never
        
        private var connect: ((@escaping SelectionHandler) -> Void)?
        private var disconnect: (() -> Void)?
        
        init(connect: @escaping (@escaping SelectionHandler) -> Void, disconnect: @escaping () -> Void) {
            self.connect = connect
            self.disconnect = disconnect
        }
        
        func receive<S: Subscriber>(subscriber: S) where S.Failure == Failure, S.Input == Output {
            let subscription = SubScription(subscriber: subscriber, connect: connect!, disconnect: disconnect!)
            
            subscriber.receive(subscription: subscription)
        }
    }
}

fileprivate
extension Publishers._CollectionViewSelect {
    private final class SubScription<S: Subscriber>: Combine.Subscription
    where S.Input == IndexPath {
        
        private var subscriber: S?
        
        private let disconnect: () -> Void
    
        init(subscriber: S, connect: @escaping (@escaping SelectionHandler) -> Void, disconnect: @escaping () -> Void) {
            self.subscriber = subscriber
            self.disconnect = disconnect
            connect { [weak self] in _ = self?.subscriber?.receive($0) }
        }
        
        func request(_ demand: Subscribers.Demand) {
        }
        
        func cancel() {
            subscriber = nil
            disconnect()
        }
    }
}


// MARK: - LevelData
@objc
class ConfigData: NSObject, UICollectionViewDataSource {
    var itemSize: CGSize = .zero
    
    var levels: [LevelInfo] = []
    
    fileprivate
    var selectHandler: SelectionHandler?
    
    lazy var selectPublisher: AnyPublisher<IndexPath, Never> = {
        Publishers._CollectionViewSelect(connect: { [weak self] handler in
            self?.selectHandler = handler
        }, disconnect: { [weak self] in
            self?.selectHandler = nil
        }).eraseToAnyPublisher()
    } ()
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section == 0 else {
            assert(false)
            popError(message: "\(#file).\(#line) #\(#function)")
            return 0
        }
        return levels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCell", for: indexPath) as! LevelCollectionViewCell
        cell.level = indexPath.item + 1
        
        let info = levels[indexPath.item]
        cell.locked = info.locked
        cell.current = info.current
        
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension ConfigData: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectHandler?(indexPath)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ConfigData: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: floor(collectionView.bounds.width/5) - 2,
                      height: floor(collectionView.bounds.width/5) - 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return  .zero
    }
}

// MARK: -  ConfigController
@objc
class ConfigController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var dataSource: ConfigData!
    
    private var collector: Set<AnyCancellable> = []
    
    var levels: [LevelInfo] = []
    
    var levelSelectionPublisher: AnyPublisher<IndexPath, Never> {
        dataSource.selectPublisher
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.levels = levels
        
        view.backgroundColor = UIColor().withAlphaComponent(0)
        collectionView.backgroundColor = UIColor().withAlphaComponent(0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}


// MARK: - LevelCollectionViewCell
class LevelCollectionViewCell: UICollectionViewCell {
    
    var level: Int = 0 {
        didSet { levelLabel.text = "\(level)" }
    }
    
    var locked: Bool = false {
        didSet {
            updateStyle()
        }
    }
    
    var current: Bool = false {
        didSet {
            updateStyle()
        }
    }
    
    @IBOutlet private weak var levelLabel: UILabel!
    @IBOutlet private weak var container: UIView!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        commonSetup()
    }
    
    private func commonSetup() {
        contentView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        levelLabel.backgroundColor = .transparent
        container.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }
    
    private func updateStyle() {
        if current {
            levelLabel.textColor = .darkGray
        } else if locked {
            levelLabel.textColor = .lightGray
        } else {
            levelLabel.textColor = .black
        }
        
        if current {
            container.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        } else if locked {
            container.backgroundColor = .transparent
        } else {
            container.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        }
        
        if current {
            contentView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        } else if locked {
            contentView.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
        } else {
            contentView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
