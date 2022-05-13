//
//  PlaylistItemCell.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 13.05.2022.
//

import UIKit
import SnapKit

class PlaylistItemCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let reuseID = "PlaylistItemCell"
    
    // MARK: - UI Elements
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupLayout()
    }
    
    func setupCell(with playlistItem: PlaylistItem) {
        
    }
    
    private func setupLayout() {
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        contentView.backgroundColor = .red
        contentView.addSubview(photoImageView)
    }
    
    private func setupConstraints() {
        photoImageView.snp.makeConstraints {
            $0.edges.equalTo(contentView)
        }
    }
}
