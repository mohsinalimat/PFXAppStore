//
//  SearchHistoryCell.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/18.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit

class SearchHistoryCell: BaseTableViewCell {
    private weak var viewModel: SearchHistoryCellViewModel?
    
    func initialize() {
        self.textLabel?.text = ""
    }
    
    override func configure(viewModel: BaseCellViewModel) {
        super.configure(viewModel: viewModel)
        self.initialize()
        guard let viewModel = viewModel as? SearchHistoryCellViewModel else {
            return
        }
        
        self.imageView?.image = UIImage(systemName: "magnifyingglass")
        self.imageView?.tintColor = UIColor.gray
        self.textLabel?.text = viewModel.text
    }
}
