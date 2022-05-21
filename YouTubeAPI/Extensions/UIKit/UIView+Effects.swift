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
    
    func asImage(frame: CGRect = .zero, bgColor: UIColor = .white) -> UIImage {
        let thumbView = UIView()
        thumbView.backgroundColor = bgColor
        thumbView.frame = frame
        
        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        let image = renderer.image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
        return image
    }
}
