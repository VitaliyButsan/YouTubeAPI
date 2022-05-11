//
//  UIFactory.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import UIKit

final class UIFactory {
    
    enum Font {
        case SFProDisplayBold(size: CGFloat)
        case SFProTextRegular(size: CGFloat)
        case SFProTextMedium(size: CGFloat)
        case SFProTextSemibold(size: CGFloat)
        
        var font: UIFont {
            switch self {
            case let .SFProDisplayBold(size):
                return FontFamily.SFProDisplay.bold.font(size: size)
            case let .SFProTextRegular(size):
                return FontFamily.SFProText.regular.font(size: size)
            case let .SFProTextMedium(size):
                return FontFamily.SFProText.medium.font(size: size)
            case let .SFProTextSemibold(size):
                return FontFamily.SFProText.semibold.font(size: size)
            }
        }
    }
    
    func getViewController(color: UIColor) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = color
        return vc
    }
    
    func newLabel(text: String, font: Font) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font.font
        return label
    }
    
    func newView(color: UIColor = .white) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        return view
    }
}
