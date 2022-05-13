//
//  PlaylistCell.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 12.05.2022.
//

import SnapKit
import SDWebImage
import RxSwift
import RxCocoa
import RxDataSources

class PlaylistCell: UITableViewCell {
    
    // MARK: - Properties
    
    typealias PlaylistSection = SectionModel<String, PlaylistItem>
    typealias DataSource = RxCollectionViewSectionedReloadDataSource<PlaylistSection>
    
    static let reuseID = "PlaylistCell"
    private let bag = DisposeBag()
    private var playlist: Playlist?
    private lazy var dataSource: DataSource = .init(configureCell: configureCell)
    
    // MARK: - UI Elements
    
    private lazy var playlistCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 120)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PlaylistItemCell.self, forCellWithReuseIdentifier: PlaylistItemCell.reuseID)
        collectionView.backgroundColor = .blue
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(with playlist: Playlist) {
        self.playlist = playlist
        bindUI()
//        playlistCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setup() {
        setupViews()
        addConstraints()
//        bindUI()
    }
    
    private func setupViews() {
        contentView.backgroundColor = .green
        contentView.addSubview(playlistCollectionView)
    }
    
    private func addConstraints() {
        playlistCollectionView.snp.makeConstraints {
            $0.edges.equalTo(contentView)
        }
    }
    
    private func bindUI() {
        playlist?.dataSourcePlaylistItems
            .bind(to: playlistCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
}

// MARK: - DataSource Configuration

extension PlaylistCell {
    
    private var configureCell: DataSource.ConfigureCell {
        return { _, collectionView, indexPath, playlistItem in
//            print(self.playlist?.playlistItems?.count)
//            print(self.playlist?.dataSourcePlaylistItems.value.count)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistItemCell.reuseID, for: indexPath) as! PlaylistItemCell
            cell.setupCell(with: playlistItem)
            return cell
        }
    }
}