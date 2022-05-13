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

class MainView: UIView {
    
    // MARK: - Properties
    
    typealias DataSource = RxTableViewSectionedReloadDataSource<ChannelSection>
    
    private var youTubeViewModel: YouTubeViewModel!
    private var uiFactory: UIFactory!
    
    private lazy var dataSource: DataSource = .init(configureCell: configureCell)
    
    // MARK: - UI Elements
    
    private lazy var topBarView = uiFactory.newView(color: .clear)
    private lazy var topBarTitleLabel = uiFactory
        .newLabel(
            text: "YouTube API",
            font: .SFPro.Display.Bold(size: 34).font,
            textColor: .white
        )
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .gray
        tableView.estimatedSectionHeaderHeight = 0
        tableView.register(PageControlCell.self, forCellReuseIdentifier: PageControlCell.reuseID)
        tableView.register(PlaylistCell.self, forCellReuseIdentifier: PlaylistCell.reuseID)
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    convenience init(viewModel: YouTubeViewModel?, uiFactory: UIFactory?) {
        self.init(frame: .zero)
        
        guard let viewModel = viewModel, let uiFactory = uiFactory else {
            fatalError("MainView init")
        }
        self.youTubeViewModel = viewModel
        self.uiFactory = uiFactory
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
    }
    
    private func setupViews() {
        backgroundColor = Asset.Colors.background.color
        topBarView.addSubview(topBarTitleLabel)
        addSubview(topBarView)
        addSubview(tableView)
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
    }
    
    private func bindUI() {
        youTubeViewModel.dataSource
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: youTubeViewModel.bag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: youTubeViewModel.bag)
    }
}

// MARK: - DataSource Configuration

extension MainView {
    
    private var configureCell: DataSource.ConfigureCell {
        return { _, tableView, indexPath, dataSource in
            switch dataSource.typeOfCell {
            case let .pageControl(channels):
                let cell = tableView.dequeueReusableCell(withIdentifier: PageControlCell.reuseID, for: indexPath) as! PageControlCell
                cell.setupCell(with: channels)
                return cell
            case let .playlist(playlist):
                let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistCell.reuseID, for: indexPath) as! PlaylistCell
                cell.setupCell(with: playlist)
                return cell
            }
        }
    }
}

// MARK: - table view delegate -

extension MainView: UITableViewDelegate {
    
    private func setupSectionHeaderView(for section: Int) -> UIView {
        let sectionTitle = youTubeViewModel.getSectionTitle(by: section)
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        headerView.backgroundColor = .gray
        
        let textLabel = UILabel()
        textLabel.font = .systemFont(ofSize: 15)
        textLabel.textColor = .black
        textLabel.text = sectionTitle
        
        headerView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        let separator = UIView()
        separator.backgroundColor = .lightGray
        
        headerView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(headerView)
            make.height.equalTo(1)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            return setupSectionHeaderView(for: section)
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            return 20
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 250
        default:
            return 150
        }
    }
}
