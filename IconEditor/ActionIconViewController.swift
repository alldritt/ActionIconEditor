//
//  ActionIconViewController.swift
//  IconEditor
//
//  Created by Mark Alldritt on 2020-06-21.
//  Copyright © 2020 Mark Alldritt. All rights reserved.
//

import UIKit
import Eureka
import PAPlaceholder


class ActionIconViewController: UIViewController {
    
    var action: ActionKit.Action? {
        didSet {
            previewView.action = action
            (viewControllers[0] as! ActionIconColorViewController).action = action
            (viewControllers[1] as! ActionIconGlyphViewController).action = action
            
            if let actionObserver = actionObserver {
                NotificationCenter.default.removeObserver(actionObserver)
                self.actionObserver = nil
            }
            if let action = action {
                actionObserver = NotificationCenter.default.addObserver(forName: ActionKit.Action.ChaneNotification,
                                                                        object: action,
                                                                        queue: nil,
                                                                        using: { (notification) in
                                                                            print("changed")
                })
            }
        }
    }
    
    private var actionObserver: NSObjectProtocol?
    private var topView = UIView()
    private let previewView = ActionKit.PreviewView()
    private var bottomView = UIView()
    private var segmentedControl = UISegmentedControl()
    fileprivate let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    fileprivate let viewControllers: [UIViewController] = [ActionIconColorViewController(), ActionIconGlyphViewController()]
    fileprivate var selectedIndex: Int = 0

    deinit {
        #if DEBUG
        print("deinit ActionIconViewController")
        #endif
        action = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //  Allow swipe-down dismissal
        isModalInPresentation = false

        navigationItem.title = "Icon"
        navigationController?.toolbar.isOpaque = true
        view.backgroundColor = .systemBackground
        
        previewView.action = action
        (viewControllers[0] as! ActionIconColorViewController).action = action
        (viewControllers[1] as! ActionIconGlyphViewController).action = action

        topView.backgroundColor = .secondarySystemBackground
        topView.addSubview(previewView)
        view.addSubview(topView)
        
        segmentedControl.insertSegment(withTitle: "Color", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Glyph", at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentControlValueChanged), for: .valueChanged)
        bottomView.addSubview(segmentedControl)
        
        view.addSubview(bottomView)

        pageViewController.setViewControllers([viewControllers[segmentedControl.selectedSegmentIndex]],
                                              direction: .forward,
                                              animated: false,
                                              completion: nil)
        addChild(pageViewController)
        bottomView.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let safeArea = view.bounds.inset(by: view.safeAreaInsets)
        let topHeight = CGFloat(300)
        let topFrame = CGRect(origin: safeArea.origin,
                              size: CGSize(width: safeArea.width, height: topHeight))
        topView.frame = topFrame
        
        let size = CGFloat(130)
        let previewFrame = CGRect(origin: CGPoint.zero,
                                  size: CGSize(width: size,
                                               height: size)).offsetBy(dx: (topFrame.width - size) / 2,
                                                                       dy: (topFrame.height - size) / 2)
        previewView.frame = previewFrame
        
        let bottomFrame = CGRect(origin: CGPoint(x: safeArea.origin.x, y: topFrame.maxY),
                                 size: CGSize(width: safeArea.width, height: safeArea.maxY - topFrame.maxY))
        bottomView.frame = bottomFrame
        
        let segmentedHeight = CGFloat(32)
        let segmentedWidth = CGFloat(250)
        let segmentedSpace = CGFloat(3)
        
        let segmentedFrame = CGRect(origin: CGPoint.zero,
                                    size: CGSize(width: segmentedWidth,
                                                 height: segmentedHeight)).offsetBy(dx: (bottomFrame.width - segmentedWidth) / 2, dy: segmentedSpace)
        segmentedControl.frame = segmentedFrame

        let pagesFrame = CGRect(origin: CGPoint(x: 0, y: segmentedHeight + segmentedSpace * 2),
                                size: CGSize(width: bottomFrame.width,
                                             height: bottomFrame.height - (segmentedHeight + segmentedSpace * 2)))
        pageViewController.view.frame = pagesFrame
    }
    
    @objc
    private func segmentControlValueChanged() {
        let selectedIndex = self.selectedIndex
        
        if segmentedControl.selectedSegmentIndex > selectedIndex {
            let nextIndex = selectedIndex + 1
            for index in nextIndex...segmentedControl.selectedSegmentIndex {
                setViewController(atIndex: index, direction: .forward)
            }
        } else if segmentedControl.selectedSegmentIndex < selectedIndex {
            let previousIndex = selectedIndex - 1
            for index in (segmentedControl.selectedSegmentIndex...previousIndex).reversed() {
                setViewController(atIndex: index, direction: .reverse)
            }
        }
        self.selectedIndex = segmentedControl.selectedSegmentIndex
    }

    private func setViewController(atIndex index: Int, direction: UIPageViewController.NavigationDirection) {
        pageViewController.setViewControllers([viewControllers[index]], direction: direction, animated: true) { [weak self] completed in
            guard let me = self else {
                return
            }
            if completed {
                me.selectedIndex = index
            }
        }
    }

}



class ActionIconColorViewController: UIViewController {
    
    var action: ActionKit.Action? {
        didSet {
            if isViewLoaded {
                paletteView.color = action?.color ?? ActionKit.colors[0]
            }
        }
    }
    var paletteView: PaletteView!
    
    deinit {
        #if DEBUG
        print("deinit ActionIconColorViewController")
        #endif
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        paletteView = PaletteView()
        paletteView.color = action?.color ?? ActionKit.colors[0]
        paletteView.changed = { [unowned self] (newColor) in
            self.action?.color = newColor
        }
        view.addSubview(paletteView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let area = view.bounds.inset(by: view.safeAreaInsets)
        let size = CGFloat(60)
        let width = 5 * size
        let height = 3 * size
        let frame = CGRect(x: (area.width - width) / 2,
                           y: (area.height - height) / 2,
                           width: width, height: height)
        
        paletteView.frame = frame
    }
}


class ActionGlyphCell: UICollectionViewCell {
    var swatchView : UIImageView
    
    override init(frame: CGRect) {
        swatchView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: frame.size).insetBy(dx: 8, dy: 8))
        swatchView.tintColor = .systemGray
        swatchView.contentMode = .scaleAspectFit
        
        super.init(frame: frame)
        
        contentView.addSubview(swatchView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var glyphName: String = "" {
        didSet {
            swatchView.image = UIImage(systemName: glyphName)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            guard isSelected != oldValue else { return }
            
            if isSelected {
                contentView.layer.backgroundColor = UIColor.secondarySystemFill.cgColor
                contentView.layer.cornerRadius = 8
                contentView.layer.masksToBounds = true
            }
            else {
                contentView.layer.backgroundColor = UIColor.clear.cgColor
            }
        }
    }
}


extension ActionKit {
    
    class GlyphPalette {
        public let name : String
        public let palette : [String]
        
        public init(name: String, palette: [String]) {
            self.name = name
            self.palette = palette
        }
    }

}

class ActionIconGlyphViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITabBarDelegate {
        
    public var palettes: [ActionKit.GlyphPalette] = [] {
        didSet {
            glyphsView.reloadData()
        }
    }

    var action: ActionKit.Action? {
        didSet {
            if isViewLoaded {
                glyphsView.selectItem(at: glyphIndexPath(), animated: false, scrollPosition: .centeredHorizontally)
            }
        }
    }
    var glyphsView: UICollectionView!
    var tabBar: UITabBar!
    
    deinit {
        #if DEBUG
        print("deinit ActionIconGlyphViewController")
        #endif
    }

    private func glyphIndexPath() -> IndexPath? {
        guard let action = action else { return nil }
        
        for (i, p) in palettes.enumerated() {
            if let index = p.palette.firstIndex(of: action.iconName) {
                return IndexPath(row: index, section: i)
            }
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let symbolsURL = Bundle.main.url(forResource: "SFSymbols", withExtension: "json") else { fatalError("SFSymbols.json missing") }
        guard let symbolsData = try? Data(contentsOf: symbolsURL) else { fatalError("cannot read SFSymbols.json") }
        guard let symbols = try? JSONSerialization.jsonObject(with: symbolsData, options: []) as? [String:[String]] else { fatalError("error reading SFSymbols.json") }

        tabBar = UITabBar()
        tabBar.isTranslucent = false
        tabBar.itemPositioning = .centered
        tabBar.delegate = self
        
        tabBar.items = [UITabBarItem(title: "Digits", image: UIImage(systemName: "1.square"), tag: 0),
                        UITabBarItem(title: "Letters", image: UIImage(systemName: "a.square"), tag: 1),
                        UITabBarItem(title: "Objects", image: UIImage(systemName: "cube.fill"), tag: 2),
                        UITabBarItem(title: "People", image: UIImage(systemName: "person.fill"), tag: 3),
                        UITabBarItem(title: "Symbols", image: UIImage(systemName: "slider.horizontal.3"), tag: 4)]
        view.addSubview(tabBar)
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        layout.itemSize = CGSize(width: 45, height: 45)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal

        glyphsView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        glyphsView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        glyphsView.translatesAutoresizingMaskIntoConstraints = false
        glyphsView.showsHorizontalScrollIndicator = true
        glyphsView.showsVerticalScrollIndicator = false
        glyphsView.backgroundColor = .clear
        glyphsView.allowsSelection = true
        glyphsView.allowsMultipleSelection = false
        glyphsView.register(ActionGlyphCell.self, forCellWithReuseIdentifier: "glyph")
        glyphsView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        glyphsView.delegate = self
        glyphsView.dataSource = self
        view.addSubview(glyphsView)
                
        palettes = [ActionKit.GlyphPalette(name: "Digits", palette: symbols["numbers"] ?? []),
                    ActionKit.GlyphPalette(name: "Letters", palette: symbols["letters"] ?? []),
                    ActionKit.GlyphPalette(name: "Objects", palette: symbols["objects"] ?? []),
                    ActionKit.GlyphPalette(name: "People", palette: symbols["people"] ?? []),
                    ActionKit.GlyphPalette(name: "Symbols", palette: symbols["other"] ?? [])]
        glyphsView.layoutIfNeeded()
        glyphsView.selectItem(at: glyphIndexPath(), animated: false, scrollPosition: .centeredHorizontally)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let tabBarHeight = CGFloat(53)
        let area = view.bounds.inset(by: view.safeAreaInsets)
        
        glyphsView.frame = CGRect(x: 0, y: 0, width:  area.width, height: area.height - tabBarHeight)
        tabBar.frame = CGRect(x: 0, y: area.height - tabBarHeight, width: area.width, height: tabBarHeight)
        
        if let selectedIndexPath = glyphsView.indexPathsForSelectedItems?.first {
            glyphsView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //  UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let palette = palettes[indexPath.section].palette
        let glyphName = palette[indexPath.row]

        action?.iconName = glyphName
        //baseRow.baseValue = newColor
        //swatchView.color = newColor
    }

    //  UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let indexPath = glyphsView.indexPathsForVisibleItems.first else { return }
        
        tabBar.selectedItem = tabBar.items?.first(where: { (item) in
            return item.tag == indexPath.section
        })
    }
    //  UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return palettes.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let palette = palettes[section].palette
        
        return palette.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "glyph", for: indexPath) as! ActionGlyphCell
        let palette = palettes[indexPath.section].palette
        let glyphName = palette[indexPath.row]
        
        cell.glyphName = glyphName
        return cell
    }
    
    /*
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let v = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath)
        
        if v.subviews.count == 0 {
            let label = UILabel(frame: CGRect(x: -36.0, y: 40.0, width: 96.0, height: 16.0))
            
            label.font = UIFont.systemFont(ofSize: 11.0)
            label.textAlignment = .center
            if #available(iOS 13.0, *) {
                label.textColor = UIColor.label
                label.backgroundColor = UIColor.systemGroupedBackground

            } else {
                label.textColor = UIColor.black
                label.backgroundColor = UIColor.init(white: 0.9, alpha: 1.0)
            }
            label.transform = CGAffineTransform(rotationAngle: (-90.0 * CGFloat.pi) / 180.0)
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 8.0
            label.tag = 1234
            
            v.addSubview(label)
        }
        
        if let label = v.viewWithTag(1234) as? UILabel {
            label.text = palettes[indexPath.section].name
        }
        
        return v
    }
    */
    
    //  UITabBarDelegate
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        glyphsView.scrollToItem(at: IndexPath(item: 0, section: item.tag), at: .left, animated: true)
    }

}
