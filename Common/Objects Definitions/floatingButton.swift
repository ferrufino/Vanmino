//
//  floatingButton
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-08-05.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.


import UIKit

struct floatingButton {
    var btn : UIButton!
    var btnMethod = {}
    
    init(btnLabel: String, imgLabel: String, xPos: CGFloat, yPos: CGFloat) {
     
        btn = UIButton(frame: CGRect(x: xPos, y: yPos, width: 100.0, height: 50.0))
        btn.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        btn.layer.cornerRadius = 25
        btn.layer.shadowOffset = CGSize(width: 0, height: 10)
        btn.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        btn.layer.shadowRadius = 5
        btn.layer.shadowOpacity = 0.3
        
        btn.tintColor = #colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1)
        btn.setTitle(btnLabel, for: .normal)
        btn.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        btn.setTitleColor(#colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1), for: .normal)
        
        if imgLabel != "" {
            let backbtnImg = UIImage(named: imgLabel)?.withRenderingMode(.alwaysTemplate)
            btn.setImage(backbtnImg, for: .normal)
        }
    }
    
    

}
