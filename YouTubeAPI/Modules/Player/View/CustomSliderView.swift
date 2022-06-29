//
//  CustomSliderView.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 20.05.2022.
//

import RxSwift
import RxCocoa
import SnapKit
import UIKit

class CustomSliderView: UIView {
    
    // MARK: - Properties
    
    private var playerViewModel: PlayerViewModel!
    
    private let uiFactory = UIFactory()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Elements
    
    private lazy var systemVolumeView = uiFactory.newSystemVolumeView()
    
    private lazy var sliderView = uiFactory
        .newSliderView(
            minimumTrackTintColor: .white,
            maximumTrackTintColor: Asset.Colors.playerTransparentWhite35.color
        )
    private lazy var soundMinImageView = uiFactory
        .newImageView(
            image: Asset.Player.Controls.soundMin.image,
            tintColor: Asset.Colors.playerTransparentWhite35.color
        )
    private lazy var soundMaxImageView = uiFactory
        .newImageView(
            image: Asset.Player.Controls.soundMax.image,
            tintColor: Asset.Colors.playerTransparentWhite35.color
        )
    
    // MARK: - Init
    
    convenience init(viewModel: PlayerViewModel) {
        self.init(frame: .zero)
        
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
        addConstraints()
        setupObservers()
    }
    
    private func setupViews() {
        addSubview(soundMinImageView)
        addSubview(sliderView)
        addSubview(soundMaxImageView)
        addSubview(systemVolumeView)
    }
    
    private func addConstraints() {
        soundMinImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        soundMaxImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        sliderView.snp.makeConstraints {
            $0.leading.equalTo(soundMinImageView.snp.trailing).offset(15)
            $0.trailing.equalTo(soundMaxImageView.snp.leading).inset(-10)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func setupObservers() {
        sliderView.rx.value
            .bind(to: playerViewModel.volume)
            .disposed(by: disposeBag)

        playerViewModel.volume
            .subscribe(onNext: { volume in
                self.systemVolumeView.setVolume(volume)
            })
            .disposed(by: disposeBag)
        
        playerViewModel.systemVolume
            .bind(to: sliderView.rx.value)
            .disposed(by: disposeBag)
        
        playerViewModel.playerOpenState
            .subscribe(onNext: { state in
                switch state {
                case .open:
                    self.setSystemVolume(by: state)
                    self.hideSystemVolumeView()
                case .close:
                    self.showSystemVolumeView()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setSystemVolume(by state: ShowPlayerState) {
        if playerViewModel.previousPlayerOpenedState != state {
            sliderView.value = systemVolumeView.getVolume()
        }
    }
    
    private func hideSystemVolumeView() {
        self.systemVolumeView.alpha = 0.001
    }
    
    private func showSystemVolumeView() {
        self.systemVolumeView.alpha = 0.0
    }
}

