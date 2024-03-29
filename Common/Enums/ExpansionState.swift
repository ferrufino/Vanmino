//
//  ExpansionState.swift
//  ShortcutsDrawer
//
//  Created by Phill Farrugia on 10/16/18.
//  Copyright © 2018 Phill Farrugia. All rights reserved.
//

import UIKit
let window = UIApplication.shared.keyWindow
/// Expansion State of a DrawerViewController that define its
/// height within its ContainerViewController.
enum ExpansionState {
    
    /// Compressed
    case compressed
    
    /// Expanded
    case expanded
    
    /// Full Height
    case fullHeight
    
    // MARK: - Height Constraint
    
    /**
     Defines the static height of the DrawerViewController in its container
     view controller.
     - Parameter state: state of the drawer to calculate height for.
     - Parameter container: frame of the container used to calculate height.
     */
    static func height(forState state: ExpansionState, inContainer container: CGRect) -> CGFloat {
        switch state {
        case .compressed:
            return container.height * 0.25
        case .expanded:
            return (FactInfoTableViewCell.cellHeight * 4 ) + 30 + (window?.safeAreaInsets.bottom)!
        case .fullHeight:
            return (FactInfoTableViewCell.cellHeight * 4 ) + 30 + (window?.safeAreaInsets.bottom)!
        }
    }
    
}
