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
        var willDisplay: AnyObserver<Bool>
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
    
    var input: ImageCellViewModel.Input!
    var output: ImageCellViewModel.Output!
    private var willDisplaySubject = PublishSubject<Bool>()
    private var loadingSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    private var downloadedSubject = PublishSubject<Data>()
    private var errorSubject: PublishSubject<NSError> = PublishSubject()
    private var imageBloc = ImageBloc()
    var screenshotModel: ScreenshotModel!

    func initialize(screenshotModel: ScreenshotModel) {
        self.disposeBag = DisposeBag()
        // swiftlint:disable line_length
        self.input = ImageCellViewModel.Input(willDisplay: self.willDisplaySubject.asObserver())
        self.output = ImageCellViewModel.Output(downloaded: self.downloadedSubject.asObservable(),
                                                loading: self.loadingSubject.asObservable(),
                                                error: self.errorSubject.asObservable())
        // swiftlint:enable line_length
        
        self.screenshotModel = screenshotModel
        
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
    
    func bindInputs() {
        self.willDisplaySubject
            .subscribe(onNext: { [weak self] value in
                guard let self = self, let targetPath = self.screenshotModel.targetPaths?.first else { return }
                let folderName = ((targetPath as NSString).lastPathComponent as NSString).deletingPathExtension
                // Hero 하기 위해서 이미지 캐싱 되어 있는 데이터로 먼저 보여주기
                if let cacheData = FileCacheHelper.shared.loadImageData(folderName: folderName, key: targetPath) {
                    self.downloadedSubject.onNext(cacheData)
                }

                // DownloadImageEvent에서 이미지 contents length 체크로 인해 공백이 보임.
                self.imageBloc.dispatch(event: DownloadImageEvent(targetPath: targetPath))
            })
            .disposed(by: self.disposeBag)
    }
}
