//
//  PlayerControlPanelView.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 19.05.2022.
//

import RxSwift
import RxCocoa
import SnapKit
import UIKit

class PlayerControlPanelView: UIView {
    
    // MARK: - Properties
    
    private var playerViewModel: PlayerViewModel!
    
    private let uiFactory = UIFactory()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Elements
    
    private lazy var progressView = CustomProgressView(viewModel: playerViewModel)
    private lazy var sliderView = CustomSliderView(viewModel: playerViewModel)
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
    private lazy var controlButtonsStackView = uiFactory
        .newStackView(
            axis: .horizontal,
            distribution: .equalCentering
        )
    
    private lazy var prevButton = uiFactory.newButton(image: Asset.Player.Controls.prev.image)
    private lazy var nextButton = uiFactory.newButton(image: Asset.Player.Controls.next.image)
    private lazy var playButton = uiFactory.newButton(image: Asset.Player.Controls.play.image)
    
    private lazy var soundMinImageView = uiFactory.newImageView(image: Asset.Player.Controls.soundMin.image)
    private lazy var soundMaxImageView = uiFactory.newImageView(image: Asset.Player.Controls.soundMax.image)
    
    // MARK: - Lifecycle
    
    convenience init(viewModel: PlayerViewModel?) {
        self.init(frame: .zero)

        guard let viewModel = viewModel else {
            fatalError("ControlPanelView init")
        }
        playerViewModel = viewModel
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
        setupObservers()
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
            $0.leading.equalToSuperview().offset(13)
            $0.trailing.equalToSuperview().inset(13)
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
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().inset(15)
            $0.height.equalTo(21)
        }
    }
    
    private func setupPlayButton(by state: PlayerWorkState) {
        switch state {
        case .play:
            playButton.setImage(Asset.Player.Controls.pause.image, for: .normal)
        case .pause, .stop:
            playButton.setImage(Asset.Player.Controls.play.image, for: .normal)
        default:
            break
        }
    }
    
    private func setupObservers() {
        prevButton.rx.tap
            .bind { self.playerViewModel.state.accept(.prev) }
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind { self.playerViewModel.state.accept(.next) }
            .disposed(by: disposeBag)
        
        playButton.rx.tap
            .bind {
                switch self.playerViewModel.state.value {
                case .play:
                    self.playerViewModel.state.accept(.pause)
                case .pause:
                    self.playerViewModel.state.accept(.play)
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        playerViewModel.state
            .subscribe(onNext: { state in
                self.setupPlayButton(by: state)
            })
            .disposed(by: disposeBag)
        
        playerViewModel.videoTitle
            .bind(to: videoTitleLabel.rx.text)
            .disposed(by: disposeBag)
        
        playerViewModel.videoViewCounter
            .bind(to: videoViewsCountLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
