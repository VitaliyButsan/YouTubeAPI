//
//  PlaylistCell.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 12.05.2022.
//

import SnapKit
import SDWebImage

class PlaylistCell: UITableViewCell {
    
    static let reuseID = "PlaylistCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setupLayout()
    }
    
    private func setupLayout() {
        
    }
    
    func setupCell(with playlistItem: PlaylistItem) {
        
    }
}
