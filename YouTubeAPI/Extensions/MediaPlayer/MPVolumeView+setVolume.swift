//
//  MPVolumeView+SetVolume.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 20.05.2022.
//

import MediaPlayer

extension MPVolumeView {
    
    func setVolume(_ volume: Float) {
        let slider = subviews.first { $0 is UISlider } as? UISlider
        slider?.value = volume
    }
    
    func getVolume() -> Float {
        if let slider = subviews.first(where: { $0 is UISlider }) as? UISlider {
            return slider.value
        }
        return 0.0
    }
    
}

