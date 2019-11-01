//
//  Theme.swift
//  Selfiegram
//
//  Created by Alexander on 30.10.2019.
//  Copyright © 2019 Alexander Shigin. All rights reserved.
//

import UIKit

struct Theme {
    
    static func apply() {
        
        guard let headerFont = UIFont(familyName: "Lobster", size: UIFont.systemFontSize * 2) else {
            print("Failed to load header font")
            return
        }
        
        guard let primaryFont = UIFont(familyName: "Quicksand") else {
            print("Failed to load application font")
            return
        }
        
        let tintColor = UIColor(red: 0.56, green: 0.35, blue: 0.97, alpha: 1)
        
        let navigationBar = UINavigationBar.appearance()
        navigationBar.titleTextAttributes = [.font: headerFont]
        navigationBar.backgroundColor = tintColor
        
        let label = UILabel.appearance()
        label.font = primaryFont
        
        let navBarLabel = UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
        navBarLabel.font = primaryFont
        
        let buttonLabel = UILabel.appearance(whenContainedInInstancesOf: [UIButton.self])
        buttonLabel.font = primaryFont
        
        let barButton = UIBarButtonItem.appearance()
        barButton.setTitleTextAttributes([.font : primaryFont], for: .normal)
        barButton.setTitleTextAttributes([.font : primaryFont], for: .highlighted)
        barButton.tintColor = tintColor
    }
}
