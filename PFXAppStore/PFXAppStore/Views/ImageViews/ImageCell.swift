//
//  ImageCell.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/19.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Lottie

class ImageCell: BaseCollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingView: UIView!

    private var viewModel: ImageCellViewModel?
    private var animationView: AnimationView?

    func initialize() {
        self.imageView.image = nil
        if self.animationView != nil { return }
        let animationView = AnimationView(name: "heart-jump")
        animationView.frame = self.loadingView.frame
        animationView.center = CGPoint(x: 0, y: self.loadingView.center.y)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .autoReverse
        self.loadingView.addSubview(animationView)
        animationView.play()
        self.animationView = animationView
    }
    
    func willDisplay() {
        guard let viewModel = self.viewModel else { return }
        viewModel.input.willDisplay.onNext(true)
    }
    
    override func configure(viewModel: BaseCellViewModel) {
        self.initialize()
        
        guard let viewModel = viewModel as? ImageCellViewModel else {
            return
        }
        
        self.viewModel = viewModel
        viewModel.initialize()
        viewModel.output.downloaded
            .asDriver(onErrorJustReturn: Data())
            .drive(onNext: { [weak self] data in
                guard let self = self else { return }
                self.imageView.image = UIImage(data: data)
            })
            .disposed(by: self.disposeBag)
        
        viewModel.output.loading
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading == true {
                    self.animationView?.play()
                    return
                }

                self.animationView?.stop()
            })
            .disposed(by: self.disposeBag)
        
        viewModel.output.error
            .asDriver(onErrorJustReturn: NSError())
            .drive(onNext: { error in
                
            })
            .disposed(by: self.disposeBag)
    }
}
