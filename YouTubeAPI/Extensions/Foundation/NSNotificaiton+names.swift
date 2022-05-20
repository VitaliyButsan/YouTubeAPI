//
//  NotificaitonCenter+names.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 20.05.2022.
//

import Foundation


extension NSNotification.Name {
    
    // tracking on
    static var volumeChanging =
    NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification")
    
    // output
    static var audioVolume =
    NSNotification.Name(rawValue: "AVSystemController_AudioVolumeNotificationParameter")
    
}
