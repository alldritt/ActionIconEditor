//
//  ActionKitAction.swift
//  IconEditor
//
//  Created by Mark Alldritt on 2020-06-30.
//  Copyright © 2020 Mark Alldritt. All rights reserved.
//

import UIKit

extension ActionKit {
    class Action {

        static let ChaneNotification = Notification.Name(rawValue: "ActionKit.Action.changed")
        
        private static var nextColor = 0
        var iconName: String = "" { // SF Symbols ID
            didSet {
                NotificationCenter.default.post(name: Self.ChaneNotification, object: self)
            }
        }
        var name: String = "untitled" {
            didSet {
                NotificationCenter.default.post(name: Self.ChaneNotification, object: self)
            }
        }
        var subtitle: String = "4 actions" {
            didSet {
                NotificationCenter.default.post(name: Self.ChaneNotification, object: self)
            }
        }
        var color: UIColor = .blue {
            didSet {
                NotificationCenter.default.post(name: Self.ChaneNotification, object: self)
            }
        }
        
        var icon: UIImage? {
            return UIImage(systemName: iconName)
        }
        
        init(name: String, subtitle: String, icon: String = "wand.and.rays") {
            self.name = name
            self.subtitle = subtitle
            self.iconName = icon
            self.color = ActionKit.colors[Self.nextColor % ActionKit.colors.count]
            Self.nextColor += 1
        }

    }
}
