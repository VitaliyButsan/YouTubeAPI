//
//  ControlPanelView.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 19.05.2022.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ControlPanelView: UIView {
    
    // MARK: - Properties
    
    private var playerViewModel: PlayerViewModel!
    private var uiFactory: UIFactory!
    private var progressView: CustomProgressView!
    private var sliderView: CustomSliderView!
    private let bag = DisposeBag()
    
    // MARK: - UI Elements
    
    private lazy var videoInfoStackView = uiFactory.newStackView(spacing: 5.0)
    private lazy var videoTitleLabel = uiFactory
        .newLabel(
            font: .SFPro.Text.Medium(size: 18).font,
            textColor: .white
        )
    private lazy var videoViewsCountLabel = uiFactory
        .newLabel(
            font: .SFPro.Text.Regular(size: 16).font,
            textColor: Asset.Colors.playerTransparentWhite70.color
        )
    
    private lazy var controlButtonsStackView = uiFactory.newStackView(axis: .horizontal, distribution: .equalCentering)
    private lazy var prevButton = uiFactory.newButton(image: Asset.Player.Controls.prev.image)
    private lazy var nextButton = uiFactory.newButton(image: Asset.Player.Controls.next.image)
    private lazy var playButton = uiFactory.newButton(image: Asset.Player.Controls.play.image)
    
    private lazy var soundMinImageView = uiFactory.newImageView(image: Asset.Player.Controls.soundMin.image)
    private lazy var soundMaxImageView = uiFactory.newImageView(image: Asset.Player.Controls.soundMax.image)
    
    // MARK: - Lifecycle
    
    convenience init(viewModel: PlayerViewModel?, uiFactory: UIFactory?, progressView: CustomProgressView?, sliderView: CustomSliderView?) {
        self.init(frame: .zero)

        guard let viewModel = viewModel,
              let uiFactory = uiFactory,
              let progressView = progressView,
              let sliderView = sliderView
        else {
            fatalError("ControlPanelView init")
        }
        self.playerViewModel = viewModel
        self.uiFactory = uiFactory
        self.progressView = progressView
        self.sliderView = sliderView
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
        setupObservers()
        
        videoTitleLabel.text = "Video track title description info"
        videoViewsCountLabel.text = ("3440304040".splitIntoThounsandParts ?? "0") + " просмотра"
    }
    
    private func setupViews() {
        addSubview(progressView)
        
        videoInfoStackView.addArrangedSubview(videoTitleLabel)
        videoInfoStackView.addArrangedSubview(videoViewsCountLabel)
        addSubview(videoInfoStackView)
        
        controlButtonsStackView.addArrangedSubview(prevButton)
        controlButtonsStackView.addArrangedSubview(playButton)
        controlButtonsStackView.addArrangedSubview(nextButton)
        addSubview(controlButtonsStackView)
        
        addSubview(sliderView)
    }
    
    private func addConstraints() {
        progressView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(19)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(31)
        }
        videoInfoStackView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(17)
            $0.width.equalTo(258)
            $0.centerX.equalToSuperview()
        }
        controlButtonsStackView.snp.makeConstraints {
            $0.top.equalTo(videoInfoStackView.snp.bottom).offset(41)
            $0.width.equalTo(176)
            $0.height.equalTo(30)
            $0.centerX.equalToSuperview()
        }
        sliderView.snp.makeConstraints {
            $0.top.equalTo(controlButtonsStackView.snp.bottom).offset(46)
            $0.leading.equalToSuperview().offset(17)
            $0.trailing.equalToSuperview().inset(17)
            $0.height.equalTo(21)
        }
    }
    
    private func setupObservers() {
        
    }
}
