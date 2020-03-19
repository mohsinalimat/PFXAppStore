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
            
            if let viewModel = viewModel as? SearchAppStoreCellViewModel {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reuseIdentifier, for: indexPath) as? SearchAppStoreCell else {
                    return UITableViewCell(style: .default, reuseIdentifier: String.random())
                }

                guard let destination = UIStoryboard(name: "Image", bundle: nil).instantiateViewController(withIdentifier: String(describing: ImageCollectionViewController.self)) as? ImageCollectionViewController else {
                    return UITableViewCell(style: .default, reuseIdentifier: String.random())
                }

                self .addChild(destination)
                cell.imageCollectionViewController = destination
                
                if let screenshotUrls = viewModel.screenshotUrls {
                    cell.imageCollectionViewController?.viewModel.input.screenshotUrlObserver.onNext(screenshotUrls)
                }
                
                cell.bgndView.addSubview(destination.view)
                destination.didMove(toParent: self)

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
        
        self.tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                guard let viewModel = try? (self.rxDataSource!.model(at: indexPath) as? BaseCellViewModel) else {
                    return
                }
                
                if viewModel is SearchAppStoreCellViewModel {
                    return
                }
                
                if let viewModel = viewModel as? SearchHistoryCellViewModel {
                    guard let text = viewModel.text else { return }
                    self.viewModel.input.selectedHistoryObserver.onNext(text)
                }
            })
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.didEndDisplayingCell
            .subscribe(onNext: { cell, indexPath in
                if let cell = cell as? SearchAppStoreCell {
                    guard let controller = cell.imageCollectionViewController else { return }
                    controller.removeFromParent()
                    
                    return
                }
            })
            .disposed(by: self.disposeBag)

        self.tableView.rx.setDelegate(self).disposed(by: self.disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let viewModel = try? (self.rxDataSource!.model(at: indexPath) as? BaseCellViewModel) else {
            return 44
        }
        
        if viewModel is SearchAppStoreCellViewModel {
            return 400
        }
        
        return 44
    }
}
