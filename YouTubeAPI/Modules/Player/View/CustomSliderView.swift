//
//  CustomSliderView.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 20.05.2022.
//

import MediaPlayer
import RxSwift
import RxCocoa
import UIKit
//import Combine

class CustomSliderView: UIView {
    
    // MARK: - Properties
    
    private var playerViewModel: PlayerViewModel!
    private var uiFactory: UIFactory!
    private let bag = DisposeBag()
    
//    private var pub: CurrentValueSubject<AVAudioSession, Float>?
    
    // MARK: - UI Elements
    
    private lazy var sliderView = uiFactory
        .newSliderView(
            minimumTrackTintColor: .white,
            maximumTrackTintColor: Asset.Colors.playerTransparentWhite35.color,
            value: 0.5
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
        
        playerViewModel.volume.accept(sliderView.value)
    }
    
    private func setupViews() {
        addSubview(soundMinImageView)
        addSubview(sliderView)
        addSubview(soundMaxImageView)
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
                MPVolumeView.setVolume(volume)
            })
            .disposed(by: playerViewModel.bag)
        
        playerViewModel.volume
            .bind(to: sliderView.rx.value)
            .disposed(by: playerViewModel.bag)
        
        playerViewModel.state
            .subscribe(onNext: { state in
                switch state {
                case .play:
                    self.playerViewModel.volume.accept(self.sliderView.value)
                default:
                    break
                }
            })
            .disposed(by: playerViewModel.bag)
        
        setSystemVolumeChangingObserver()
    }
    
    private func setSystemVolumeChangingObserver() {
        NotificationCenter.default.rx.notification(.volumeChanging)
            .subscribe(onNext: { notification in
                guard let userInfo = notification.userInfo else { return }
                guard let anyValue = userInfo[NSNotification.Name.audioVolume] else { return }
                guard let volume = anyValue as? Float else { return }
                self.playerViewModel.volume.accept(volume)
            })
            .disposed(by: playerViewModel.bag)
    }
}
