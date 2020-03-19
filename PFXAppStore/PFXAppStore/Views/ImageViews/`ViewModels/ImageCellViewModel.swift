//
//  ImageCellViewModel.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/19.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class ImageCellViewModel: BaseCellViewModel {
    struct Input {
        var requestDownloadObserver: AnyObserver<String>
    }
    
    struct Output {
        var downloaded: Observable<Data>
        var loading: Observable<Bool>
        var error: Observable<NSError>
    }
    
    var disposeBag = DisposeBag()
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    var targetPath = ""
    var input: ImageCellViewModel.Input!
    var output: ImageCellViewModel.Output!
    private var requestDownloadSubject = PublishSubject<String>()
    private var loadingSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    private var downloadedSubject = PublishSubject<Data>()
    private var errorSubject: PublishSubject<NSError> = PublishSubject()
    private var imageBloc = ImageBloc()
    
    func initialize() {
        self.disposeBag = DisposeBag()
        // swiftlint:disable line_length
        self.input = ImageCellViewModel.Input(requestDownloadObserver: self.requestDownloadSubject.asObserver())
        self.output = ImageCellViewModel.Output(downloaded: self.downloadedSubject.asObservable(),
                                                loading: self.loadingSubject.asObservable(),
                                                error: self.errorSubject.asObservable())
        // swiftlint:enable line_length
        
        self.bindBlocs()
        self.imageBloc.dispatch(event: DownloadImageEvent(targetPath: targetPath))
    }
    
    func bindBlocs() {
        self.imageBloc.stateRelay
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                if let _ = state as? IdleImageState {
                    self.loadingSubject.onNext(false)
                    return
                }

                if let state = state as? ErrorImageState {
                    self.errorSubject.onNext(state.error)
                    return
                }

                if let state = state as? DownloadImageState {
                    self.downloadedSubject.onNext(state.data)
                    return
                }

                if let _ = state as? DownloadingImageState {
                    self.loadingSubject.onNext(true)
                    return
                }
            })
            .disposed(by: self.disposeBag)
    }
}
