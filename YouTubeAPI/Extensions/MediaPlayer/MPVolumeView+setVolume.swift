//
//  MPVolumeView+SetVolume.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 20.05.2022.
//

import MediaPlayer

extension MPVolumeView {
    
    public func setVolume(_ value: Float, duration: Double = 0.01) {
        let slider = subviews.first { $0 is UISlider } as? UISlider
        
        UIView.animate(withDuration: duration) {
            slider?.setValue(value, animated: true)
        } completion: { _ in
            UIView.animate(withDuration: duration) {
                slider?.setValue(value, animated: false)
            }
        }
    }
    
    func getVolume() -> Float {
        let slider = subviews.first { $0 is UISlider } as? UISlider
        return slider?.value ?? 0.0
    }
    
}

