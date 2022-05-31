//
//  PageControlCell.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 12.05.2022.
//

import RxCocoa
import RxSwift
import SnapKit

protocol PageControlCellDelegate: AnyObject {
    func switchChannel(by pageIndex: Int)
    func channelDidSelect(_ channel: Channel)
}

class PageControlCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: PageControlCellDelegate?
    
    private var pagesCounter = BehaviorRelay(value: 0)
    private var currentIndex = 0
    private var pendingIndex = 0
    
    private var channels: [Channel] = []
    private var pages: [UIViewController] = []
    
    static let reuseID = L10n.pageControlCellId
    
    private let disposeBag = DisposeBag()
    private let uiFactory = UIFactory()
    
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
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    
    func setupCell(with channels: [Channel], bind pagesCounter: BehaviorRelay<Int>) {
        self.channels = channels
        if pages.isEmpty {
            setupPageViewController(with: channels)
            setupPageControl()
            bind(pagesCounter)
        }
    }
    
    // MARK: - Private methods
    
    private func bind(_ counter: BehaviorRelay<Int>) {
        counter
            .bind(to: pagesCounter)
            .disposed(by: disposeBag)
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
    }
    
    private func setupPageViewController(with channels: [Channel]) {
        for channel in channels {
            let newPage = uiFactory.newPage(with: channel)
            pages.append(newPage)
        }
        addPagesToPageViewController()
        setupPageViewControllerGestures()
    }
    
    private func setupPageViewControllerGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.pageViewController.view.subviews[0].addGestureRecognizer(tapGesture)
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
    
    private func addPagesToPageViewController() {
        if let firstPage = pages.first {
            pageViewController.setViewControllers(
                [firstPage],
                direction: .forward,
                animated: true
            )
        }
    }
    
    private func addConstraints() {
        pageViewControllerContainer.snp.makeConstraints {
            $0.top.equalTo(contentView).offset(32)
            $0.leading.equalTo(contentView).offset(Constants.defaultPadding)
            $0.trailing.equalTo(contentView).inset(Constants.defaultPadding)
            $0.bottom.equalTo(contentView).inset(Constants.defaultPadding)
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
            $0.height.equalTo(40)
        }
    }
    
    private func moveCarousel() {
        if currentIndex == pages.count - 1 {
            currentIndex = 0
        } else {
            currentIndex += 1
        }
        let nextPage = pages[currentIndex]
        
        pageViewController.setViewControllers([nextPage], direction: .forward, animated: true) { completed in
            if completed {
                self.delegate?.switchChannel(by: self.currentIndex)
                self.pageControl.currentPage = self.currentIndex
            }
        }
    }
    
    private func setupObservers() {
        pagesCounter
            .filter { $0 > 0 }
            .subscribe(onNext: { _ in
                self.moveCarousel()
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func handleTap() {
        guard let delegate = delegate else { return }
        let channel = channels[currentIndex]
        delegate.channelDidSelect(channel)
    }
}

// MARK: - UIPageViewControllerDataSource

extension PageControlCell: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentPageIndex = pages.firstIndex(of: viewController) else { return nil }
        if currentPageIndex == 0 {
            return nil
        }
        let previousPageIndex = abs((currentPageIndex - 1) % pages.count)
        return pages[previousPageIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentPageIndex = pages.firstIndex(of: viewController) else { return nil }
        if currentPageIndex == pages.count - 1 {
            return nil
        }
        let nextPageIndex = abs((currentPageIndex + 1) % pages.count)
        return pages[nextPageIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let firstPendingController = pendingViewControllers.first else { return }
        guard let pendingPageIndex = pages.firstIndex(of: firstPendingController) else { return }
        pendingIndex = pendingPageIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentIndex = pendingIndex
            pageControl.currentPage = currentIndex
            delegate?.switchChannel(by: currentIndex)
        }
    }
}

// MARK: - Constants

extension PageControlCell {
    
    private enum Constants {
        static let defaultPadding: CGFloat = 18.0
    }
}
