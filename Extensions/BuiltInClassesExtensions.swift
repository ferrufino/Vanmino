//
//  GeneralExtensions.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-02-23.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

import UIKit

extension Array {
    func contains<T>(obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}
