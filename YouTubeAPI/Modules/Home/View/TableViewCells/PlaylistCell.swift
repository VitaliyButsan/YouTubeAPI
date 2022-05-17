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
    
    private var indexPath = IndexPath(row: 0, section: 0)
    
    private var defaultPadding: CGFloat {
        return Constants.defaultPadding
    }
    
    typealias PlaylistSection = SectionModel<String, PlaylistItem>
    typealias DataSource = RxCollectionViewSectionedReloadDataSource<PlaylistSection>
    
    private lazy var dataSource: DataSource = .init(configureCell: configureCell)
    
    static let reuseID = "PlaylistCell"
    private let bag = DisposeBag()
    private var playlist: RxPlaylist?
    private let uiFactory = UIFactory()
    
    // MARK: - UI Elements
    
    lazy var playlistCollectionView = uiFactory.newCollectionView()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(with playlist: RxPlaylist, for indexPath: IndexPath) {
        self.indexPath = indexPath
        self.playlist = playlist
        playlistCollectionView.delegate = nil
        playlistCollectionView.dataSource = nil
        bindUI()
        setPlaylistCollectionViewHeight(by: indexPath.section)
    }
    
    private func setup() {
        setupViews()
        addConstraints()
    }
    
    private func setupViews() {
        contentView.addSubview(playlistCollectionView)
    }
    
    private func setPlaylistCollectionViewHeight(by sectionIndex: Int) {
        var height: CGFloat = 0.0
        switch sectionIndex {
        case 1:
            height = Constants.firstSectionHeight
        case 2:
            height = Constants.secondSectionHeight
        default:
            break
        }
        playlistCollectionView.snp.makeConstraints {
            $0.height.equalTo(height)
        }
        contentView.layoutIfNeeded()
    }
    
    private func addConstraints() {
        playlistCollectionView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(defaultPadding)
            $0.trailing.bottom.top.equalToSuperview()
        }
    }
    
    private func bindUI() {
        playlistCollectionView.rx
            .setDelegate(self)
            .disposed(by: bag)
        
        playlist?.playlistItems?
            .bind(to: playlistCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
}

// MARK: - DataSource Configuration

extension PlaylistCell {
    
    private var configureCell: DataSource.ConfigureCell {
        return { _, collectionView, indexPath, playlistItem in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistItemCell.reuseID, for: indexPath) as! PlaylistItemCell
            cell.setupCell(with: playlistItem, indexPath: self.indexPath)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PlaylistCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch self.indexPath.section {
        case 1:
            let width = Constants.firstSectionCellWidth
            let height = Constants.firstSectionHeight
            return CGSize(width: width, height: height)
        case 2:
            let width = Constants.secondSectionCellWidth
            let height = Constants.secondSectionHeight
            return CGSize(width: width, height: height)
        default:
            return .zero
        }
    }
}
