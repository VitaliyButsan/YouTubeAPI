//
//  MPVolumeView+SetVolume.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 20.05.2022.
//

import MediaPlayer

extension MPVolumeView {
    
    func setVolume(_ value: Float) {
        let slider = subviews.first { $0 is UISlider } as? UISlider
        slider?.setValue(value, animated: true)
    }
    
    func getVolume() -> Float {
        let slider = subviews.first { $0 is UISlider } as? UISlider
        return slider?.value ?? 0.0
    }
}

