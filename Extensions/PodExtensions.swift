//
//  PodExtensions.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-02-28.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

import UIKit
import YNDropDownMenu

class DropDownView: YNDropDownView {
    // override method to call open & close
    override func dropDownViewOpened() {
        print("dropDownViewOpened")
    }
    
    override func dropDownViewClosed() {
        print("dropDownViewClosed")
    }
    
    // Hide Menu
  /*  self.hideMenu()
    
    // Change Menu Title At Index
    self.changeMenu(title: "Changed", at: 1)
    self.changeMenu(title: "Changed", status: .selected, at: 1)
    
    // Change View At Index
    self.changeView(view: UIView(), at: 3)
    
    // Always Selected Menu
    self.alwaysSelected(at: 0)
    self.normalSelected(at: 0) */
}
