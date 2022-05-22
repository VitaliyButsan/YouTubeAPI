//
//  Constants.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 17.05.2022.
//

import UIKit

struct Constants {
    
    static let screenWidth: CGFloat = UIScreen.main.bounds.width
    static let screenHeight: CGFloat = UIScreen.main.bounds.height
    static let halfScreenWidth: CGFloat = screenWidth / 2
    static let halfScreenHeight: CGFloat = screenHeight / 2
    static let quarterScreenHeight: CGFloat = halfScreenHeight / 2
    
    static let topBarHeight: CGFloat = 92.0
    
    static let defaultPadding: CGFloat = 18.0
    static let firstSectionHeight: CGFloat = 130.0
    static let secondSectionHeight: CGFloat = 220.0
    
    static let firstSectionCellWidth: CGFloat = 160.0
    static let secondSectionCellWidth: CGFloat = 135.0
    
    static let playerOpenHeight: CGFloat = screenHeight - 97.0
    static let playerCloseHeight: CGFloat = 50.0
    
    static let playerViewCornerRadius: CGFloat = 20.0
}
