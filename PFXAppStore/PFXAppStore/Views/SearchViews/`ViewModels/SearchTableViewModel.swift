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
        var historyObserver: AnyObserver<String>
        var selectedHistoryObserver: AnyObserver<String>
        var requestSearchObserver: AnyObserver<String>
        var nextSearchObserver: AnyObserver<String>
        var cancelSearchObserver: AnyObserver<Bool>
        var beginScrollObserver: AnyObserver<Bool>
        var refreshHistoryObserver: AnyObserver<Bool>
    }
    
    struct Output {
        var recentSections: Observable<[BaseSectionTableViewModel]>
        var searchDynamicSections: Observable<[BaseSectionTableViewModel]>
        var loading: Observable<Bool>
        var empty: Observable<String>
        var error: Observable<NSError>
        var selectedHistory: Observable<String>
        var beginScroll: Observable<Bool>
    }
    
    private var disposeBag = DisposeBag()
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    var input: SearchTableViewModel.Input!
    var output: SearchTableViewModel.Output!
    private var refreshHistorySubject = PublishSubject<Bool>()
    private var recentSectionsSubject = BehaviorRelay<[BaseSectionTableViewModel]>(value: [BaseSectionTableViewModel()])
    private var searchDynamicSectionsSubject = BehaviorRelay<[BaseSectionTableViewModel]>(value: [BaseSectionTableViewModel()])
    private var cancelSearchSubject = PublishSubject<Bool>()
    private var emptySubject = PublishSubject<String>()
    private var loadingSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    private var errorSubject = PublishSubject<NSError>()
    private var stubSubject = PublishSubject<Bool>()
    private var historySubject = PublishSubject<String>()
    private var requestSearchSubject = PublishSubject<String>()
    private var nextSearchSubject = PublishSubject<String>()
    private var selectedHistorySubject = PublishSubject<String>()
    private var beginScrollSubject = PublishSubject<Bool>()
    private var parameterSubject = BehaviorRelay<Dictionary<String, String>>(value: [
        "media" : "software",
        "country" : "kr",
        "limit" : String(ConstNumbers.maxLoadLimit)
    ])
    
    private var validDict = [String:String]()

    private var hasNext = false
    private let searchBloc = SearchBloc()
    private let historyBloc = HistoryBloc()

    init() {
        // swiftlint:disable line_length
        self.input = SearchTableViewModel.Input(historyObserver: self.historySubject.asObserver(),
                                                selectedHistoryObserver: self.selectedHistorySubject.asObserver(),
                                                requestSearchObserver: self.requestSearchSubject.asObserver(),
                                                nextSearchObserver: self.nextSearchSubject.asObserver(),
                                                cancelSearchObserver: self.cancelSearchSubject.asObserver(),
                                                beginScrollObserver: self.beginScrollSubject.asObserver(),
                                                refreshHistoryObserver: self.refreshHistorySubject.asObserver())
        self.output = SearchTableViewModel.Output(recentSections: self.recentSectionsSubject.asObservable(),
                                                  searchDynamicSections: self.searchDynamicSectionsSubject.asObservable(),
                                                  loading: self.loadingSubject.asObservable(),
                                                  empty: self.emptySubject.asObservable(),
                                                  error: self.errorSubject.asObservable(),
                                                  selectedHistory: self.selectedHistorySubject.asObservable(),
                                                  beginScroll: self.beginScrollSubject.asObservable())
        // swiftlint:enable line_length

        self.bindBlocs()
        self.bindInputs()
    }
    
    func bindBlocs() {
        self.historyBloc.stateRelay
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                if let _ = state as? IdleHistoryState {
                    return
                }

                if let _ = state as? FetchingHistoryState {
                    return
                }

                if let state = state as? ErrorHistoryState {
                    self.errorSubject.onNext(state.error)
                    return
                }

                if let state = state as? RecentHistoryState {
                    var items = [BaseCellViewModel]()
                    for model in state.datas {
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
                    
                    return
                }
                
                if let state = state as? AllHistoryState {
                    var items = [BaseCellViewModel]()
                    for model in state.datas {
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
                    
                    return
                }
                
                if let _ = state as? CompletedHistoryState {
                    return
                }
            })
            .disposed(by: self.disposeBag)
        
        self.searchBloc.stateRelay
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                if state is FetchingSearchState {
                    self.loadingSubject.onNext(true)
                    return
                }
                
                if let state = state as? EmptySearchState {
                    var sections = self.searchDynamicSectionsSubject.value
                    if var collectionViewModel = sections.first {
                        collectionViewModel.items.removeAll()
                        sections.removeFirst()
                        sections.append(collectionViewModel)
                        self.searchDynamicSectionsSubject.accept(sections)
                    }
                    
                    self.emptySubject.onNext("'\(state.text)'")
                    return
                }
                
                if let state = state as? FetchedSearchState {
                    print("fetchedSearch count \(state.appStoreResponseModel.resultCount)")
                    if state.appStoreResponseModel.resultCount < ConstNumbers.maxLoadLimit {
                        self.hasNext = false
                    }
                    
                    self.emptySubject.onNext("")
                    let models = state.appStoreResponseModel.results
                    var items = [BaseCellViewModel]()
                    for model in models {
                        let viewModel = SearchAppStoreCellViewModel(reuseIdentifier: String(describing: SearchAppStoreCell.self), identifier: String(describing: SearchAppStoreCell.self) + String.random())
                        viewModel.trackName = model.trackName
                        viewModel.sellerName = model.sellerName
                        viewModel.artworkUrl100 = model.artworkUrl100
                        viewModel.averageUserRating = String(model.averageUserRating)
                        viewModel.appStoreModel = model
                        
                        let trackId = String(model.trackId)
                        if self.validDict[trackId] != nil {
                            print("Received duplicate trackId. exclude app info...\nduplicate trackid \(model.trackName)")
                            continue
                        }
                        else {
                            self.validDict[trackId] = trackId
                        }

                        var size = ConstNumbers.portraitPhoneImageCellSize
                        if viewModel.appStoreModel?.isPortraitPhoneScreenshot() == false {
                            size = ConstNumbers.landscapePhoneImageCellSize
                        }
                        
                        viewModel.screenshotModel = ScreenshotModel(targetPaths: model.screenshotUrls, size: size)
                        items.append(viewModel)
                    }
                    
                    var sections = self.searchDynamicSectionsSubject.value
                    if var collectionViewModel = sections.first {
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
    }
    
    func bindInputs() {
        self.parameterSubject
            .skip(1)
            .subscribe(onNext: { [weak self] parameterDict in
                guard let self = self else { return }
                self.searchBloc.dispatch(event: FetchingSearchEvent(parameterDict: parameterDict))
            })
            .disposed(by: self.disposeBag)
        
        self.requestSearchSubject
            .do(onNext: { text in
                self.historyBloc.dispatch(event: UpdateHistoryEvent(historyModel: HistoryModel(text: text, date: Date())))
                self.refreshRecentHistory()
            })
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.validDict.removeAll()
                var oldValue = self.parameterSubject.value
                oldValue["term"] = text
                oldValue["offset"] = "0"
                self.hasNext = true
                self.parameterSubject.accept(oldValue)
                var sections = self.searchDynamicSectionsSubject.value
                if var collectionViewModel = sections.first {
                    collectionViewModel.items.removeAll()
                    sections.removeFirst()
                    sections.append(collectionViewModel)
                    self.searchDynamicSectionsSubject.accept(sections)
                }

            })
            .disposed(by: self.disposeBag)
        
        self.nextSearchSubject
            .filter({ _ in self.hasNext && self.searchBloc.currentState is IdleSearchState })
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                var oldValue = self.parameterSubject.value
                guard let value = oldValue["offset"], let offset = Int(value) else {
                    return
                }
                
                oldValue["offset"] = String(offset + ConstNumbers.maxLoadLimit)
                self.parameterSubject.accept(oldValue)
            })
            .disposed(by: self.disposeBag)
        
        self.cancelSearchSubject
            .subscribe(onNext: { [weak self] isCancel in
                guard let self = self else { return }
                self.emptySubject.onNext("")
            })
            .disposed(by: self.disposeBag)

        self.historySubject
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.emptySubject.onNext("")
                print("request history...")

                self.historyBloc.dispatch(event: AllHistoryEvent(text: text))
            })
            .disposed(by: self.disposeBag)
        
        self.refreshHistorySubject
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                self.refreshRecentHistory()
            })
            .disposed(by: self.disposeBag)
    }
    
    func refreshRecentHistory() {
        self.historyBloc.dispatch(event: RecentHistoryEvent(isAscending: false, limit: ConstNumbers.maxRecentHistoryCount))
    }
}
