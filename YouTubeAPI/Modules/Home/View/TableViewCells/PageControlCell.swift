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
    
    static let reuseID = "PageControlCell"
    
    private var currentIndex: Int?
    private var pendingIndex: Int?
    
    private var timerCounter = BehaviorRelay(value: 0)
    private let bag = DisposeBag()
    
    private var defaultPadding: CGFloat {
        return Constants.defaultPadding
    }
    
    private let uiFactory = UIFactory()
    
    private var channels: [Channel] = []
    
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
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(with channels: [Channel], bind timerCounter: BehaviorRelay<Int>) {
        self.channels = channels
        if pages.isEmpty {
            setupPageViewController(with: channels)
            setupPageControl()
            bind(timerCounter)
        }
    }
    
    private func bind(_ counter: BehaviorRelay<Int>) {
        counter
            .bind(to: timerCounter)
            .disposed(by: bag)
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
        currentIndex = 0
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
    
    private func moveCarousel() {
        if currentIndex == pages.count - 1 {
            currentIndex = 0
        } else {
            currentIndex? += 1
        }
        let nextPage = pages[currentIndex ?? 0]
        
        pageViewController.setViewControllers([nextPage], direction: .forward, animated: true) { completed in
            if completed {
                self.delegate?.switchChannel(by: self.currentIndex ?? 0)
                self.pageControl.currentPage = self.currentIndex ?? 0
            }
        }
    }
    
    private func setupObservers() {
        timerCounter
            .subscribe(onNext: { time in
                if time > 0, time % 5 == 0 {
                    self.moveCarousel()
                }
            })
            .disposed(by: bag)
    }
    
    @objc private func handleTap() {
        guard let delegate = delegate else { return }
        guard let currentIndex = currentIndex else { return }
        let channel = channels[currentIndex]
        delegate.channelDidSelect(channel)
    }
}

// MARK: - UIPageViewControllerDataSource

extension PageControlCell: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        if currentIndex == 0 {
            return nil
        }
        let previousIndex = abs((currentIndex - 1) % pages.count)
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else { return nil }
        if currentIndex == pages.count - 1 {
            return nil
        }
        let nextIndex = abs((currentIndex + 1) % pages.count)
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingIndex = pages.firstIndex(of: pendingViewControllers.first!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentIndex = pendingIndex
            if let index = currentIndex {
                pageControl.currentPage = index
                delegate?.switchChannel(by: index)
            }
        }
    }
}
