//
//  UIAlertControllerExt.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-03-23.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

import UIKit

extension UIAlertController {
    func addImage(image: UIImage){
        let maxSize = CGSize(width: 245, height: 300)
        let imgSize = image.size
        
        var ratio: CGFloat!
        if(imgSize.width > imgSize.height){
            ratio = maxSize.width / imgSize.width
        }else {
            ratio = maxSize.height / imgSize.height
        }
        
        let scaledSize = CGSize(width: imgSize.width * ratio, height: imgSize.height * ratio)
        let resizedimage = image.imageWithSize(scaledSize)
        let imageAction = UIAlertAction(title: "", style: .default, handler: nil)
        imageAction.isEnabled = false
        imageAction.setValue(resizedimage.withRenderingMode(.alwaysOriginal), forKey: "image")
        self.addAction(imageAction)
        
    }
}
