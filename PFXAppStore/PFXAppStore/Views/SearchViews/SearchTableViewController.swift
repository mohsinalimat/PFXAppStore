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
    private var searchEmptyView = SearchEmptyView()
    private var ignore = false
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
            guard let viewModel = try? (dataSource.model(at: indexPath) as? BaseCellViewModel),
                let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reuseIdentifier, for: indexPath) as? SearchHistoryCell else {
                    return UITableViewCell()
            }
            
            cell.configure(viewModel: viewModel)
            return cell
        }, titleForHeaderInSection: { (dataSource, index) in
            let viewModel = dataSource.sectionModels[index]
            return viewModel.header
        })

        self.viewModel.output.recentSections
            .bind(to: self.tableView.rx.items(dataSource: self.rxDataSource!))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                do {
                    guard let viewModel = try (self.rxDataSource!.model(at: indexPath) as? SearchHistoryCellViewModel) else { return }
                    guard let text = viewModel.text else { return }
                    self.focusSearchBar(text: text)
                }
                catch {
                    
                }
            })
            .disposed(by: self.disposeBag)
        
        self.tableView.rx
            .setDelegate(self)
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

        guard let emptyView = Bundle.main.loadNibNamed("SearchEmptyView", owner: self, options: nil)?.first as? SearchEmptyView else { return }
        searchController.view.addSubview(emptyView)
        self.searchEmptyView = emptyView

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
            .skip(1)
            .distinctUntilChanged()
            .filter({ $0.count > 0 })
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                print("searchController.searchBar.rx.text text \(text)")
                if self.ignore == true {
                    self.ignore = false
                    return
                }
                self.viewModel.input.historyObserver.onNext(text)
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindInputs() {
        self.viewModel.input.refreshHistoryObserver.onNext(true)
    }
    
    func bindOutputs() {
        self.viewModel.output.empty
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { text in
                self.searchEmptyView.searchTextLabel.text = ""
                self.searchEmptyView.isHidden = true
                if text.count > 0 {
                    self.searchEmptyView.searchTextLabel.text = text
                    self.searchEmptyView.isHidden = false
                    self.searchEmptyView.frame = self.view.bounds
                    return
                }
            })
            .disposed(by: self.disposeBag)
        
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
        
        self.viewModel.output.selectedHistory
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] text in
                guard let self = self else { return }
                self.focusSearchBar(text: text)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.beginScroll
        .asDriver(onErrorJustReturn: true)
            .drive(onNext: { [weak self] isScroll in
                guard let self = self, let searchController = self.navigationItem.searchController else { return }
                // TODO : i want hide keyboard!!!!!
                // 버그로 인하여 플래그 추가.
                self.ignore = true
                searchController.searchBar.resignFirstResponder()
            })
            .disposed(by: self.disposeBag)
    }
    
    func focusSearchBar(text: String) {
        print("\(#function) text \(text)")
        guard let searchController = self.navigationItem.searchController else { return }
        searchController.searchBar.text = text
        searchController.searchBar.searchTextField.becomeFirstResponder()
        self.viewModel.input.requestSearchObserver.onNext(text)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let destination = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: String(describing: SearchHeaderSectionViewController.self))
        return destination.view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    private let presentingIndicatorTypes = {
        return NVActivityIndicatorType.allCases.filter { $0 != .blank }
    }()
}
