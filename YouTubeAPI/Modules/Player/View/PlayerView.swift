//
//  PlayerView.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 18.05.2022.
//

import RxCocoa
import RxSwift
import UIKit
import YouTubePlayer

enum PlayerOpenCloseState {
    case open
    case close
}

enum PlayerWorkState {
    case play, stop, pause
}

class PlayerView: UIView {
    
    // MARK: - Properties
    
    private var playerViewModel: PlayerViewModel!
    private var uiFactory: UIFactory!
    private var controlPanelView: ControlPanelView!
    private let bag = DisposeBag()
    
    var didLayoutSubviewsSubject = PublishRelay<Void>()
    var isPlayerOpened = BehaviorRelay<PlayerOpenCloseState>(value: .close)
    var yOffset = BehaviorRelay<CGFloat>(value: 0.0)
    
    // MARK: - UI Elements
    
    private lazy var openCloseButton = uiFactory.newButton(image: Asset.Player.Controls.chevronDown.image)
    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(detectPan))
    private lazy var videoPlayer = YouTubePlayerView()
    
    // MARK: - Lifecycle
    
    convenience init(viewModel: PlayerViewModel?, uiFactory: UIFactory?, controlPanel: ControlPanelView?) {
        self.init(frame: .zero)
        
        guard let viewModel = viewModel,
              let uiFactory = uiFactory,
              let controlPanel = controlPanel
        else {
            fatalError("MainView init")
        }
        self.playerViewModel = viewModel
        self.uiFactory = uiFactory
        self.controlPanelView = controlPanel
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
        videoPlayer.delegate = self
    }
    
    private func setGradientBackground() {
        let topColor = Asset.Colors.playerUpperBoundGradient.color.cgColor
        let bottomColor = Asset.Colors.playerLowerBoundGradient.color.cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupViews() {
        layer.cornerRadius = Constants.playerViewCornerRadius
        layer.masksToBounds = true
        
        addGestureRecognizer(panGesture)
        
        addSubview(openCloseButton)
        
        addSubview(videoPlayer)
//        videoPlayer.loadVideoID("5ww7JyxV1ds")
        videoPlayer.loadVideoID("v6EjmbMgv80")
        videoPlayer.backgroundColor = .gray
        
        addSubview(controlPanelView)
        
        openCloseButton.isUserInteractionEnabled = false
    }
    
    private func addConstraints() {
        openCloseButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.centerX.equalToSuperview()
        }
        videoPlayer.snp.makeConstraints {
            $0.top.equalToSuperview().offset(47)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(235)
        }
        controlPanelView.snp.makeConstraints {
            $0.top.equalTo(videoPlayer.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupObservers() {
        didLayoutSubviewsSubject
            .subscribe { [unowned self] _ in
                setGradientBackground()
            }
            .disposed(by: bag)
        
        isPlayerOpened
            .subscribe(onNext: { [unowned self] event in
                switch event {
                case .open:
                    self.playerViewModel.state.accept(.play)
                case .close:
                    self.playerViewModel.state.accept(.stop)
                }
                self.openCloseButton.rotate()
            })
            .disposed(by: bag)
        
        playerViewModel.state
            .subscribe(onNext: { state in
                self.setPlayerState(state)
                
                switch state {
                case .play:
                    break
                case .pause:
                    break
                case .stop:
                    break
                }
            })
            .disposed(by: playerViewModel.bag)
    }
    
    private func setPlayerState(_ state: PlayerWorkState) {
        switch state {
        case .play:
            videoPlayer.play()
        case .pause:
            videoPlayer.pause()
        case .stop:
            videoPlayer.stop()
        }
    }
    
    private func getVideoDuration() {
        videoPlayer.getDuration { duration in
            guard let duration = duration else { return }
            self.playerViewModel.duration = duration
        }
    }
    
    private func startVideoTimeTracking() {
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance).bind { timePassed in
            self.videoPlayer.getCurrentTime { time in
                guard let time = time else { return }
                self.playerViewModel.currentTime.accept(time)
            }
        }.disposed(by: bag)
    }
    
    @objc private func detectPan(_ recognizer: UIPanGestureRecognizer) {
        let point = recognizer.translation(in: self)
        
        switch recognizer.state {
        case .changed:
            yOffset.accept(point.y)
        case .ended:
            if frame.minY >= (Constants.halfScreenHeight / 2) {
                isPlayerOpened.accept(.close)
            } else {
                isPlayerOpened.accept(.open)
            }
        default:
            break
        }
        recognizer.setTranslation(.zero, in: self)
    }
}

// MARK: YouTubePlayerDelegate

extension PlayerView: YouTubePlayerDelegate {
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        getVideoDuration()
    }
    
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        switch playerState {
        case .Playing:
            startVideoTimeTracking()
        default:
            break
        }
    }
}
