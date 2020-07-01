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
    fileprivate let viewControllers: [UIViewController] = [ActionIconColorViewController(), UIViewController()]
    fileprivate var selectedIndex: Int = 0

    deinit {
        action = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers[1].view.backgroundColor = .blue
        
        //  Prevent swipe-down dismissal
        isModalInPresentation = true

        navigationItem.title = "Icon"
        navigationController?.toolbar.isOpaque = true
        view.backgroundColor = .systemBackground
        
        previewView.action = action
        (viewControllers[0] as! ActionIconColorViewController).action = action

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
                self.setViewController(atIndex: index, direction: .forward)
            }
        } else if segmentedControl.selectedSegmentIndex < selectedIndex {
            let previousIndex = selectedIndex - 1
            for index in (segmentedControl.selectedSegmentIndex...previousIndex).reversed() {
                self.setViewController(atIndex: index, direction: .reverse)
            }
        }
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
