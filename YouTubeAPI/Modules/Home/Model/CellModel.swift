//
//  CellModel.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 13.05.2022.
//

import Foundation
import RxRelay
import RxDataSources

struct CellModel {
    
    enum CellType {
        case pageControl(model: [Channel])
        case playlist(model: RxPlaylist)
    }
    
    let title: String
    let typeOfCell: CellType
}
