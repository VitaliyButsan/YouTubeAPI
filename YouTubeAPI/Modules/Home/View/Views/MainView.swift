//
//  MainView.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import RxAnimated
import RxCocoa
import RxDataSources
import RxSwift
import SnapKit
import UIKit

class MainView: UIView {
    
    typealias DataSource = RxTableViewSectionedReloadDataSource<ResourceSection>
    
    // MARK: - Properties
    
    private var uiFactory = UIFactory()
    private var playerViewHeightConstraint: NSLayoutConstraint!
    
    private(set) var youTubeViewModel: YouTubeViewModel!
    
    private lazy var dataSource: DataSource = .init(configureCell: cellConfiguration)
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Elements
    
    private lazy var topBarView = uiFactory.newView(color: .clear)
    
    private lazy var topBarTitleLabel = uiFactory
        .newLabel(
            text: "",
            font: .SFPro.Display.bold(size: 34).font,
            textColor: .white
        )
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .gray
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 10
        tableView.backgroundColor = Asset.Colors.background.color
        tableView.register(PageControlCell.self, forCellReuseIdentifier: PageControlCell.reuseID)
        tableView.register(PlaylistCell.self, forCellReuseIdentifier: PlaylistCell.reuseID)
        return tableView
    }()
    
    private lazy var shadowView = uiFactory.newShadowView(alpha: 0.5)
    private lazy var playerView = PlayerView(viewModel: PlayerViewModel())
    
    // MARK: - Init
    
    convenience init(viewModel: YouTubeViewModel) {
        self.init(frame: .zero)
        
        youTubeViewModel = viewModel
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Private methods
    
    private func setup() {
        setupViews()
        addConstraints()
        bindUI()
        bindObservers()
        startTimer()
    }
    
    private func setupViews() {
        backgroundColor = Asset.Colors.background.color
        topBarView.addSubview(topBarTitleLabel)
        addSubview(topBarView)
        addSubview(tableView)
        addSubview(playerView)
    }
    
    private func addConstraints() {
        topBarView.snp.makeConstraints {
            $0.leading.trailing.top.equalTo(self)
            $0.height.equalTo(Constants.topBarHeight)
        }
        topBarTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(topBarView).offset(24)
            $0.bottom.equalTo(topBarView)
            $0.width.equalTo(Constants.screenWidth * 0.7)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(topBarView.snp.bottom)
            $0.leading.trailing.bottom.equalTo(self)
        }
        playerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(5)
            $0.trailing.equalToSuperview().inset(5)
            $0.height.equalTo(Constants.screenHeight - Constants.topBarHeight)
        }
        playerViewHeightConstraint = NSLayoutConstraint(
            item: playerView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        playerViewHeightConstraint.isActive = true
    }
    
    private func bindUI() {
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        youTubeViewModel.sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func bindObservers() {
        youTubeViewModel.isLoadedData
            .filter { $0 }
            .map { _ in -Constants.playerCloseHeight }
            .bind(to: youTubeViewModel.playerViewHeight)
            .disposed(by: disposeBag)
        
        youTubeViewModel.playerViewHeight
            .bind(to: playerViewHeightConstraint.rx.animated.layout(duration: 0.3).constant)
            .disposed(by: disposeBag)
        
        playerView.playerViewModel.yOffset
            .subscribe(onNext: { [weak self] y in
                self?.setPlayerViewHeight(by: y)
            })
            .disposed(by: disposeBag)

        youTubeViewModel.didLayoutSubviewsSubject
            .subscribe { [weak self] _ in
                self?.playerView.playerViewModel.didLayoutSubviewsSubject.accept(Void())
                self?.addConstraints()
            }
            .disposed(by: disposeBag)
        
        playerView.playerViewModel.playerOpenState
            .subscribe(onNext: { [unowned self] state in
                setupShadowBackground(by: state)
                setupTopBarTitle(by: state)
                if youTubeViewModel.isLoadedData.value {
                    openClosePlayer(by: state)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setPlayerViewHeight(by y: CGFloat) {
        let playerHeight = youTubeViewModel.playerViewHeight.value
        if abs(playerHeight + y) < Constants.playerOpenHeight,
           abs(playerHeight + y) > Constants.playerCloseHeight {
            youTubeViewModel.playerViewHeight.accept(playerHeight + y)
        }
    }
    
    private func openClosePlayer(by state: ShowPlayerState) {
        switch state {
        case .open:
            youTubeViewModel.playerViewHeight.accept(-Constants.playerOpenHeight)
        case .close:
            youTubeViewModel.playerViewHeight.accept(-Constants.playerCloseHeight)
        }
    }
    
    private func setupTopBarTitle(by state: ShowPlayerState) {
        switch state {
        case .open:
            topBarTitleLabel.text = "My Music"
        case .close:
            topBarTitleLabel.text = "YouTube API"
        }
    }
    
    private func setupShadowBackground(by state: ShowPlayerState) {
        switch state {
        case .open:
            addShadowView()
        case .close:
            removeShadowView()
        }
    }
    
    private func addShadowView() {
        addSubview(shadowView)
        shadowView.frame = frame
        bringSubviewToFront(playerView)
    }
    
    private func removeShadowView() {
        shadowView.removeFromSuperview()
    }
    
    private func startTimer() {
        youTubeViewModel.startTimer()
    }
}

// MARK: - DataSource Configuration

extension MainView {
    
    private var cellConfiguration: DataSource.ConfigureCell {
        return { _, tableView, indexPath, dataSource in
            switch dataSource.typeOfCell {
            case let .pageControl(channels):
                let cell = tableView.dequeueReusableCell(withIdentifier: PageControlCell.reuseID, for: indexPath) as! PageControlCell
                cell.contentView.backgroundColor = Asset.Colors.background.color
                cell.delegate = self
                cell.setupCell(with: channels, bind: self.youTubeViewModel.pagesCounter)
                return cell
            case let .playlist(playlist):
                let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistCell.reuseID, for: indexPath) as! PlaylistCell
                cell.contentView.backgroundColor = Asset.Colors.background.color
                cell.setupCell(with: playlist, for: indexPath)
                return cell
            }
        }
    }
}

// MARK: - UITableViewDelegate -

extension MainView: UITableViewDelegate {
    
    private func setupSectionHeaderView(for section: Int) -> UIView {
        let headerWidth = tableView.frame.width
        let headerHeight = Constants.sectionHeaderHeight
        let headerRect = CGRect(x: 0, y: 0, width: headerWidth, height: headerHeight)
        let headerView = UIView(frame: headerRect)
        
        let textLabel = uiFactory
            .newLabel(
                text: youTubeViewModel.getSectionTitle(by: section),
                font: .SFPro.Display.bold(size: 23).font,
                textColor: .white
            )
        headerView.addSubview(textLabel)
        
        textLabel.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.leading.width.equalToSuperview().inset(Constants.defaultPadding)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        } else {
            return Constants.sectionHeaderHeight
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else {
            return setupSectionHeaderView(for: section)
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        nil
    }
}

// MARK: - PageControlCellDelegate

extension MainView: PageControlCellDelegate {
    
    func switchChannel(by pageIndex: Int) {
        youTubeViewModel.updateData(for: pageIndex)
    }
    
    func channelDidSelect(_ channel: Channel) {
        let videos = joinedPlaylistsItems(from: channel.playlists)
        playerView.playerViewModel.videos = videos
        playerView.playerViewModel.playerOpenState.accept(.open)
    }
    
    private func joinedPlaylistsItems(from playlists: [Playlist]?) -> [PlaylistItem] {
        guard let playlistsItems2D = playlists?.compactMap(\.playlistItems) else { return [] }
        return Array(playlistsItems2D.joined())
    }
}

// MARK: - Constants

extension MainView {
    
    private enum Constants {
        static let screenWidth: CGFloat = UIScreen.main.bounds.width
        static let screenHeight: CGFloat = UIScreen.main.bounds.height
        
        static let playerOpenHeight: CGFloat = screenHeight - 97.0
        static let playerCloseHeight: CGFloat = 50.0
        
        static let topBarHeight: CGFloat = 92.0
        static let sectionHeaderHeight: CGFloat = 60.0
        
        static let defaultPadding: CGFloat = 18.0
    }
}
