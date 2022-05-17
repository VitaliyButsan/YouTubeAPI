//
//  String+splitIntoThousandParts.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 17.05.2022.
//

import Foundation

extension String {
    
    var splitIntoThounsandParts: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter.string(for: Int(self))
    }
}
