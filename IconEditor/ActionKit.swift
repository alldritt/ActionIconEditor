//
//  ActionKit.swift
//  IconEditor
//
//  Created by Mark Alldritt on 2020-06-21.
//  Copyright © 2020 Mark Alldritt. All rights reserved.
//

import UIKit


class ActionKit {

    static func buttonImage(symbol: String, color: UIColor, tintColor: UIColor, size: CGFloat) -> UIImage {
        let bounds = CGRect(origin: .zero, size: CGSize(width: size, height: size))
        let buttonRect = bounds.insetBy(dx: size * 0.12, dy: size * 0.12)
                        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let _ = UIGraphicsGetCurrentContext() {
            ActionKitStyleKit.drawEditButton(frame: buttonRect,
                                             resizing: .aspectFill,
                                             fillColor: color,
                                             strokeColor: tintColor)
            
            let fSize = buttonRect.size.height * 0.5
            let config = UIImage.SymbolConfiguration(pointSize: fSize)
            if let symbolImage = UIImage(systemName: symbol, withConfiguration: config) {
                let f = CGRect(origin: CGPoint.zero,
                               size: symbolImage.size).offsetBy(dx: (bounds.width - symbolImage.size.width) / 2,
                                                                dy: (bounds.height - symbolImage.size.height) / 2)
                UIColor.white.set()
                symbolImage.withRenderingMode(.alwaysTemplate).draw(in: f)
            }
            
            return UIGraphicsGetImageFromCurrentImageContext()!
        }
        fatalError()
    }

    static func previewImage(symbol: String, color: UIColor, size: CGFloat) -> UIImage {
        let buttonRect = CGRect(origin: .zero, size: CGSize(width: size, height: size))
                        
        UIGraphicsBeginImageContextWithOptions(buttonRect.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let _ = UIGraphicsGetCurrentContext() {
            ActionKitStyleKit.drawSampleView(frame: buttonRect,
                                             resizing: .aspectFill,
                                             fillColor: color)
            
            let fSize = buttonRect.size.height * 0.5
            let config = UIImage.SymbolConfiguration(pointSize: fSize)
            if let symbolImage = UIImage(systemName: symbol, withConfiguration: config) {
                let f = CGRect(origin: CGPoint.zero,
                               size: symbolImage.size).offsetBy(dx: (buttonRect.width - symbolImage.size.width) / 2,
                                                                dy: (buttonRect.height - symbolImage.size.height) / 2)
                UIColor.white.set()
                symbolImage.withRenderingMode(.alwaysTemplate).draw(in: f)
            }
            
            return UIGraphicsGetImageFromCurrentImageContext()!
        }
        fatalError()
    }
}
