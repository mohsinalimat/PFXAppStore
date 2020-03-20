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
        var artworkImage: Observable<Data>
        var trackName: Observable<String>
        var sellerName: Observable<String>
        var averageUserRating: Observable<String>
        var genres: Observable<String>
        var trackContentRating: Observable<String>
        var description: Observable<String>
    }

    //    @IBOutlet weak var downloadButton: UIButton!
    //    @IBOutlet weak var shareButton: UIButton!
    //    @IBOutlet weak var moreButton: UIButton!
    //    @IBOutlet weak var Label: UILabel!
        // screenshotUrls

    private var disposeBag = DisposeBag()
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    var appStoreModel: AppStoreModel
    var input: AppInfoViewModel.Input!
    var output: AppInfoViewModel.Output!
    private var refreshSubject = PublishSubject<Bool>()
    private var artworkImageSubject = PublishSubject<Data>()
    private var trackNameSubject = PublishSubject<String>()
    private var sellerNameSubject = PublishSubject<String>()
    private var averageUserRatingSubject = PublishSubject<String>()
    private var genresSubject = PublishSubject<String>()
    private var trackContentRatingSubject = PublishSubject<String>()
    private var descriptionSubject = PublishSubject<String>()
    
    var imageBloc = ImageBloc()

    init(appStoreModel: AppStoreModel) {
        self.appStoreModel = appStoreModel
        // swiftlint:disable line_length
        self.input = AppInfoViewModel.Input(refreshObserver: self.refreshSubject.asObserver())
        self.output = AppInfoViewModel.Output(artworkImage: self.artworkImageSubject.asObservable(), trackName: self.trackNameSubject.asObservable(), sellerName: self.sellerNameSubject.asObservable(), averageUserRating: self.averageUserRatingSubject.asObservable(), genres: self.genresSubject.asObservable(), trackContentRating: self.trackContentRatingSubject.asObservable(), description: self.descriptionSubject.asObservable())
        // swiftlint:enable line_length

        self.bindBlocs()
        self.bindInputs()
    }
    
    func bindBlocs() {
        self.imageBloc.stateRelay
            .subscribe(onNext: { [weak self] state in
                
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindInputs() {
        self.refreshSubject
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                
            })
            .disposed(by: self.disposeBag)
    }
}
