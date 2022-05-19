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
    
    var didLayoutSubviewsSubject = PublishRelay<Void>()
    private let bag = DisposeBag()
    
    var isPlayerOpened = BehaviorRelay<OpenCloseState>(value: .open)
    
    // MARK: - UI Elements
    
    private lazy var openCloseButton = uiFactory.newButton(image: Asset.Player.Controls.chevronDown.image)
    
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
        
        addSubview(openCloseButton)
        openCloseButton.rotate()
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
        
        openCloseButton.rx.tap.subscribe { [unowned self] _ in
            switch isPlayerOpened.value {
            case .open:
                isPlayerOpened.accept(.close)
            case .close:
                isPlayerOpened.accept(.open)
            }
            openCloseButton.rotate()
        }
        .disposed(by: bag)
    }
}
