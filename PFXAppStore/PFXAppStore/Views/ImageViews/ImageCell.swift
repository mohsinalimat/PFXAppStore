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
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let viewModel = self.viewModel else { return layoutAttributes }
        
        setNeedsLayout()
        layoutIfNeeded()
        
        var frame = layoutAttributes.frame
        frame.size.width = CGFloat(viewModel.screenshotModel.width)
        frame.size.height = CGFloat(viewModel.screenshotModel.height)
        layoutAttributes.frame = frame
        return layoutAttributes
    }

    func initialize() {
        self.imageView.image = nil
        self.imageView.roundLayer(value: CGFloat(ConstNumbers.appStoreImageViewRound))
    }
    
    func willDisplay() {
        guard let viewModel = self.viewModel else { return }
        self.imageView.alpha = 0

        viewModel.input.willDisplay.onNext(true)
        if self.animationView != nil {
            self.updateLoadingView()
            return
        }
        
        let animationView = AnimationView(name: "image_loading")
        self.loadingView.addSubview(animationView)
        self.animationView = animationView
        self.updateLoadingView()
        animationView.alpha = 0.8
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .autoReverse
        animationView.play()
    }
    
    func updateLoadingView() {
        guard let animationView = self.animationView, let viewModel = self.viewModel else {
            return
        }
        
        // 다운로드 받은 lottie 파일이라 좌표 및 크기 수정이 잘 안돼서 좌표 설정 해 버림.
        animationView.snp.removeConstraints()
        animationView.snp.makeConstraints { make in
            make.top.equalTo(self.imageView).offset(0)
            make.bottom.equalTo(self.imageView).offset(0)
            
            if viewModel.screenshotModel.isPortrait() {
                make.right.equalTo(self.imageView).offset(0)
                make.left.equalTo(self.imageView).offset(0)
            }
            else {
                make.right.equalTo(self.imageView).offset(-70)
                make.left.equalTo(self.imageView).offset(70)
            }
        }
        
        animationView.play()

        return
    }
    
    override func configure(viewModel: BaseCellViewModel) {
        self.initialize()
        
        guard let viewModel = viewModel as? ImageCellViewModel else {
            return
        }
        
        self.viewModel = viewModel
        viewModel.output.downloaded
            .asDriver(onErrorJustReturn: Data())
            .drive(onNext: { [weak self] data in
                guard let self = self else { return }
                self.imageView.image = UIImage(data: data)
                UIView.animate(withDuration: 0.5) {
                    self.imageView.alpha = 1
                }
            })
            .disposed(by: self.disposeBag)
        
        viewModel.output.loading
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading == true {
                    self.animationView?.alpha = 0.8
                    return
                }

                // stop을 호출하면 lottie 다시 재생이 안됨. 알파로만 처리
                UIView.animate(withDuration: 1, animations: {
                    self.animationView?.alpha = 0
                })
            })
            .disposed(by: self.disposeBag)
        
        viewModel.output.error
            .asDriver(onErrorJustReturn: NSError())
            .drive(onNext: { error in
                
            })
            .disposed(by: self.disposeBag)
    }
}
