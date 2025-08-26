//
//  UIView+ProgressHUD.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 22.05.2022.
//

import UIKit
import ProgressHUD

extension UIView {
    
    static func showRotationHUD() {
        ProgressHUD.animate()
        ProgressHUD.animationType = .circleRotateChase
        ProgressHUD.colorAnimation = .black
    }
    
    static func showSuccessHUD() {
        ProgressHUD.succeed()
        ProgressHUD.colorAnimation = .systemGreen
    }
    
    static func showFailedHUD() {
        ProgressHUD.failed()
        ProgressHUD.colorAnimation = .systemRed
    }
    
    static func hideHUD() {
        ProgressHUD.dismiss()
    }
    
}
