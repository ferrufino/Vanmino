//
//  MainNavBarViewController.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-04-05.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

import UIKit

class MainNavBarViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.topItem?.title = "Outdoorsy"
        navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
             NSAttributedString.Key.font: UIFont(name: "Hiragino Sans W6", size: 25)!]
        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
}
