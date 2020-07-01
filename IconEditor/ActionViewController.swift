//
//  ActionViewController.swift
//  IconEditor
//
//  Created by Mark Alldritt on 2020-06-21.
//  Copyright © 2020 Mark Alldritt. All rights reserved.
//

import UIKit
import Eureka


class ActionViewController: EurekaFormViewController {

    var action: ActionKit.Action? {
        didSet {
            if let actionObserver = actionObserver {
                NotificationCenter.default.removeObserver(actionObserver)
                self.actionObserver = nil
            }
            if let action = action {
                actionObserver = NotificationCenter.default.addObserver(forName: ActionKit.Action.ChaneNotification,
                                                                        object: action,
                                                                        queue: nil,
                                                                        using: { [unowned self] (notification) in
                                                                            guard !self.editingAction else { return }
                                                                            self.form.rowBy(tag: "name")?.reload()
                })
            }
        }
    }
    
    private var editingAction = false
    private var actionObserver: NSObjectProtocol?
    
    let shortcutIconSize = CGFloat(70)
    lazy var tapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(shortcutIconTapped(sender:)))
        
        recognizer.numberOfTapsRequired = 1
        return recognizer
    }()
    
    deinit {
        #if DEBUG
        print("deinit ActionViewController")
        #endif
        action = nil
    }
    
    override func viewDidLoad() {
        //  Present the form in the insetGrouped style
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.cellLayoutMarginsFollowReadableWidth = true
                
        super.viewDidLoad()

        //  Prevent swipe-down dismissal
        isModalInPresentation = true
        
        navigationItem.title = "Details"
        
        form +++ Section()
            <<< NameRow("name") { (row) in
                row.placeholder = "Shortcut Name"
                row.value = action?.name
            }
            .onChange { [unowned self] (row) in
                guard let newValue = row.value else { return }
                self.editingAction = true
                self.action?.name = newValue
                self.editingAction = false
            }
            .cellSetup { [unowned self] (cell, row) in
                cell.height = { return self.shortcutIconSize }
                cell.imageView?.addGestureRecognizer(self.tapRecognizer)
                cell.imageView?.isUserInteractionEnabled = true
            }
            .cellUpdate { [unowned self] (cell, row) in
                cell.imageView?.image = ActionKit.buttonImage(symbol: self.action?.iconName ?? "",
                                                              color: self.action?.color ?? .white,
                                                              tintColor: self.view.tintColor,
                                                              size: self.shortcutIconSize)
            }
        
        form +++ Section()
            <<< ButtonRow() { (row) in
                row.title = "Add to Home Screen"
            }
            .cellUpdate { (cell, row) in
                cell.textLabel?.textAlignment = .left
            }
            .onCellSelection { (cell, row) in
                guard !row.isDisabled else { return }
                
                let alertController = UIAlertController(title: "Pressed",
                                                        message: "The button was pressed",
                                                        preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Cancel",
                                                        style: .cancel))
                
                self.present(alertController, animated: true)
            }
        
        form +++ Section()
            <<< SwitchRow() { (row) in
                row.title = "Show in Widget"
                row.value = true
            }
            <<< SwitchRow() { (row) in
                row.title = "Show in Share Sheet"
                row.value = true
            }
    }

    @objc
    private func shortcutIconTapped(sender: UITapGestureRecognizer) {
        let vc = ActionIconViewController();
        
        vc.navigationItem.rightBarButtonItem = LNSBarButtonItem(barButtonSystemItem: .done,
                                                                actionHandler: { (button) in
                                                                    vc.dismiss(animated: true)
        })
        vc.action = action
        
        let nvc = UINavigationController(rootViewController: vc)
        
        nvc.modalPresentationStyle = .formSheet
        present(nvc, animated: true) {
            print("completed!")
        }
    }
}

