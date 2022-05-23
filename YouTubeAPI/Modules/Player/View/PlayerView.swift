//
//  PlayerView.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 18.05.2022.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit
import YouTubePlayer

enum PlayerOpenCloseState {
    case open, close
}

enum PlayerWorkState {
    case play, pause, stop, prev, next
}

class PlayerView: UIView {
    
    // MARK: - Properties
    
    private var timeTrackerBag = DisposeBag()
    
    private(set) var playerViewModel: PlayerViewModel!
    
    private let uiFactory = UIFactory()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Elements
    
    private lazy var openCloseButton = uiFactory.newButton(image: Asset.Player.Controls.chevronDown.image)
    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(detectPan))
    private lazy var videoPlayer = YouTubePlayerView()
    private lazy var controlPanelView = PlayerControlPanelView(viewModel: playerViewModel)
    
    // MARK: - Lifecycle
    
    convenience init(viewModel: PlayerViewModel?) {
        self.init(frame: .zero)
        
        guard let viewModel = viewModel else {
            fatalError("MainView init")
        }
        timeTrackerBag = DisposeBag()
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
        setupVideoPlayer()
        setupPreviousPlayerOpenedState()
        setupObservers()
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
        addSubview(controlPanelView)
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
    
    private func setupVideoPlayer() {
        videoPlayer.delegate = self
        videoPlayer.backgroundColor = .black
    }
    
    private func setupPreviousPlayerOpenedState() {
        switch playerViewModel.isPlayerOpened.value {
        case .open:
            playerViewModel.previousPlayerOpenedState = .close
        case .close:
            playerViewModel.previousPlayerOpenedState = .open
        }
    }
    
    private func setupObservers() {
        playerViewModel.didLayoutSubviewsSubject
            .subscribe { [unowned self] _ in
                setGradientBackground()
            }
            .disposed(by: disposeBag)
        
        playerViewModel.isPlayerOpened
            .subscribe(onNext: { [unowned self] state in
                switch state {
                case .open:
                    if playerViewModel.previousPlayerOpenedState != state {
                        self.setVideoToPlayer()
                        self.playerViewModel.state.accept(.play)
                    }
                case .close:
                    self.playerViewModel.state.accept(.stop)
                    self.stopVideoTimeTracking()
                }
                self.rotateOpenCloseButton(by: state)
                playerViewModel.previousPlayerOpenedState = state
            })
            .disposed(by: disposeBag)
        
        playerViewModel.state
            .subscribe(onNext: { state in
                self.setPlayerState(state)
            })
            .disposed(by: disposeBag)
    }
    
    private func setVideoToPlayer() {
        guard let startedVideo = playerViewModel.getStartedVideo() else { return }
        let videoID = startedVideo.snippet.resourceId.videoId
        videoPlayer.loadVideoID(videoID)
    }
    
    private func rotateOpenCloseButton(by state: PlayerOpenCloseState) {
        if playerViewModel.previousPlayerOpenedState != state {
            self.openCloseButton.rotate()
        }
    }
     
    private func setPlayerState(_ state: PlayerWorkState) {
        switch state {
        case .play:
            play()
        case .pause:
            pause()
        case .stop:
            stop()
        case .prev:
            playPrevious()
        case .next:
            playNext()
        }
    }
    
    private func getVideoDuration() {
        videoPlayer.getDuration { duration in
            guard let duration = duration else { return }
            self.playerViewModel.duration = duration
        }
    }
    
    private func startVideoTimeTracking() {
        Observable<Int>.interval(.milliseconds(100), scheduler: MainScheduler.instance).bind { _ in
            self.videoPlayer.getCurrentTime { time in
                guard let time = time else { return }
                self.playerViewModel.currentTime.accept(time)
            }
        }.disposed(by: timeTrackerBag)
    }
    
    private func stopVideoTimeTracking() {
        timeTrackerBag = DisposeBag()
    }
    
    private func play() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.videoPlayer.play()
        }
    }
    
    private func pause() {
        videoPlayer.pause()
    }
    
    private func stop() {
        videoPlayer.stop()
    }
    
    private func playPrevious() {
        let videoID = playerViewModel.getPreviousVideoId()
        videoPlayer.loadVideoID(videoID)
        setPlayerState(.play)
    }
    
    private func playNext() {
        let videoID = playerViewModel.getNextVideoId()
        videoPlayer.loadVideoID(videoID)
        setPlayerState(.play)
    }
    
    @objc private func detectPan(_ recognizer: UIPanGestureRecognizer) {
        let point = recognizer.translation(in: self)
        
        switch recognizer.state {
        case .changed:
            playerViewModel.yOffset.accept(point.y)
        case .ended:
            if frame.minY > Constants.quarterScreenHeight {
                playerViewModel.isPlayerOpened.accept(.close)
            } else {
                playerViewModel.isPlayerOpened.accept(.open)
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
            playerViewModel.state.accept(.play)
        case .Paused:
            playerViewModel.state.accept(.pause)
        default:
            break
        }
    }
}

// MARK: - Constants

extension PlayerView {
    
    private enum Constants {
        static let screenWidth: CGFloat = UIScreen.main.bounds.width
        static let screenHeight: CGFloat = UIScreen.main.bounds.height
        static let halfScreenWidth: CGFloat = screenWidth / 2
        static let halfScreenHeight: CGFloat = screenHeight / 2
        static let quarterScreenHeight: CGFloat = halfScreenHeight / 2
        static let playerViewCornerRadius: CGFloat = 20.0
    }
}
