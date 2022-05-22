//
//  MPVolumeView+SetVolume.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 20.05.2022.
//

import MediaPlayer

extension MPVolumeView {
    
    public func setVolume(_ value: Float, duration: Double = 0.01) {
        guard let slider = subviews.first(where: { $0 is UISlider }) as? UISlider else { return }
        
        UIView.animate(withDuration: duration) {
            slider.setValue(value, animated: true)
        } completion: { _ in
            UIView.animate(withDuration: duration) {
                slider.setValue(value, animated: true)
            }
        }
    }
    
    func getVolume() -> Float {
        if let slider = subviews.first(where: { $0 is UISlider }) as? UISlider {
            return slider.value
        }
        return 0.0
    }
    
}

