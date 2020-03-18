//
//  BaseCell.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/16.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol Configurable where Self: UITableViewCell {
    func configure(viewModel: BaseCellViewModel)
}

typealias ConfigurableCell = UITableViewCell & Configurable

class BaseCell: ConfigurableCell {

    var disposeBag = DisposeBag()

    func configure(viewModel: BaseCellViewModel) {}

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
