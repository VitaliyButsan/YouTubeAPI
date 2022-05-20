//
//  MPVolumeView+SetVolume.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 20.05.2022.
//

import MediaPlayer

extension MPVolumeView {
    
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first { $0 is UISlider } as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            slider?.value = volume
        }
    }
    
}

