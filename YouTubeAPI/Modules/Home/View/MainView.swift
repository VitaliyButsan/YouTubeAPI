//
//  MainView.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import UIKit
import SnapKit

class MainView: UIView {
    
    // MARK: - Properties
    
    private var youTubeViewModel: YouTubeViewModel!
    private var uiFactory: UIFactory!
    
    private var defaultPadding: CGFloat = 18.0
    
    // MARK: - UI Elements
    
    private lazy var topBarView = uiFactory.newView()
    private lazy var topBarTitleLabel = uiFactory.newLabel(text: "YouTubeAPI", font: .SFPro.Display.Bold(size: 34).font)
    
    private lazy var pageViewController: UIPageViewController = {
        let viewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        viewController.dataSource = self
        viewController.view.backgroundColor = .black
        return viewController
    }()
    
    private lazy var orderedViewControllers: [UIViewController] = {
        [uiFactory.getViewController(color: .red),
         uiFactory.getViewController(color: .blue),
         uiFactory.getViewController(color: .green),
         uiFactory.getViewController(color: .orange)]
//        let count = youTubeViewModel.channelsIdsCount()
//        return Array(repeating: UIViewController(), count: count)
    }()
    
    // MARK: - Lifecycle
    
    convenience init(viewModel: YouTubeViewModel?, uiFactory: UIFactory?) {
        self.init(frame: .zero)
        
        guard let viewModel = viewModel, let uiFactory = uiFactory else {
            fatalError("MainView init")
        }
        self.youTubeViewModel = viewModel
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
        setupPageViewController()
        addConstraints()
    }
    
    private func setupViews() {
        backgroundColor = .white
        topBarView.addSubview(topBarTitleLabel)
        addSubview(topBarView)
        addSubview(pageViewController.view)
    }
    
    private func addConstraints() {
        topBarView.snp.makeConstraints {
            $0.leading.trailing.top.equalTo(self)
            $0.height.equalTo(92)
        }
        topBarTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(topBarView).offset(24)
            $0.bottom.equalTo(topBarView)
        }
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(snp.topMargin).offset(32)
            $0.leading.equalTo(defaultPadding)
            $0.trailing.equalTo(-defaultPadding)
            $0.height.equalTo(200)
        }
    }
    
    private func setupPageViewController() {
        if let firstViewController = orderedViewControllers.first {
            pageViewController.setViewControllers(
                [firstViewController],
                direction: .forward,
                animated: true,
                completion: nil
            )
        }
    }
    
}

// MARK: - UIPageViewControllerDataSource

extension MainView: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = orderedViewControllers.firstIndex(of: viewController) {
            if index > 0 {
                return orderedViewControllers[index - 1]
            } else {
                return nil
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = orderedViewControllers.firstIndex(of: viewController) {
            if index < orderedViewControllers.count - 1 {
                return orderedViewControllers[index + 1]
            } else {
                return nil
            }
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}
