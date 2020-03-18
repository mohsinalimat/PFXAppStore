//
//  SearchTableViewModel.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/18.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class SearchTableViewModel {
    struct Input {
        var stubObserver: AnyObserver<Bool>
        var historyObserver: AnyObserver<String>
        var requestSearchObserver: AnyObserver<String>
        var cancelSearchObserver: AnyObserver<Bool>
    }
    
    struct Output {
        var recentSections: Observable<[BaseSectionTableViewModel]>
        var searchDynamicSections: Observable<[BaseSectionTableViewModel]>
        var loading: Observable<Bool>
        var empty: Observable<Bool>
        var error: Observable<NSError>
    }
    
    private var disposeBag = DisposeBag()
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    var input: SearchTableViewModel.Input!
    var output: SearchTableViewModel.Output!
    private var recentSectionsSubject = BehaviorRelay<[BaseSectionTableViewModel]>(value: [BaseSectionTableViewModel()])
    private var searchDynamicSectionsSubject = BehaviorRelay<[BaseSectionTableViewModel]>(value: [BaseSectionTableViewModel()])
    private var cancelSearchSubject = PublishSubject<Bool>()
    private var emptySubject = BehaviorRelay<Bool>(value: true)
    private var loadingSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    private var errorSubject: PublishSubject<NSError> = PublishSubject()
    private var stubSubject: PublishSubject<Bool> = PublishSubject()
    private var historySubject: PublishSubject<String> = PublishSubject()
    private var requestSearchSubject: PublishSubject<String> = PublishSubject()
    
    private let searchBloc = SearchBloc()

    init() {
        // swiftlint:disable line_length
        self.output = SearchTableViewModel.Output(recentSections: self.recentSectionsSubject.asObservable(),
                                                  searchDynamicSections: self.searchDynamicSectionsSubject.asObservable(),
                                                  loading: self.loadingSubject.asObservable(),
                                                  empty: self.emptySubject.asObservable(),
                                                  error: self.errorSubject.asObservable())
        // swiftlint:enable line_length

        self.input = SearchTableViewModel.Input(stubObserver: self.stubSubject.asObserver(),
                                                historyObserver: self.historySubject.asObserver(),
                                                requestSearchObserver: self.requestSearchSubject.asObserver(),
                                                cancelSearchObserver: self.cancelSearchSubject.asObserver())
        
        self.searchBloc.stateRelay
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                if state is FetchingSearchState {
                    self.loadingSubject.onNext(true)
                    return
                }
                
                if let state = state as? FetchedSearchState {
                    let models = state.appStoreResponseModel.results
                    var items = [BaseCellViewModel]()
                    for model in models {
                        let viewModel = SearchAppStoreCellViewModel(reuseIdentifier: String(describing: SearchAppStoreCell.self), identifier: String(describing: SearchAppStoreCell.self) + String.random())
                        viewModel.text = model.artistName
                        items.append(viewModel)
                    }
                    
                    var sections = self.searchDynamicSectionsSubject.value
                    if var collectionViewModel = sections.first {
                        collectionViewModel.items.removeAll()
                        collectionViewModel.items.append(contentsOf: items)
                        sections.removeFirst()
                        sections.append(collectionViewModel)
                        self.searchDynamicSectionsSubject.accept(sections)
                    }

                    return
                }
                
                if state is IdleSearchState {
                    self.loadingSubject.onNext(false)
                    return
                }
                
                if let state = state as? ErrorSearchState {
                    self.errorSubject.onNext(state.error)
                    return
                }
            })
            .disposed(by: self.disposeBag)
        
        self.requestSearchSubject
            .subscribe(onNext: { text in
                if let error = CoreDataHelper.shared.updateHistory(model: HistoryModel(text: text, date: Date())) {
                    self.errorSubject.onNext(error)
                    return
                }
                
                let parameterDict = ["term" : text,
                                     "media" : "software",
                                     "offset" : "0",
                                     "limit" : String(ConstNumbers.maxLoadLimit)]

                self.searchBloc.dispatch(event: FetchingSearchEvent(parameterDict: parameterDict))
            })
            .disposed(by: self.disposeBag)
        
        self.cancelSearchSubject
            .subscribe(onNext: { [weak self] isCancel in
                guard let self = self else { return }
                self.entityHistories()
            })
            .disposed(by: self.disposeBag)

        self.historySubject
            .subscribe(onNext: { text in
                CoreDataHelper.shared.entityHistories(text: text)
                    .subscribe(onNext: { [weak self] models in
                        guard let self = self else { return }
                        
                        var items = [BaseCellViewModel]()
                        for model in models {
                            let viewModel = SearchHistoryCellViewModel(reuseIdentifier: String(describing: SearchHistoryCell.self), identifier: String(describing: SearchHistoryCell.self) + String.random())
                            viewModel.text = model.text
                            viewModel.date = model.date
                            items.append(viewModel)
                        }
                        
                        var sections = self.searchDynamicSectionsSubject.value
                        if var collectionViewModel = sections.first {
                            collectionViewModel.items.removeAll()
                            collectionViewModel.items.append(contentsOf: items)
                            sections.removeFirst()
                            sections.append(collectionViewModel)
                            self.searchDynamicSectionsSubject.accept(sections)
                        }
                    }, onError: { error in
                        self.errorSubject.onNext(NSError(domain: "\(#function) : \(#line)", code: PBError.coredata_select_entity.rawValue, userInfo: nil))
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: self.disposeBag)

        self.stubSubject
            .subscribe(onNext: { _ in
                CoreDataHelper.shared.initializeStub { error in
                    if error != nil {
                        return
                    }
                    
                    self.entityHistories()
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    func entityHistories() {
        CoreDataHelper.shared.entityHistories(isAscending: false, limit: 10)
            .subscribe(onNext: { [weak self] models in
                guard let self = self else { return }
                
                var items = [BaseCellViewModel]()
                for model in models {
                    let viewModel = SearchHistoryCellViewModel(reuseIdentifier: String(describing: SearchHistoryCell.self), identifier: String(describing: SearchHistoryCell.self) + String.random())
                    viewModel.text = model.text
                    viewModel.date = model.date
                    items.append(viewModel)
                }
                
                var sections = self.recentSectionsSubject.value
                if var collectionViewModel = sections.first {
                    collectionViewModel.items.removeAll()
                    collectionViewModel.items.append(contentsOf: items)
                    sections.removeFirst()
                    sections.append(collectionViewModel)
                    self.recentSectionsSubject.accept(sections)
                }
            }, onError: { error in
                self.errorSubject.onNext(NSError(domain: "\(#function) : \(#line)", code: PBError.coredata_select_entity.rawValue, userInfo: nil))
            })
            .disposed(by: self.disposeBag)
    }
}
