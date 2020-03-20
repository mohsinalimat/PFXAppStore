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
    private var errorSubject: PublishSubject<NSError> = PublishSubject()
    private var stubSubject: PublishSubject<Bool> = PublishSubject()
    private var historySubject: PublishSubject<String> = PublishSubject()
    private var requestSearchSubject: PublishSubject<String> = PublishSubject()
    private var selectedHistorySubject = PublishSubject<String>()
    private var beginScrollSubject = PublishSubject<Bool>()

    private let searchBloc = SearchBloc()

    init() {
        // swiftlint:disable line_length
        self.input = SearchTableViewModel.Input(historyObserver: self.historySubject.asObserver(),
                                                selectedHistoryObserver: self.selectedHistorySubject.asObserver(),
                                                requestSearchObserver: self.requestSearchSubject.asObserver(),
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

                        var imageWidth: Float = 150
                        var imageHeight: Float = 300
                        for url in model.screenshotUrls {
                            var fileName = (url as NSString).lastPathComponent
                            fileName = (fileName as NSString).deletingPathExtension
                            fileName = fileName.replacingOccurrences(of: "bb", with: "")
                            let tokens = fileName.components(separatedBy: "x")
                            guard let first = tokens.first, let last = tokens.last else {
                                continue
                            }
                            
                            guard let width = Int(first), let height = Int(last) else {
                                continue
                            }
                            
                            if width > height {
                                imageWidth = 300
                                imageHeight = 180
                            }
                        }
                        
                        viewModel.screenshotModel = ScreenshotModel(targetPaths: model.screenshotUrls, width: imageWidth, height: imageHeight)
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
    }
    
    func bindInputs() {
        self.requestSearchSubject
            .do(onNext: { text in
                if let error = CoreDataHelper.shared.updateHistory(model: HistoryModel(text: text, date: Date())) {
                    print(error)
    //                        self.errorSubject.onNext(error)
    //                        return
                }
            })
            .subscribe(onNext: { text in
                let parameterDict = ["term" : text,
                                     "media" : "software",
                                     "offset" : "0",
                                     "country" : "kr",
                                     "limit" : String(ConstNumbers.maxLoadLimit)]

                self.searchBloc.dispatch(event: FetchingSearchEvent(parameterDict: parameterDict))
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
                
                CoreDataHelper.shared.entityHistories(text: text)
                    .distinctUntilChanged()
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
        
        self.refreshHistorySubject
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                self.refreshRecentHistory()
            })
            .disposed(by: self.disposeBag)
    }
    
    func refreshRecentHistory() {
        CoreDataHelper.shared.entityHistories(isAscending: false, limit: ConstNumbers.maxRecentHistoryCount)
            .subscribe(onNext: { [weak self] models in
                guard let self = self else { return }
                var items = [BaseCellViewModel]()
                
                for i in 0..<models.count {
                    if i >= ConstNumbers.maxRecentHistoryCount {
                        break
                    }
                    
                    let model = models[i]
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
