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
    
    // MARK: - UI Elements
    
    private lazy var pageViewController: UIPageViewController = {
        let viewController = UIPageViewController()
        viewController.dataSource = self
        return viewController
    }()
    
    private lazy var orderedViewControllers: [UIViewController] = {
        let count = youTubeViewModel.channelsIdsCount()
        return Array(repeating: UIViewController(), count: count)
    }()
    
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
        
        setup()
    }
    
    private func setup() {
        setupNavBar()
        setupLayout()
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "YouTubeAPI"
    }
    
    private func setupLayout() {
        view.backgroundColor = .white
        
        
    }
    
}

// MARK: - UIPageViewControllerDataSource

extension YouTubeViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
}
