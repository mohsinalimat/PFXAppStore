//
//  SearchDynamicTableViewController.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/18.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SearchDynamicTableViewController: UITableViewController {
    var viewModel = SearchTableViewModel()
    private var disposeBag = DisposeBag()
    private var rxDataSource: RxTableViewSectionedAnimatedDataSource<BaseSectionTableViewModel>?
    weak var searchBar: UISearchBar?

    deinit {
        self.disposeBag = DisposeBag()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindTableView()
    }
    
    func bindTableView() {
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.rxDataSource = RxTableViewSectionedAnimatedDataSource<BaseSectionTableViewModel>(configureCell: { dataSource, tableView, indexPath, cellViewModel in
            guard let viewModel = try? (dataSource.model(at: indexPath) as? BaseCellViewModel) else {
                return UITableViewCell(style: .default, reuseIdentifier: String.random())
            }
            
            if viewModel is SearchAppStoreCellViewModel {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reuseIdentifier, for: indexPath) as? SearchAppStoreCell else {
                    return UITableViewCell(style: .default, reuseIdentifier: String.random())
                }

                cell.configure(viewModel: viewModel)
                return cell
            }
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reuseIdentifier, for: indexPath) as? SearchHistoryCell else {
                return UITableViewCell()
            }
            
            cell.configure(viewModel: viewModel)
            return cell
        })

        self.viewModel.output.searchDynamicSections
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(dataSource: self.rxDataSource!))
            .disposed(by: self.disposeBag)
    }
}
