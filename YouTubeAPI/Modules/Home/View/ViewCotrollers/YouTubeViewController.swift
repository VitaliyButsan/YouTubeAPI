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
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        youTubeViewModel.getData()
    }
}
