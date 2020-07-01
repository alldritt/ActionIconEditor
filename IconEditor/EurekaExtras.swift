//
//  EurekaExtras.swift
//
//  Created by Mark Alldritt on 2018-03-25.
//  Copyright © 2018 Late Night Software Ltd. All rights reserved.
//
//  Additions to the Eureka Form object
//

import Eureka


//  A version of FormViewController conforming to Eureka's RowControllerType protocol so that Eureka's
//  dismissed callback operates correctly when presenting a view controller from a Eureka form.  Why
//  Eureka's FormViewController does not provide this is a mystery, but...
//
//  This version of FormViewController also provides a Copy menu for LabelRows to copy the row's value
//  to the clipboard.

class EurekaFormViewController: FormViewController, RowControllerType {
    
    var onDismissCallback: ((UIViewController) -> Void)?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if !isMovingToParent {
            onDismissCallback?(self)
        }
    }

    // MARK: - UITableViewDelegate
    //
    //  Provide a contextual Copy menu to copy the value of LabelRows which have an assigned value.

    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        guard let row = form[indexPath] as? LabelRow else { return false }
        guard let value = row.value, value != "" else { return false }
        
        return true
    }

    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        return action == #selector(copy(_:))
    }

    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            guard let row = form[indexPath] as? LabelRow else { return }

            UIPasteboard.general.string = row.value
        }
    }
}


//  A version of UIViewController conforming to Eureka's RowControllerType protocol so that Eureka's
//  dismissed callback operates correctly when presenting a view controller from a Eureka form.

class EurekaViewController: UIViewController, RowControllerType {
    
    var onDismissCallback: ((UIViewController) -> Void)?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if !isMovingToParent {
            onDismissCallback?(self)
        }
    }
    /*
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !isMovingToParent {
            onDismissCallback?(self)
        }
    }
    */
    
}


//  A version of UINavigationController conforming to Eureka's RowControllerType protocol so that
//  dismissed callback operates correctly when presenting a view controller from a Eureka form.

class EurekaNavigationController: UINavigationController, RowControllerType {
    
    var onDismissCallback: ((UIViewController) -> Void)?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if !isMovingToParent {
            onDismissCallback?(self)
        }
    }
    /*
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !isMovingToParent {
            onDismissCallback?(self)
        }
    }
    */
}

