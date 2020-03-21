//
//  AppInfoViewModel.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/20.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift

class AppInfoViewModel {
    struct Input {
        var refreshObserver: AnyObserver<Bool>
    }
    
    struct Output {
        var loading: Observable<Bool>
        var error: Observable<NSError>
        var artworkImage: Observable<Data>
        var trackName: Observable<String>
        var sellerName: Observable<String>
        var averageUserRating: Observable<String>
        var genres: Observable<String>
        var trackContentRating: Observable<String>
        var description: Observable<String>
    }

    private var disposeBag = DisposeBag()
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    var appStoreModel: AppStoreModel
    var heroId: String
    var input: AppInfoViewModel.Input!
    var output: AppInfoViewModel.Output!
    private var refreshSubject = PublishSubject<Bool>()
    private var loadingSubject = PublishSubject<Bool>()
    private var errorSubject = PublishSubject<NSError>()
    private var artworkImageSubject = PublishSubject<Data>()
    private var trackNameSubject = PublishSubject<String>()
    private var sellerNameSubject = PublishSubject<String>()
    private var averageUserRatingSubject = PublishSubject<String>()
    private var genresSubject = PublishSubject<String>()
    private var trackContentRatingSubject = PublishSubject<String>()
    private var descriptionSubject = PublishSubject<String>()
    
    var imageBloc = ImageBloc()

    init(appStoreModel: AppStoreModel, heroId: String) {
        self.appStoreModel = appStoreModel
        self.heroId = heroId
        // swiftlint:disable line_length
        self.input = AppInfoViewModel.Input(refreshObserver: self.refreshSubject.asObserver())
        self.output = AppInfoViewModel.Output(loading: self.loadingSubject.asObserver(),
                                              error: self.errorSubject.asObserver(),
                                              artworkImage: self.artworkImageSubject.asObservable(),
                                              trackName: self.trackNameSubject.asObservable(),
                                              sellerName: self.sellerNameSubject.asObservable(),
                                              averageUserRating: self.averageUserRatingSubject.asObservable(),
                                              genres: self.genresSubject.asObservable(),
                                              trackContentRating: self.trackContentRatingSubject.asObservable(),
                                              description: self.descriptionSubject.asObservable())
        // swiftlint:enable line_length

        self.bindBlocs()
        self.bindInputs()
    }
    
    func bindBlocs() {
        self.imageBloc.stateRelay
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                if let _ = state as? IdleImageState {
                    self.loadingSubject.onNext(false)
                    return
                }
                
                if let _ = state as? DownloadingImageState {
                    self.loadingSubject.onNext(true)
                    return
                }
                
                if let state = state as? DownloadImageState {
                    self.artworkImageSubject.onNext(state.data)
                    return
                }
                
                if let state = state as? ErrorImageState {
                    self.errorSubject.onNext(state.error)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindInputs() {
        self.refreshSubject
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.trackNameSubject.onNext(self.appStoreModel.trackName)
                self.sellerNameSubject.onNext(self.appStoreModel.sellerName)
                self.averageUserRatingSubject.onNext(String(self.appStoreModel.averageUserRating))
                if let genre = self.appStoreModel.genres.first {
                    self.genresSubject.onNext(genre)
                }
                
                self.trackContentRatingSubject.onNext(self.appStoreModel.trackContentRating)
                self.descriptionSubject.onNext(self.appStoreModel.description)
                self.imageBloc.dispatch(event: DownloadImageEvent(targetPath: self.appStoreModel.artworkUrl100))
                self.imageBloc.dispatch(event: DownloadImageEvent(targetPath: self.appStoreModel.artworkUrl512))
            })
            .disposed(by: self.disposeBag)
    }
}
