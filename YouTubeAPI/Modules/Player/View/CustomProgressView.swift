//
//  CustomProgressView.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 19.05.2022.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class CustomProgressView: UIView {
    
    // MARK: - Properties
    
    private var playerViewModel: PlayerViewModel!
    
    private let uiFactory = UIFactory()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Elements
    
    private lazy var progressPointerThumb = uiFactory
        .newView(frame: CGRect(x: 0, y: 0, width: 2, height: 12))
        .asImage()
    
    private lazy var progressView = uiFactory
        .newSliderView(
            minimumTrackTintColor: .white,
            maximumTrackTintColor: Asset.Colors.playerTransparentWhite35.color
        )
    private lazy var currentTimeLabel = uiFactory
        .newLabel(
            font: .SFPro.Text.Regular(size: 11).font,
            textColor: Asset.Colors.playerTransparentWhite70.color
        )
    private lazy var remainingTimeLabel = uiFactory
        .newLabel(
            font: .SFPro.Text.Medium(size: 11).font,
            textColor: Asset.Colors.playerTransparentWhite70.color
        )
    
    // MARK: - Lifecycle
    
    convenience init(viewModel: PlayerViewModel?) {
        self.init(frame: .zero)
        
        guard let viewModel = viewModel else {
            fatalError("CustomProgressView init")
        }
        playerViewModel = viewModel
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setup() {
        setupViews()
        setupProgressView()
        addConstraints()
        setupObservers()
    }
    
    private func setupViews() {
        addSubview(progressView)
        addSubview(currentTimeLabel)
        addSubview(remainingTimeLabel)
    }
    
    private func setupProgressView() {
        progressView.setThumbImage(progressPointerThumb, for: .normal)
        progressView.isUserInteractionEnabled = false
    }
    
    private func addConstraints() {
        progressView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        currentTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(progressView)
            $0.top.equalTo(progressView.snp.bottom).offset(7)
        }
        remainingTimeLabel.snp.makeConstraints {
            $0.trailing.equalTo(progressView)
            $0.top.equalTo(progressView.snp.bottom).offset(7)
        }
    }
    
    private func setupObservers() {
        playerViewModel.currentTimeFormatted
            .bind(to: currentTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        playerViewModel.remainTimeFormatted
            .bind(to: remainingTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        playerViewModel.progress
            .bind(to: progressView.rx.value)
            .disposed(by: disposeBag)
    }
}
