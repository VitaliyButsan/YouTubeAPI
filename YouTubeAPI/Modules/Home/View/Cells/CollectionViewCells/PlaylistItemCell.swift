//
//  PlaylistItemCell.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 13.05.2022.
//

import SDWebImage
import SnapKit
import UIKit

class PlaylistItemCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    private var playlistItem: PlaylistItem?
     
    static let reuseID = L10n.playlistItemCellId
    
    private let uiFactory = UIFactory()
    
    // MARK: - UI Elements
    
    private lazy var containerView = uiFactory.newView()
    private lazy var photoImageView = uiFactory.newImageView(cornerRadius: 6)
    
    private lazy var titleVideoLabel = uiFactory
        .newLabel(
            font: .SFPro.Text.medium(size: 17).font,
            textColor: .white
        )
    private lazy var viewsCounterLabel = uiFactory
        .newLabel(
            font: .SFPro.Text.medium(size: 12).font,
            textColor: .gray
        )
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        setupLayout()
    }
    
    // MARK: - Public methods
    
    func setupCell(with playlistItem: PlaylistItem, indexPath: IndexPath) {
        self.playlistItem = playlistItem
        titleVideoLabel.text = playlistItem.snippet.title
        let viewsCount = playlistItem.snippet.viewCount?.splitIntoThounsandParts ?? "0"
        viewsCounterLabel.text = viewsCount + " просмотра"
        setupPosterHeight(by: indexPath.section)
        let url = playlistItem.snippet.thumbnails?.default?.url ?? ""
        photoImageView.sd_setImage(with: URL(string: url), placeholderImage: Asset.placeholder.image)
    }
    
    // MARK: - Private methods
    
    private func setupPosterHeight(by sectionIndex: Int) {
        var height: CGFloat = 0.0
        switch sectionIndex {
        case 1:
            height = 70.0
        case 2:
            height = 135.0
        default:
            break
        }
        photoImageView.snp.makeConstraints {
            $0.height.equalTo(height)
        }
        containerView.layoutIfNeeded()
    }
    
    private func setupLayout() {
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        containerView.addSubview(photoImageView)
        containerView.addSubview(titleVideoLabel)
        containerView.addSubview(viewsCounterLabel)
        contentView.addSubview(containerView)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        photoImageView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
        }
        titleVideoLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(photoImageView.snp.bottom).offset(7)
        }
        viewsCounterLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(titleVideoLabel.snp.bottom)
        }
    }
}
