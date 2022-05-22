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
    
    private var mainView: UIView!
    
    // MARK: - Lifecycle
    
    convenience init(viewModel: YouTubeViewModel?, view: UIView?) {
        self.init(nibName: nil, bundle: nil)
        
        guard let viewModel = viewModel, let view = view else {
            fatalError("YouTubeViewController init")
        }
        self.youTubeViewModel = viewModel
        self.mainView = view
    }
    
    override func loadView() {
        super.loadView()
        
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupObservers()
//        getData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let mainView = mainView as? MainView {
            mainView.youTubeViewModel.didLayoutSubviewsSubject.accept(())
        }
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
            .subscribe(onNext: { error in
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
