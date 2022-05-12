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
    private var uiFactory = UIFactory()
    
    private var defaultPadding: CGFloat = 18.0
    
    // MARK: - UI Elements
    
    private lazy var pageViewController: UIPageViewController = {
        let viewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        viewController.dataSource = self
        viewController.view.backgroundColor = .black
        return viewController
    }()
    
    lazy var newLabel = uiFactory.newLabel(text: "Hello", font: .systemFont(ofSize: 40))
    
    private lazy var orderedViewControllers: [UIViewController] = {
        [uiFactory.getViewController(color: .yellow),
         uiFactory.getViewController(color: .blue),
         uiFactory.getViewController(color: .green),
         uiFactory.getViewController(color: .orange)]
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(with channels: [Channel]) {
        textLabel?.text = channels.count.description
    }
    
    private func setupLayout() {
        setupViews()
        setupPageViewController()
        addConstraints()
    }
    
    private func setupViews() {
        contentView.backgroundColor = .cyan
        contentView.addSubview(pageViewController.view)
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
    
    private func addConstraints() {
        pageViewController.view.snp.makeConstraints {
            $0.top.equalTo(contentView).offset(defaultPadding)
            $0.leading.equalTo(contentView).offset(defaultPadding)
            $0.trailing.equalTo(contentView).inset(defaultPadding)
            $0.bottom.equalTo(contentView).inset(defaultPadding)
        }
    }
}

// MARK: - UIPageViewControllerDataSource

extension PageControlCell: UIPageViewControllerDataSource {
    
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
