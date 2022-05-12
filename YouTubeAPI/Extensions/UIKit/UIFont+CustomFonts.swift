//
//  UIFont+CustomFonts.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 12.05.2022.
//

import UIKit

extension UIFont {
    
    enum SFPro {
        enum Display {
            case Bold(size: CGFloat)
            
            var font: UIFont {
                switch self {
                case let .Bold(size):
                    return FontFamily.SFProDisplay.bold.font(size: size)
                }
            }
        }
        enum Text {
            case Regular(size: CGFloat)
            case Medium(size: CGFloat)
            case Semibold(size: CGFloat)
            
            var font: UIFont {
                switch self {
                case let .Regular(size):
                    return FontFamily.SFProText.regular.font(size: size)
                case let .Medium(size):
                    return FontFamily.SFProText.medium.font(size: size)
                case let .Semibold(size):
                    return FontFamily.SFProText.semibold.font(size: size)
                }
            }
        }
    }
    
}
