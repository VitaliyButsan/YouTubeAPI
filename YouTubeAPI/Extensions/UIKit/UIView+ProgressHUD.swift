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
        ProgressHUD.show()
        ProgressHUD.animationType = .circleRotateChase
        ProgressHUD.colorAnimation = .black
    }
    
    static func showHUD(icon: AlertIcon) {
        ProgressHUD.show(icon: icon)
    }
    
    static func showSuccessHUD() {
        ProgressHUD.showSucceed()
        ProgressHUD.colorAnimation = .systemGreen
    }
    
    static func showFailedHUD() {
        ProgressHUD.showFailed()
        ProgressHUD.colorAnimation = .systemRed
    }
    
    static func hideHUD() {
        ProgressHUD.dismiss()
    }
    
}
