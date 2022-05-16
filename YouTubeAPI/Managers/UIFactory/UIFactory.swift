//
//  UIFactory.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import UIKit

final class UIFactory {
    
    func newViewController(color: UIColor = .white) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = color
        return vc
    }
    
    func newLabel(text: String, font: UIFont, textColor: UIColor = .black, bgColor: UIColor = .clear) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.backgroundColor = bgColor
        return label
    }
    
    func newView(color: UIColor = .white) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        return view
    }
}
