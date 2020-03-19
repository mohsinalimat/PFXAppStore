//
//  SearchHistoryCell.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/18.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit

class SearchHistoryCell: BaseCell {
    private weak var viewModel: SearchHistoryCellViewModel?
    
    func initialize() {
        self.textLabel?.text = ""
    }
    
    override func configure(viewModel: BaseCellViewModel) {
        print(String(describing: self))
        self.initialize()
        guard let viewModel = viewModel as? SearchHistoryCellViewModel else {
            return
        }
        
        self.textLabel?.text = viewModel.text
    }
}
