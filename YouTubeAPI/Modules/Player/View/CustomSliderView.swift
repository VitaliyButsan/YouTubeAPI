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
    private var uiFactory: UIFactory!
    private let bag = DisposeBag()
    
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
            .disposed(by: playerViewModel.bag)

        playerViewModel.volume
            .subscribe(onNext: { volume in
                self.systemVolumeView.setVolume(volume)
            })
            .disposed(by: playerViewModel.bag)
        
        playerViewModel.systemVolume
            .bind(to: sliderView.rx.value)
            .disposed(by: playerViewModel.bag)
        
        playerViewModel.isPlayerOpened
            .subscribe(onNext: { state in
                switch state {
                case .open:
                    self.setSystemVolume(by: state)
                    self.systemVolumeView.alpha = 0.001 // hide
                case .close:
                    self.systemVolumeView.alpha = 0.0 // show
                }
            })
            .disposed(by: bag)
    }
    
    private func setSystemVolume(by state: PlayerOpenCloseState) {
        guard playerViewModel.previousPlayerOpenedState != state else { return }
        let systemVolume = systemVolumeView.getVolume()
        playerViewModel.volume.accept(systemVolume)
        sliderView.value = systemVolume
    }
}
