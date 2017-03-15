//
//  GlobalUtilities.swift
//  Lala
//
//  Created by Görkem Karahan on 26/02/2017.
//  Copyright © 2017 Görkem Karahan. All rights reserved.
//

import UIKit

class GlobalUtilities {

    let dateFormatter = DateFormatter()
    
    static let sharedInstance: GlobalUtilities = {
        let instance = GlobalUtilities()
        instance.dateFormatter.locale = Locale.current
        instance.dateFormatter.dateStyle = .short
        instance.dateFormatter.timeStyle = .short
        return instance
    }()
}
