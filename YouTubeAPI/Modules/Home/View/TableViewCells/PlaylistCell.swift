//
//  PlaylistCell.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 12.05.2022.
//

import RxCocoa
import RxDataSources
import RxSwift
import SDWebImage
import SnapKit

class PlaylistCell: UITableViewCell {
    
    typealias PlaylistSection = SectionModel<String, PlaylistItem>
    typealias DataSource = RxCollectionViewSectionedReloadDataSource<PlaylistSection>
    
    // MARK: - Properties
    
    private var indexPath = IndexPath(row: 0, section: 0)
    private var playlist: RxPlaylist?
    
    private lazy var dataSource: DataSource = .init(configureCell: configureCell)
    
    static let reuseID = L10n.playlistCellId
    
    private let disposeBag = DisposeBag()
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
    
    // MARK: - Public methods
    
    func setupCell(with playlist: RxPlaylist, for indexPath: IndexPath) {
        self.indexPath = indexPath
        self.playlist = playlist
        setPlaylistCollectionViewHeight(by: indexPath.section)
        playlistCollectionView.delegate = nil
        playlistCollectionView.dataSource = nil
        bindUI()
    }
    
    // MARK: - Private methods
    
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
            $0.leading.equalToSuperview().offset(Constants.defaultPadding)
            $0.trailing.equalToSuperview()
            $0.bottom.top.equalToSuperview()
        }
    }
    
    private func bindUI() {
        playlistCollectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        playlist?.playlistItems?
            .bind(to: playlistCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
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

// MARK: - Constants

extension PlaylistCell {
    
    private enum Constants {
        static let firstSectionCellWidth: CGFloat = 160.0
        static let secondSectionCellWidth: CGFloat = 135.0
        
        static let firstSectionHeight: CGFloat = 130.0
        static let secondSectionHeight: CGFloat = 220.0
        
        static let defaultPadding: CGFloat = 18.0
    }
}
