//
//  UIFactory.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import UIKit
import SDWebImage

final class UIFactory {
    
    func newPageControl() -> UIPageControl {
        let pageControl = UIPageControl()
        return pageControl
    }
    
    func newCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PlaylistItemCell.self, forCellWithReuseIdentifier: PlaylistItemCell.reuseID)
        collectionView.backgroundColor = .clear
        return collectionView
    }
    
    func newViewController(color: UIColor = .white) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = color
        return vc
    }
    
    func newLabel(text: String = "", font: UIFont, textColor: UIColor = .black, bgColor: UIColor = .clear) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.backgroundColor = bgColor
        return label
    }
    
    func newView(color: UIColor = .clear) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        return view
    }
    
    func newShadowView(alpha: CGFloat) -> UIView {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(alpha)
        return view
    }
    
    func newImageView(image: UIImage? = nil, cornerRadius: CGFloat = 0.0) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = cornerRadius
        imageView.image = image
        return imageView
    }
    
    func newPage(with channel: Channel) -> UIViewController {
        let vc = UIViewController()
        
        // set image
        let channelIconImageView = newImageView()
        vc.view.addSubview(channelIconImageView)
        let urlString = channel.brandingSettings.image.bannerExternalUrl
        channelIconImageView.sd_setImage(with: URL(string: urlString))
        channelIconImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        // set title label
        let channelTitleLabel = newLabel(
            text: channel.brandingSettings.channel.title,
            font: .SFPro.Text.Semibold(size: 16).font,
            textColor: Asset.Colors.channelTitleTextColor.color
        )
        vc.view.addSubview(channelTitleLabel)
        channelTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().inset(30)
            $0.width.equalTo(vc.view.frame.width / 2)
        }
        // set subscriptions counter label
        let viewsCount = channel.statistics.subscriberCount.splitIntoThounsandParts ?? "0"
        let channelSubscribersCounterLabel = newLabel(
            text: viewsCount + " подписчика",
            font: .SFPro.Text.Regular(size: 10).font,
            textColor: .gray
        )
        vc.view.addSubview(channelSubscribersCounterLabel)
        channelSubscribersCounterLabel.snp.makeConstraints {
            $0.leading.equalTo(channelTitleLabel)
            $0.top.equalTo(channelTitleLabel.snp.bottom).offset(4)
        }
        return vc
    }
    
    func newButton(title: String = "", image: UIImage? = nil) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setImage(image, for: .normal)
        return button
    }
    
    func newStackView(axis: NSLayoutConstraint.Axis = .vertical, alignment: UIStackView.Alignment = .center, distribution: UIStackView.Distribution = .fill, spacing: CGFloat = 0.0) -> UIStackView {
        let stack = UIStackView()
        stack.axis = axis
        stack.spacing = spacing
        stack.alignment = alignment
        stack.distribution = distribution
        return stack
    }
    
    func newSliderView() -> UISlider {
        let slider = UISlider()
        slider.maximumTrackTintColor = Asset.Colors.playerTransparentWhite35.color
        return slider
    }
}
