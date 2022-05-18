//
//  YouTubeViewController.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 10.05.2022.
//

import UIKit
import SnapKit

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
    
    private func setupNavBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func getData() {
        youTubeViewModel.getData()
    }
    
    private func setupObservers() {
        youTubeViewModel.errorSubject
            .subscribe(onNext: { error in
                self.showAlert(message: error)
            })
            .disposed(by: youTubeViewModel.bag)
    }
}
