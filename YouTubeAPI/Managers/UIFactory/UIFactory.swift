//
//  UIFactory.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import UIKit

final class UIFactory {
    
    func getViewController(color: UIColor) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = color
        return vc
    }
    
    func newLabel(text: String, font: UIFont) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        return label
    }
    
    func newView(color: UIColor = .white) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        return view
    }
}
