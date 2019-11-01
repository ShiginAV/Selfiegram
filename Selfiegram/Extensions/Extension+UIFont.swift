//
//  Extension+UIFont.swift
//  Selfiegram
//
//  Created by Alexander on 30.10.2019.
//  Copyright © 2019 Alexander Shigin. All rights reserved.
//

import UIKit

extension UIFont {
    
    convenience init? (familyName: String, size: CGFloat = UIFont.systemFontSize, variantName: String? = nil) {
        
        guard let name = UIFont.familyNames
            .filter({ $0.contains(familyName) })
            .flatMap({ UIFont.fontNames(forFamilyName: $0) })
            .filter({ variantName != nil ? $0.contains(variantName!) : true })
            .first else { return nil }
        
        self.init(name: name, size: size)
    }
}
