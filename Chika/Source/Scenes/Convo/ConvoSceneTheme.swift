//
//  ConvoSceneTheme.swift
//  Chika
//
//  Created by Mounir Ybanez on 11/23/17.
//  Copyright © 2017 Nir. All rights reserved.
//

import UIKit

protocol ConvoSceneTheme: class {

    var bgColor: UIColor { get }
    
    var rightCellContentTextColor: UIColor { get }
    var rightCellContenBGColor: UIColor { get }
    var rightCellContentFont: UIFont? { get }
    var rightCellBorderWidth: CGFloat { get }
    var rightCellBorderColor: UIColor { get }
    var rightCellAuthorTextColor: UIColor { get }
    var rightCellAuthorFont: UIFont? { get }
    var rightCellTimeTextColor: UIColor { get }
    var rightCellTimeFont: UIFont? { get }
    
    var leftCellContentTextColor: UIColor { get }
    var leftCellContenBGColor: UIColor { get }
    var leftCellContentFont: UIFont? { get }
    var leftCellBorderWidth: CGFloat { get }
    var leftCellBorderColor: UIColor { get }
    var leftCellAuthorTextColor: UIColor { get }
    var leftCellAuthorFont: UIFont? { get }
    var leftCellTimeTextColor: UIColor { get }
    var leftCellTimeFont: UIFont? { get }
}

extension ConvoScene {
    
    class Theme: ConvoSceneTheme {
        
        var bgColor: UIColor = .white
        
        var rightCellContentTextColor: UIColor = .black
        var rightCellContenBGColor: UIColor = .white
        var rightCellContentFont: UIFont? = UIFont(name: "AvenirNext-Regular", size: 16.0)
        var rightCellBorderColor: UIColor = .black
        var rightCellBorderWidth: CGFloat = 1
        var rightCellAuthorTextColor: UIColor = .gray
        var rightCellAuthorFont: UIFont? = UIFont(name: "AvenirNext-Medium", size: 12.0)
        var rightCellTimeTextColor: UIColor = .gray
        var rightCellTimeFont: UIFont? = UIFont(name: "AvenirNext-Regular", size: 12.0)
        
        var leftCellContentTextColor: UIColor = .white
        var leftCellContenBGColor: UIColor = .black
        var leftCellContentFont: UIFont? = UIFont(name: "AvenirNext-Regular", size: 16.0)
        var leftCellBorderColor: UIColor = .black
        var leftCellBorderWidth: CGFloat = 0
        var leftCellAuthorTextColor: UIColor = .gray
        var leftCellAuthorFont: UIFont? = UIFont(name: "AvenirNext-Medium", size: 12.0)
        var leftCellTimeTextColor: UIColor = .gray
        var leftCellTimeFont: UIFont? = UIFont(name: "AvenirNext-Regular", size: 12.0)
    }
}
