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
    private let bag = DisposeBag()
    
    // MARK: - UI Elements
    
    // MARK: - Lifecycle
    
    convenience init(viewModel: PlayerViewModel?, uiFactory: UIFactory?, progressView: CustomProgressView?) {
        self.init(frame: .zero)

        guard let viewModel = viewModel,
              let uiFactory = uiFactory,
              let progressView = progressView
        else {
            fatalError("ControlPanelVew init")
        }
        self.playerViewModel = viewModel
        self.uiFactory = uiFactory
        self.progressView = progressView
        setup()
    }
//
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
    
    private func setupViews() {
        backgroundColor = .blue
        addSubview(progressView)
    }
    
    private func addConstraints() {
        progressView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(19)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupObservers() {
        
    }
}
