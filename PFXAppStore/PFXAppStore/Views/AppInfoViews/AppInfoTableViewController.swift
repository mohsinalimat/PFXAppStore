//
//  AppInfoTableViewController.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/20.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxDataSources
import NVActivityIndicatorView
import TTGEmojiRate
import Lottie

class AppInfoTableViewController: UITableViewController, NVActivityIndicatorViewable {
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var averageUserRatingLabel: UILabel!
    @IBOutlet weak var averageUserRatingView: EmojiRateView!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var trackContentRatingLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private weak var animationView: AnimationView?

    var viewModel: AppInfoViewModel!
    private var toggleValue = false
    private var iphoneImageCollectionViewController: ImageCollectionViewController?
    private var ipadImageCollectionViewController: ImageCollectionViewController?
    private let presentingIndicatorTypes = {
        return NVActivityIndicatorType.allCases.filter { $0 != .blank }
    }()

    private var disposeBag = DisposeBag()
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.artworkImageView.hero.id = "artworkImageView" + self.viewModel.heroId
        self.artworkImageView.roundLayer(value: CGFloat(ConstNumbers.artworkImageViewRound))
        self.downloadButton.roundLayer(value: CGFloat(ConstNumbers.buttonRound))
        self.moreButton.roundLayer(value: CGFloat(ConstNumbers.buttonRound))
        self.bindOutputs()
        self.bindButtons()
        
        self.averageUserRatingView.rateColorRange = ConstColors.rateColorRange
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.input.refreshObserver.onNext(true)
    }
    
    func bindOutputs() {
        self.viewModel.output.loading
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                self.showLoading(isLoading: isLoading)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.error
            .asDriver(onErrorJustReturn: NSError())
            .drive(onNext: { error in
                ErrorViewHelper.show(error: error)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.artworkImage
            .asDriver(onErrorJustReturn: Data())
            .drive(onNext: { [weak self] value in
                guard let self = self, let image = UIImage(data: value) else { return }
                self.artworkImageView.image = image
            })
            .disposed(by: self.disposeBag)

        self.viewModel.output.trackName
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] value in
                guard let self = self else { return }
                self.trackNameLabel.text = value
            })
            .disposed(by: self.disposeBag)

        self.viewModel.output.sellerName
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] value in
                guard let self = self else { return }
                self.sellerNameLabel.text = value
            })
            .disposed(by: self.disposeBag)

        self.viewModel.output.averageUserRating
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] value in
                guard let self = self, let rateValue = Float(value) else { return }
                self.averageUserRatingLabel.text = value
                self.averageUserRatingView.rateValue = rateValue
            })
            .disposed(by: self.disposeBag)

        self.viewModel.output.genres
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] value in
                guard let self = self else { return }
                self.genresLabel.text = value
            })
            .disposed(by: self.disposeBag)

        self.viewModel.output.trackContentRating
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] value in
                guard let self = self else { return }
                self.trackContentRatingLabel.text = value
            })
            .disposed(by: self.disposeBag)

        self.viewModel.output.description
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] value in
                guard let self = self else { return }
                self.descriptionLabel.text = value
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindButtons() {
        self.moreButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.moreButton.tag != 0 {
                    return
                }
                
                self.moreButton.tag = 1
                self.moreButton.isHidden = true
                self.tableView.reloadData()
            })
            .disposed(by: self.disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == AppInfoSectionType.info.rawValue {
            guard let sectionView = Bundle.main.loadNibNamed("CloseSectionView", owner: self, options: nil)?.first as? CloseSectionView else {
                return UIView()
            }
            
            sectionView.closeButton.rx.tap
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.dismiss(animated: true, completion: nil)
                })
                .disposed(by: self.disposeBag)
            
            return sectionView
        }

        if section == AppInfoSectionType.ipadScreenshot.rawValue {
            if self.viewModel.appStoreModel.ipadScreenshotUrls.count == 0 {
                return UIView()
            }
            
            guard let sectionView = Bundle.main.loadNibNamed("PadSectionView", owner: self, options: nil)?.first as? PadSectionView else {
                return UIView()
            }
            
            if self.toggleValue == true {
                sectionView.toggleButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
                sectionView.toggleButton.setTitle(" iPhone", for: .normal)
                sectionView.toggleButton.isEnabled = false
            }
            
            sectionView.toggleButton.rx.tap
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    if self.toggleValue == true {
                        return
                    }
                    
                    self.toggleValue = !self.toggleValue
                    self.tableView.reloadData()
                })
                .disposed(by: self.disposeBag)
            
            return sectionView
        }
        
        if section == AppInfoSectionType.description.rawValue {
            if self.toggleValue == true {
                guard let sectionView = Bundle.main.loadNibNamed("PadSectionView", owner: self, options: nil)?.first as? PadSectionView else {
                    return UIView()
                }
                
                if self.toggleValue == true {
                    sectionView.toggleButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
                    sectionView.toggleButton.setTitle(" iPad", for: .normal)
                    sectionView.toggleButton.isEnabled = false
                    
                    return sectionView
                }
            }
        }
        
        return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == AppInfoSectionType.info.rawValue {
            return UITableView.automaticDimension
        }

        if indexPath.section == AppInfoSectionType.iphoneScreenshot.rawValue {
            if self.viewModel.appStoreModel.screenshotUrls.count == 0 {
                return 0
            }
            
            return self.viewModel.appStoreModel.isPortraitPhoneScreenshot() == true ?
                CGFloat(ConstNumbers.portraitPhoneImageSize.height + 40) : CGFloat(ConstNumbers.landscapePhoneImageSize.height + 40)
        }
        
        if indexPath.section == AppInfoSectionType.ipadScreenshot.rawValue {
            if self.viewModel.appStoreModel.ipadScreenshotUrls.count == 0 {
                return 0
            }
            
            if self.toggleValue == true {
                return self.viewModel.appStoreModel.isPortraitPadScreenshot() == true ?
                    CGFloat(ConstNumbers.portraitPadImageSize.height + 40) : CGFloat(ConstNumbers.landscapePadImageSize.height + 40)
            }
            
            return 0
        }
        
        if indexPath.section == AppInfoSectionType.description.rawValue {
            if self.moreButton.tag == 1 {
                return UITableView.automaticDimension
            }
            
            return 100
        }
        
        return UITableView.automaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let destination = segue.destination as? ImageCollectionViewController else {
            return
        }
        
        var screenshotModel = ScreenshotModel()
        defer {
            destination.willDisplay(screenshotModel: screenshotModel)
        }

        if segue.identifier == "iphoneImageCollectionViewController" {
            self.iphoneImageCollectionViewController = destination
            destination.collectionView.hero.id = self.viewModel.heroId
            var size = ConstNumbers.portraitPhoneImageSize
            if self.viewModel.appStoreModel.isPortraitPhoneScreenshot() == false {
                size = ConstNumbers.landscapePhoneImageSize
            }
            
            screenshotModel = ScreenshotModel(targetPaths: self.viewModel.appStoreModel.screenshotUrls, size: size)
            return
        }
        
        self.ipadImageCollectionViewController = destination
        var size = ConstNumbers.portraitPadImageSize
        if self.viewModel.appStoreModel.isPortraitPadScreenshot() == false {
            size = ConstNumbers.landscapePadImageSize
        }
        
        screenshotModel = ScreenshotModel(targetPaths: self.viewModel.appStoreModel.ipadScreenshotUrls, size: size)
    }
    
    func showLoading(isLoading: Bool) {
        if isLoading == false {
            UIView.animate(withDuration: 1) {
                self.animationView?.alpha = 0
            }
        }
        
        if self.animationView != nil {
            self.updateLoadingView()
            return
        }
        
        let animationView = AnimationView(name: "image_loading")
        self.artworkImageView.addSubview(animationView)
        self.animationView = animationView
        self.updateLoadingView()
        animationView.alpha = 0.8
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
    }
    
    func updateLoadingView() {
        guard let animationView = self.animationView else {
            return
        }
        
        animationView.snp.removeConstraints()
        animationView.snp.makeConstraints { make in
            make.centerX.equalTo(self.artworkImageView)
            make.centerY.equalTo(self.artworkImageView)
            make.width.height.equalTo(44)
        }
        
        animationView.play()

        return
    }
    

}
