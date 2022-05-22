//
//  NotificaitonCenter+names.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 20.05.2022.
//

import Foundation

extension NSNotification.Name {
    
    static var volumeChanging =
    NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification")
    
    static var audioVolume =
    NSNotification.Name(rawValue: "AVSystemController_AudioVolumeNotificationParameter")
    
}
