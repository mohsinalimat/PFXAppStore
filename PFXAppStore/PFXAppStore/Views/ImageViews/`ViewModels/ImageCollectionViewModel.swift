//
//  ImageCollectionViewModel.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/19.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class ImageCollectionViewModel {
    struct Input {
        var screenshotUrlObserver: AnyObserver<ScreenshotModel>
    }
    
    struct Output {
        var sections: Observable<[BaseSectionCollectionViewModel]>
        var error: Observable<NSError>
    }
    
    var disposeBag = DisposeBag()
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    var size: Size
    var input: ImageCollectionViewModel.Input!
    var output: ImageCollectionViewModel.Output!
    private var sectionsSubject = BehaviorRelay<[BaseSectionCollectionViewModel]>(value: [BaseSectionCollectionViewModel()])
    private var screenshotModelSubject = PublishSubject<ScreenshotModel>()
    private var errorSubject: PublishSubject<NSError> = PublishSubject()

    init(size: Size) {
        
        self.input = ImageCollectionViewModel.Input(screenshotUrlObserver: self.screenshotModelSubject.asObserver())
        self.output = ImageCollectionViewModel.Output(sections: self.sectionsSubject.asObservable(), error: self.errorSubject.asObservable())
        self.size = size
        
        self.bindInputs()
    }
    
    func bindInputs() {
        self.screenshotModelSubject
            .subscribe(onNext: { [weak self] model in
                guard let self = self, let targetPaths = model.targetPaths else { return }
                var items = [ImageCellViewModel]()
                for targetPath in targetPaths {
                    let viewModel = ImageCellViewModel(reuseIdentifier: String(describing: ImageCell.self), identifier: String(describing: ImageCell.self) + String.random())
                    let screenshotModel = ScreenshotModel(targetPaths: [targetPath], size: self.size)
                    viewModel.initialize(screenshotModel: screenshotModel)
                    items.append(viewModel)
                }
                
                self.sectionsSubject.accept([BaseSectionCollectionViewModel(header: "", items: items)])
            })
            .disposed(by: self.disposeBag)
    }
}
