//
//  ScreenshotCell.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/21.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation

class ScreenshotCell: BaseTableViewCell {
//    @IBOutlet weak var artworkImageView: UIImageView!
//    @IBOutlet weak var trackNameLabel: UILabel!
//    @IBOutlet weak var sellerNameLabel: UILabel!
//    @IBOutlet weak var averageUserRatingLabel: UILabel!
//    @IBOutlet weak var bgndView: UIView!
//    @IBOutlet weak var appInfoButton: UIButton!

    private weak var viewModel: AppInfoCellViewModel?
    var imageCollectionViewController: ImageCollectionViewController?
    private var imageBloc = ImageBloc()
    
    func initialize() {
//        self.averageUserRatingLabel.text = ""
//        self.artworkImageView.image = nil
//        if self.artworkImageView.isHidden == false {
//            return
//        }
//
//        self.artworkImageView.isHidden = false
//        self.artworkImageView.roundLayer(value: CGFloat(ConstNumbers.artworkImageViewRound))
    }
    
    func willDisplay() {
        guard let viewModel = self.viewModel, let screenshotModel = viewModel.appStoreModel?.screenshotUrls else {
            return
        }

        self.imageCollectionViewController?.willDisplay(screenshotModel: ScreenshotModel(targetPaths: screenshotModel, width: 200, height: 450))
    }
    
    override func configure(viewModel: BaseCellViewModel) {
        self.initialize()
        guard let viewModel = viewModel as? AppInfoCellViewModel else {
            return
        }

        self.viewModel = viewModel
//        self.trackNameLabel.text = viewModel.trackName
//        self.sellerNameLabel.text = viewModel.sellerName
//        self.averageUserRatingLabel.text = viewModel.averageUserRating
        
        guard let targetPath = viewModel.appStoreModel?.artworkUrl512 else { return }
        self.imageBloc.stateRelay
            .asDriver(onErrorJustReturn: IdleImageState())
            .drive(onNext: { state in
                if let state = state as? DownloadImageState {
//                    self.artworkImageView.image = UIImage(data: state.data)
                    return
                }
            })
            .disposed(by: self.disposeBag)
            
        self.imageBloc.dispatch(event: DownloadImageEvent(targetPath: targetPath))
    }
}
