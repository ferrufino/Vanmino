//
//  TabBarViewController.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-04-06.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.unselectedItemTintColor = #colorLiteral(red: 0.1059800163, green: 0.1060054824, blue: 0.1059766635, alpha: 1)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
