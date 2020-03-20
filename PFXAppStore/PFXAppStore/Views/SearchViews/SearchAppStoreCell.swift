//
//  SearchAppStoreCell.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/18.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import Hero

class SearchAppStoreCell: BaseTableViewCell {
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var averageUserRatingLabel: UILabel!
    @IBOutlet weak var bgndView: UIView!
    
    private weak var viewModel: SearchAppStoreCellViewModel?
    var imageCollectionViewController: ImageCollectionViewController?
    private var imageBloc = ImageBloc()
    private var screenshotModel: ScreenshotModel!
    
    func initialize() {
        self.trackNameLabel.text = ""
        self.sellerNameLabel.text = ""
        self.averageUserRatingLabel.text = ""
        self.artworkImageView.image = nil
        if self.artworkImageView.isHidden == false {
            return
        }
        
        self.artworkImageView.isHidden = false
        self.artworkImageView.roundLayer(value: CGFloat(ConstNumbers.artworkImageViewRound))
    }
    
    func willDisplay() {
        guard let viewModel = self.viewModel, let screenshotModel = viewModel.screenshotModel else {
            return
        }

        self.imageCollectionViewController?.willDisplay(screenshotModel: screenshotModel)
    }
    
    func configure(viewModel: BaseCellViewModel, screenshotModel: ScreenshotModel) {
        self.configure(viewModel: viewModel)
        self.screenshotModel = screenshotModel
    }
    
    override func configure(viewModel: BaseCellViewModel) {
        self.initialize()
        guard let viewModel = viewModel as? SearchAppStoreCellViewModel else {
            return
        }

        self.viewModel = viewModel
        self.trackNameLabel.text = viewModel.trackName
        self.sellerNameLabel.text = viewModel.sellerName
        self.averageUserRatingLabel.text = viewModel.averageUserRating
        
        guard let targetPath = viewModel.artworkUrl100 else { return }
        self.imageBloc.stateRelay
            .asDriver(onErrorJustReturn: IdleImageState())
            .drive(onNext: { state in
                if let state = state as? DownloadImageState {
                    self.artworkImageView.image = UIImage(data: state.data)
                    return
                }
            })
            .disposed(by: self.disposeBag)
            
        self.imageBloc.dispatch(event: DownloadImageEvent(targetPath: targetPath))
    }
}
