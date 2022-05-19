//
//  PlayerView.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 18.05.2022.
//

import UIKit
import RxCocoa
import RxSwift

enum OpenCloseState {
    case open
    case close
}

class PlayerView: UIView {
    
    // MARK: - Properties
    
    private var playerViewModel: PlayerViewModel!
    private var uiFactory: UIFactory!
    private let bag = DisposeBag()
    
    var didLayoutSubviewsSubject = PublishRelay<Void>()
    var isPlayerOpened = BehaviorRelay<OpenCloseState>(value: .close)
    var yOffset = BehaviorRelay<CGFloat>(value: 0.0)
    
    // MARK: - UI Elements
    
    private lazy var openCloseButton = uiFactory.newButton(image: Asset.Player.Controls.chevronDown.image)
    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(detectPan))
    
    // MARK: - Lifecycle
    
    convenience init(viewModel: PlayerViewModel?, uiFactory: UIFactory?) {
        self.init(frame: .zero)
        
        guard let viewModel = viewModel, let uiFactory = uiFactory else {
            fatalError("MainView init")
        }
        self.playerViewModel = viewModel
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
        openCloseButton.rotate()
        openCloseButton.isUserInteractionEnabled = false
    }
    
    private func addConstraints() {
        openCloseButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func setupObservers() {
        didLayoutSubviewsSubject
            .subscribe { [unowned self] _ in
                setGradientBackground()
            }
            .disposed(by: bag)
    }
    
    @objc private func detectPan(_ recognizer: UIPanGestureRecognizer) {
        let transition = recognizer.translation(in: self)
        switch recognizer.state {
        case .changed:
            yOffset.accept(transition.y)
        case .ended:
            isPlayerOpened.accept(.close)
        default:
            break
        }
        recognizer.setTranslation(.zero, in: self)
    }
}
