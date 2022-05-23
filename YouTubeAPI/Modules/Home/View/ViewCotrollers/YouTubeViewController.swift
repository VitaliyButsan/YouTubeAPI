//
//  YouTubeViewController.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 10.05.2022.
//

import ProgressHUD
import RxCocoa
import SnapKit
import UIKit

class YouTubeViewController: UIViewController {
    
    // MARK: - Properties
    
    private var youTubeViewModel: YouTubeViewModel!
    
    // MARK: - UI Elements
    
    private lazy var mainView = MainView(viewModel: youTubeViewModel)
    
    // MARK: - Lifecycle
    
    convenience init(viewModel: YouTubeViewModel?) {
        self.init(nibName: nil, bundle: nil)
        
        guard let viewModel = viewModel else {
            fatalError("YouTubeViewController init")
        }
        self.youTubeViewModel = viewModel
    }
    
    override func loadView() {
        super.loadView()
        
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupObservers()
        getData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mainView.youTubeViewModel?.didLayoutSubviewsSubject.accept(Void())
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func getData() {
        youTubeViewModel.getData()
        ProgressHUD.showRotationHUD()
    }
    
    private func setupObservers() {
        youTubeViewModel.errorSubject
            .subscribe(onNext: { [unowned self] error in
                ProgressHUD.hideHUD()
                self.showAlert(message: error)
            })
            .disposed(by: youTubeViewModel.bag)
        
        youTubeViewModel.isLoadedData
            .filter { $0 }
            .subscribe { _ in ProgressHUD.hideHUD() }
            .disposed(by: youTubeViewModel.bag)
    }
}
