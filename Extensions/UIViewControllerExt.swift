//
//  UIViewControllerExt.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2018-12-21.
//  Copyright © 2018 Gustavo Ferrufino. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentDescription(_ viewControllerToPresent: UIViewController){
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window?.layer.add(transition, forKey: kCATransition)
        
        present(viewControllerToPresent, animated: false, completion: nil)
    }
    
    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window?.layer.add(transition, forKey: kCATransition)
        
        dismiss(animated: false, completion: nil)
    }
    
    func notifyUser(title: String, message: String, imageName: String, extraOption: String,handleComplete:@escaping (()->())) -> Void{
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        if !imageName.isEmpty {
            let image = UIImage(named: imageName)
            alertController.addImage(image: image!)
        }
        
        if !extraOption.isEmpty {
            let extraAction = UIAlertAction(title: extraOption, style: .default, handler: {
                action in
               handleComplete()
            })
            alertController.addAction(extraAction)
            
        }
        self.present(alertController, animated: true, completion: nil)
    }

}
