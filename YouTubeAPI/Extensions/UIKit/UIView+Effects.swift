//
//  UIView+effects.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 19.05.2022.
//

import UIKit

extension UIView {
    
    func addGradientWithColor(color: UIColor) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [UIColor.clear.cgColor, color.cgColor]
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func rotate(angle: CGFloat = .pi) {
        self.transform = self.transform.rotated(by: angle)
    }
    
}
