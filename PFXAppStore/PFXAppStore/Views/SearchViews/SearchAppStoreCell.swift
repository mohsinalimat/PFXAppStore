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
import TTGEmojiRate
import RxSwift

class SearchAppStoreCell: BaseTableViewCell {
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var averageUserRateView: EmojiRateView!
    @IBOutlet weak var averageUserRatingLabel: UILabel!
    @IBOutlet weak var bgndView: UIView!
    @IBOutlet weak var appInfoButton: UIButton!

    private weak var viewModel: SearchAppStoreCellViewModel?
    var imageCollectionViewController: ImageCollectionViewController?
    private var imageBloc = ImageBloc()
    
    func initialize() {
        self.trackNameLabel.text = ""
        self.sellerNameLabel.text = ""
        self.averageUserRatingLabel.text = ""
        self.averageUserRateView.rateValue = 0
        self.artworkImageView.image = nil
        if self.artworkImageView.isHidden == false {
            return
        }
        
        self.averageUserRateView.rateColorRange = ConstColors.rateColorRange
        self.artworkImageView.isHidden = false
        self.artworkImageView.roundLayer(value: CGFloat(ConstNumbers.artworkImageViewRound))
    }
    
    func willDisplay() {
        guard let viewModel = self.viewModel, let screenshotModel = viewModel.screenshotModel else {
            return
        }

        self.imageCollectionViewController?.willDisplay(screenshotModel: screenshotModel)
    }
    
    override func configure(viewModel: BaseCellViewModel) {
        super.configure(viewModel: viewModel)
        self.initialize()
        guard let viewModel = viewModel as? SearchAppStoreCellViewModel else {
            return
        }

        self.contentView.hero.id = viewModel.identifier
        self.artworkImageView.hero.id = "artworkImageView" + viewModel.identifier
        self.viewModel = viewModel
        self.trackNameLabel.text = viewModel.trackName
        self.sellerNameLabel.text = viewModel.sellerName
        self.averageUserRatingLabel.text = viewModel.averageUserRating
        if let rateValue = viewModel.averageUserRating {
            if let value = Float(rateValue) {
                self.averageUserRateView.rateValue = value
            }
        }

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
