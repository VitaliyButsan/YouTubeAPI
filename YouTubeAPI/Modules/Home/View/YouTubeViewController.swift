//
//  YouTubeViewController.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 10.05.2022.
//

import UIKit

class YouTubeViewController: UIViewController {
    
    // MARK: - Properties
    
    private var youTubeViewModel: YouTubeViewModel!
    
    // MARK: - Lifecycle
    
    convenience init(viewModel: YouTubeViewModel?) {
        self.init(nibName: nil, bundle: nil)
        guard let viewModel = viewModel else {
            fatalError("YouTubeViewController init")
        }
        self.youTubeViewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .orange
        youTubeViewModel.getData()
    }
    
}

