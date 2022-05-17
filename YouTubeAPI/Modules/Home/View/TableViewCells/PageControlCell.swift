//
//  PageControlCell.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 12.05.2022.
//

import SnapKit
import SDWebImage

class PageControlCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseID = "PageControlCell"
    
    private var currentIndex: Int?
    private var pendingIndex: Int?
    
    private var defaultPadding: CGFloat {
        return Constants.defaultPadding
    }
    
    private var uiFactory = UIFactory()
    
    // MARK: - UI Elements
    
    private lazy var pageViewControllerContainer = uiFactory.newView()
    private lazy var pageControl = uiFactory.newPageControl()
    
    private lazy var pageViewController: UIPageViewController = {
        let viewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        viewController.dataSource = self
        viewController.delegate = self
        viewController.view.layer.cornerRadius = 6
        return viewController
    }()
    
    private var pages: [UIViewController] = []
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(with channels: [Channel]) {
        textLabel?.text = channels[0].brandingSettings.channel.title
        if pages.isEmpty {
            addPages(by: channels.count)
            setupPageControl(with: pages.count)
        }
    }
    
    private func setupPageControl(with pagesCount: Int) {
        pageControl.numberOfPages = pagesCount
        pageControl.currentPage = 0
        
    }
    
    private func addPages(by channelsCount: Int) {
        for _ in 0..<channelsCount {
            let vc = uiFactory.newViewController(color: .random)
            pages.append(vc)
        }
        setupPageViewController()
    }
    
    private func setupLayout() {
        setupViews()
        addConstraints()
    }
    
    private func setupViews() {
        pageViewControllerContainer.addSubview(pageViewController.view)
        pageViewControllerContainer.addSubview(pageControl)
        contentView.addSubview(pageViewControllerContainer)
    }
    
    private func setupPageViewController() {
        if let firstViewController = pages.first {
            pageViewController.setViewControllers(
                [firstViewController],
                direction: .forward,
                animated: true,
                completion: nil
            )
        }
    }
    
    private func addConstraints() {
        pageViewControllerContainer.snp.makeConstraints {
            $0.top.equalTo(contentView).offset(32)
            $0.leading.equalTo(contentView).offset(defaultPadding)
            $0.trailing.equalTo(contentView).inset(defaultPadding)
            $0.bottom.equalTo(contentView).inset(defaultPadding)
            $0.height.equalTo(200)
        }
        pageViewController.view.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(180)
        }
        
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(pageViewController.view.snp.bottom)
            $0.width.equalTo(140)
            $0.height.equalTo(30)
        }
    }
}

// MARK: - UIPageViewControllerDataSource

extension PageControlCell: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.firstIndex(of:viewController)!
            if currentIndex == 0 {
                return nil
            }
            let previousIndex = abs((currentIndex - 1) % pages.count)
            return pages[previousIndex]
        }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
            let currentIndex = pages.firstIndex(of:viewController)!
            if currentIndex == pages.count - 1 {
                return nil
            }
            let nextIndex = abs((currentIndex + 1) % pages.count)
            return pages[nextIndex]
        }

    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {
            pendingIndex = pages.firstIndex(of:pendingViewControllers.first!)
        }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed {
                currentIndex = pendingIndex
                if let index = currentIndex {
                    pageControl.currentPage = index
                }
            }
        }
}

extension UIColor {
    
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}
