//
//  PageControlCell.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 12.05.2022.
//

import SnapKit
import SDWebImage

class PageControlCell: UITableViewCell {
    
    static let reuseID = "PageControlCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(with channels: [Channel]) {
        print("---------> \n", channels)
    }
    
    private func setup() {
        setupLayout()
    }
    
    private func setupLayout() {
        
    }
}
