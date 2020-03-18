//
//  SearchTableViewController.swift
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
import SwiftMessages
import NVActivityIndicatorView

class SearchTableViewController: UITableViewController, NVActivityIndicatorViewable {
    @IBOutlet weak var stubButton: UIBarButtonItem!
    
    var viewModel = SearchTableViewModel()
    private var disposeBag = DisposeBag()
    private var rxDataSource: RxTableViewSectionedAnimatedDataSource<BaseSectionTableViewModel>?

    deinit {
        self.disposeBag = DisposeBag()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindTableView()
        self.bindSearchBar()
        self.bindInputs()
        self.bindOutputs()
    }
    
    func bindTableView() {
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.rxDataSource = RxTableViewSectionedAnimatedDataSource<BaseSectionTableViewModel>(configureCell: { dataSource, tableView, indexPath, cellViewModel in
            guard let viewModel = try? (dataSource.model(at: indexPath) as! BaseCellViewModel),
                let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reuseIdentifier, for: indexPath) as? SearchHistoryCell else {
                    return UITableViewCell()
            }
            
            cell.configure(viewModel: viewModel)
            return cell
        })

        self.viewModel.output.recentSections.asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(dataSource: self.rxDataSource!))
            .disposed(by: self.disposeBag)
    }
    
    func bindSearchBar() {
        guard let historyTableViewController = UIStoryboard(name: "Search", bundle: nil)
            .instantiateViewController(withIdentifier: String(describing: SearchDynamicTableViewController.self)) as? SearchDynamicTableViewController else {
            return
        }
        
        let searchController = UISearchController(searchResultsController: historyTableViewController)
        historyTableViewController.viewModel = self.viewModel
        self.navigationItem.searchController = searchController

        searchController.searchBar.rx.searchButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let self = self, let text = searchController.searchBar.text else { return }
                self.viewModel.input.requestSearchObserver.onNext(text)
            })
            .disposed(by: self.disposeBag)
        
        searchController.searchBar.rx.cancelButtonClicked
            .subscribe(onNext: { [weak self] in
                self?.viewModel.input.cancelSearchObserver.onNext(true)
            })
            .disposed(by: self.disposeBag)

        searchController.searchBar.rx.text
            .orEmpty
            .distinctUntilChanged()
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.viewModel.input.historyObserver.onNext(text)
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindInputs() {
        self.stubButton.rx.tap
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.input.stubObserver.onNext(true)
                self.stubButton.isEnabled = false
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindOutputs() {
        self.viewModel.output.error
            .asDriver(onErrorJustReturn: NSError())
            .drive(onNext: { error in
                var config = SwiftMessages.Config()
                config.presentationStyle = .top
                config.presentationContext = .window(windowLevel: .statusBar)
                config.duration = .automatic
                config.dimMode = .gray(interactive: true)
                config.interactiveHide = false
                config.preferredStatusBarStyle = .lightContent

                let view = MessageView.viewFromNib(layout: .cardView)
                view.configureTheme(.error)
                view.configureDropShadow()
                let iconText = "😡"
                view.configureContent(title: "Error", body: PBError.messageKey(value: error.code), iconText: iconText)
                view.button?.isHidden = true
                view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
                (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
                SwiftMessages.show(config: config, view: view)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.loading
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading == true {
                    let size = CGSize(width: 30, height: 30)
                    let selectedIndicatorIndex = 15
                    let indicatorType = self.presentingIndicatorTypes[selectedIndicatorIndex]
                    self.startAnimating(size, message: "Loading...", type: indicatorType, fadeInAnimation: nil)
                    return
                }
                
                self.stopAnimating()
            })
            .disposed(by: self.disposeBag)
    }
    
    private let presentingIndicatorTypes = {
        return NVActivityIndicatorType.allCases.filter { $0 != .blank }
    }()
}
