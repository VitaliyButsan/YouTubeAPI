//
//  YouTubeViewController.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 10.05.2022.
//

import UIKit

class YouTubeViewController: UIViewController {
    
    private var youTubeViewModel: YouTubeViewModel!
    
    convenience init(viewModel: YouTubeViewModel?) {
        self.init(nibName: nil, bundle: nil)
        guard let viewModel = viewModel else {
            fatalError("YouTubeViewController init")
        }
        self.youTubeViewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .orange
        youTubeViewModel.getChannels(by: "UCkhh_JEXUpT9mAJHOATkIeg")
    }
    
}

