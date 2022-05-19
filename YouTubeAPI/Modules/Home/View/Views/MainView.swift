//
//  MainView.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import UIKit
import SnapKit
import RxSwift
import RxDataSources
import RxAnimated
import RxCocoa

class MainView: UIView {
    
    // MARK: - Properties
    
    private var youTubeViewModel: YouTubeViewModel!
    private var uiFactory: UIFactory!
    private var playerView: PlayerView!
    
    typealias DataSource = RxTableViewSectionedReloadDataSource<ResourcesSection>
    private lazy var dataSource: DataSource = .init(configureCell: configureCell)
    
    private var playerViewMinHeight: CGFloat = 50.0
    private var playerViewMaxHeight: CGFloat = 500.0
    private var playerViewHeightConstraint: NSLayoutConstraint!
    private lazy var playerViewHeight = BehaviorRelay(value: playerViewMinHeight)
    
    // MARK: - UI Elements
    
    private lazy var topBarView = uiFactory.newView(color: .clear)
    private lazy var topBarTitleLabel = uiFactory
        .newLabel(
            text: "YouTube API",
            font: .SFPro.Display.Bold(size: 34).font,
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
    
    // MARK: - Lifecycle
    
    convenience init(viewModel: YouTubeViewModel?, uiFactory: UIFactory?, playerView: PlayerView?) {
        self.init(frame: .zero)
        
        guard let viewModel = viewModel,
              let uiFactory = uiFactory,
              let playerView = playerView
        else {
            fatalError("MainView init")
        }
        self.youTubeViewModel = viewModel
        self.uiFactory = uiFactory
        self.playerView = playerView
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        setupViews()
        addConstraints()
        bindUI()
        bindObservers()
//        startTimer()
    }
    
    private func setupViews() {
        backgroundColor = Asset.Colors.background.color
        topBarView.addSubview(topBarTitleLabel)
        addSubview(topBarView)
        addSubview(tableView)
        addSubview(playerView)
        bringSubviewToFront(playerView)
    }
    
    private func addConstraints() {
        topBarView.snp.makeConstraints {
            $0.leading.trailing.top.equalTo(self)
            $0.height.equalTo(92)
        }
        topBarTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(topBarView).offset(24)
            $0.bottom.equalTo(topBarView)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(topBarView.snp.bottom)
            $0.leading.trailing.bottom.equalTo(self)
        }
        
        playerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview()
        }
        
        playerViewHeightConstraint = NSLayoutConstraint(
            item: playerView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 0
        )
        playerViewHeightConstraint.isActive = true
    }
    
    private func bindUI() {
        tableView.rx
            .setDelegate(self)
            .disposed(by: youTubeViewModel.bag)
        
        youTubeViewModel.dataSource
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: youTubeViewModel.bag)
    }
    
    private func bindObservers() {
        playerViewHeight
            .bind(to: playerViewHeightConstraint.rx.animated.layout(duration: 0.3).constant)
            .disposed(by: youTubeViewModel.bag)
    }
    
    private func startTimer() {
        youTubeViewModel.startTimer()
    }
}

// MARK: - DataSource Configuration

extension MainView {
    
    private var configureCell: DataSource.ConfigureCell {
        return { _, tableView, indexPath, dataSource in
            switch dataSource.typeOfCell {
            case let .pageControl(channels):
                let cell = tableView.dequeueReusableCell(withIdentifier: PageControlCell.reuseID, for: indexPath) as! PageControlCell
                cell.contentView.backgroundColor = Asset.Colors.background.color
                cell.delegate = self
                cell.setupCell(with: channels, bind: self.youTubeViewModel.timerCounter)
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

// MARK: - table view delegate -

extension MainView: UITableViewDelegate {
    
    private func setupSectionHeaderView(for section: Int) -> UIView {
        let headerWidth = tableView.frame.width
        let headerHeight = youTubeViewModel.sectionHeaderHeight
        let headerRect = CGRect(x: 0, y: 0, width: headerWidth, height: headerHeight)
        let headerView = UIView(frame: headerRect)
        
        let textLabel = uiFactory
            .newLabel(
                text: youTubeViewModel.getSectionTitle(by: section),
                font: .SFPro.Display.Bold(size: 23).font,
                textColor: .white
            )
        headerView.addSubview(textLabel)
        
        textLabel.snp.makeConstraints { make in
            make.height.equalTo(headerHeight)
            make.leading.equalToSuperview().inset(youTubeViewModel.defaultPadding)
            make.width.equalTo(headerWidth / 2)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        } else {
            return youTubeViewModel.sectionHeaderHeight
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
    
    func stopTimer() {
        youTubeViewModel.stopTimer()
    }
    
    func channelDidSelect(_ channel: Channel) {
        switch playerViewHeight.value {
        case playerViewMinHeight:
            playerViewHeight.accept(playerViewMaxHeight)
        case playerViewMaxHeight:
            playerViewHeight.accept(playerViewMinHeight)
        default:
            break
        }
    }
}
