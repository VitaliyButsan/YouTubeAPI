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
    private lazy var topBarTitleLabel = uiFactory.newLabel(text: "YouTubeAPI", font: .SFProDisplayBold(size: 34))
    
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
        setupNavBar()
        setupLayout()
    }
    
    private func setupNavBar() {
        
    }
    
    private func setupLayout() {
        backgroundColor = .white
        
        topBarView.addSubview(topBarTitleLabel)
        
        addSubview(topBarView)
        addSubview(pageViewController.view)
        
        setupPageControl()
        addConstraints()
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
            $0.top.equalTo(snp.topMargin).offset(defaultPadding * 2)
            $0.leading.equalTo(defaultPadding)
            $0.trailing.equalTo(-defaultPadding)
            $0.height.equalTo(200)
        }
    }
    
    private func setupPageControl() {
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
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
}
