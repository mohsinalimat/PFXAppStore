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
        var screenshotUrlObserver: AnyObserver<[String]>
    }
    
    struct Output {
        var sections: Observable<[BaseSectionCollectionViewModel]>
        var error: Observable<NSError>
    }
    
    var disposeBag = DisposeBag()
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    var input: ImageCollectionViewModel.Input!
    var output: ImageCollectionViewModel.Output!
    private var sectionsSubject = BehaviorRelay<[BaseSectionCollectionViewModel]>(value: [BaseSectionCollectionViewModel()])
    private var screenshotUrlSubject = PublishSubject<[String]>()
    private var errorSubject: PublishSubject<NSError> = PublishSubject()

    init() {
        
        self.input = ImageCollectionViewModel.Input(screenshotUrlObserver: self.screenshotUrlSubject.asObserver())
        self.output = ImageCollectionViewModel.Output(sections: self.sectionsSubject.asObservable(), error: self.errorSubject.asObservable())
        
        self.bindInputs()
    }
    
    func bindInputs() {
        self.screenshotUrlSubject
            .subscribe(onNext: { [weak self] screenshotUrls in
                guard let self = self else { return }
                var items = [ImageCellViewModel]()
                for url in screenshotUrls {
                    let viewModel = ImageCellViewModel(reuseIdentifier: String(describing: ImageCell.self), identifier: String(describing: ImageCell.self) + String.random())
                    viewModel.targetPath = url
                    items.append(viewModel)
                }
                
                self.sectionsSubject.accept([BaseSectionCollectionViewModel(header: "", items: items)])
            })
            .disposed(by: self.disposeBag)
    }
}
