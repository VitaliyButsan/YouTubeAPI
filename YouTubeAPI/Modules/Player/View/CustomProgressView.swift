//
//  CustomProgressView.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 19.05.2022.
//

import UIKit
import RxSwift

class CustomProgressView: UIView {
    
    // MARK: - Properties
    
    private var playerViewModel: PlayerViewModel!
    private var uiFactory: UIFactory!
    private let bag = DisposeBag()
    
    // MARK: - UI Elements
    
    private lazy var progressView = UIProgressView()
    
    private lazy var leftTimeLabel = uiFactory
        .newLabel(
            text: "0:00",
            font: .SFPro.Text.Regular(size: 11).font,
            textColor: Asset.Colors.playerTransparentWhite70.color
        )
    private lazy var rightTimeLabel = uiFactory
        .newLabel(
            text: "-9:99",
            font: .SFPro.Text.Medium(size: 11).font,
            textColor: Asset.Colors.playerTransparentWhite70.color
        )
    
    // MARK: - Lifecycle
    
    convenience init(viewModel: PlayerViewModel?, uiFactory: UIFactory?) {
        self.init(frame: .zero)
        
        guard let viewModel = viewModel, let uiFactory = uiFactory else {
            fatalError("CustomProgressView init")
        }
        self.playerViewModel = viewModel
        self.uiFactory = uiFactory
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setupViews()
        addConstraints()
        setupObservers()
    }
    
    private func setupViews() {
        progressView.progressTintColor = .white
        progressView.trackTintColor = Asset.Colors.playerTransparentWhite35.color
        progressView.progress = 0.5
        
        addSubview(progressView)
        addSubview(leftTimeLabel)
        addSubview(rightTimeLabel)
    }
    
    private func addConstraints() {
        progressView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.leading.equalToSuperview().offset(13)
            $0.trailing.equalToSuperview().inset(13)
        }
        leftTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(progressView)
            $0.top.equalTo(progressView.snp.bottom).offset(7)
        }
        rightTimeLabel.snp.makeConstraints {
            $0.trailing.equalTo(progressView)
            $0.top.equalTo(progressView.snp.bottom).offset(7)
        }
    }
    
    private func setupObservers() {
        
    }
    
}
