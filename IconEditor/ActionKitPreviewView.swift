//
//  ActionKitPreviewView.swift
//  IconEditor
//
//  Created by Mark Alldritt on 2020-06-22.
//  Copyright © 2020 Mark Alldritt. All rights reserved.
//

import UIKit

extension ActionKit {

    class PreviewView: UIView {

        var action: Action? {
            didSet {
                setNeedsDisplay()
                if let actionObserver = actionObserver {
                    NotificationCenter.default.removeObserver(actionObserver)
                    self.actionObserver = nil
                }
                if let action = action {
                    actionObserver = NotificationCenter.default.addObserver(forName: ActionKit.Action.ChaneNotification,
                                                                            object: action,
                                                                            queue: nil,
                                                                            using: { [unowned self] (notification) in
                                                                                self.setNeedsDisplay()
                    })
                }
            }
        }
        
        private var actionObserver: NSObjectProtocol?

        override init(frame: CGRect) {
            super.init(frame: frame)
                        
            isOpaque = false
            backgroundColor = .clear
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            
            isOpaque = false
            backgroundColor = .clear
        }

        deinit {
            action = nil
        }
        
        override func draw(_ rect: CGRect) {
            let size = min(bounds.width, bounds.height)
            let image = ActionKit.previewImage(symbol: action?.iconName ?? "",
                                               color: action?.color ?? .white,
                                               size: size)
            
            let f = CGRect(origin: CGPoint.zero,
                           size: image.size).offsetBy(dx: (bounds.width - size) / 2,
                                                      dy: (bounds.height - size) / 2)
            image.draw(in: f)
        }

    }
}
