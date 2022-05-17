//
//  UIFactory.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 11.05.2022.
//

import UIKit

final class UIFactory {
    
    func newPageControl() -> UIPageControl {
        let pageControl = UIPageControl()
        return pageControl
    }
    
    func newCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: 1, height: 1)
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
    
    func newLabel(text: String, font: UIFont, textColor: UIColor = .black, bgColor: UIColor = .clear) -> UILabel {
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
    
    func newImageView(cornerRadius: CGFloat = 0.0) -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = cornerRadius
        return imageView
    }
}
