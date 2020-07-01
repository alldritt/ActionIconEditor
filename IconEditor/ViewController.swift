//
//  ViewController.swift
//  IconEditor
//
//  Created by Mark Alldritt on 2020-06-21.
//  Copyright © 2020 Mark Alldritt. All rights reserved.
//

import UIKit
import Eureka


class ViewController: EurekaFormViewController {
    
    var action = ActionKit.Action(name: "Hello World", subtitle: "")

    override func viewDidLoad() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        super.viewDidLoad()
        
        form +++ Section()
            <<< ButtonRow() { (row) in
                row.title = "Edit Action"
                row.presentationMode = .presentModally(controllerProvider: ControllerProvider.callback {
                    let vc = ActionViewController()
                    
                    vc.navigationItem.rightBarButtonItem = LNSBarButtonItem(barButtonSystemItem: .done,
                                                                            actionHandler: { (button) in
                                                                                vc.dismiss(animated: true)
                    })
                    vc.action = self.action
                    
                    let nvc = UINavigationController(rootViewController: vc)
                    
                    nvc.modalPresentationStyle = .formSheet
                    return nvc
                },
                                                       onDismiss: nil)
            }
            .cellUpdate { (cell, row) in
                cell.textLabel?.textAlignment = .center
                cell.accessoryType = .none
            }
    }
}

