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
            case bold(size: CGFloat)
            
            var font: UIFont {
                switch self {
                case let .bold(size):
                    return FontFamily.SFProDisplay.bold.font(size: size)
                }
            }
        }
        
        enum Text {
            case regular(size: CGFloat)
            case medium(size: CGFloat)
            case semibold(size: CGFloat)
            
            var font: UIFont {
                switch self {
                case let .regular(size):
                    return FontFamily.SFProText.regular.font(size: size)
                case let .medium(size):
                    return FontFamily.SFProText.medium.font(size: size)
                case let .semibold(size):
                    return FontFamily.SFProText.semibold.font(size: size)
                }
            }
        }
        
    }
    
}
