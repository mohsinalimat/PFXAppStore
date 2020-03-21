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

class AppInfoTableViewController: UITableViewController, NVActivityIndicatorViewable {
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var averageUserRatingLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var trackContentRatingLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!

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
        
        self.artworkImageView.roundLayer(value: CGFloat(ConstNumbers.artworkImageViewRound))
        self.downloadButton.roundLayer(value: CGFloat(ConstNumbers.buttonRound))
        self.moreButton.roundLayer(value: CGFloat(ConstNumbers.buttonRound))
        self.bindOutputs()
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
                if isLoading == true {
                    let size = CGSize(width: 30, height: 30)
                    let selectedIndicatorIndex = 15
                    let indicatorType = self.presentingIndicatorTypes[selectedIndicatorIndex]
                    self.startAnimating(size, message: "Loading...", type: indicatorType, fadeInAnimation: nil)
                    return
                }
                
                self.stopAnimating()
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
                guard let self = self else { return }
                self.averageUserRatingLabel.text = value
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == AppInfoSectionType.ipadScreenshot.rawValue {
            if self.viewModel.appStoreModel.ipadScreenshotUrls.count == 0 {
                return UIView()
            }
            
            guard let sectionView = Bundle.main.loadNibNamed("iPadSectionView", owner: self, options: nil)?.first as? iPadSectionView else {
                return UIView()
            }
            
            if self.toggleValue == true {
                sectionView.toggleButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
                sectionView.toggleButton.setTitle("iPhone", for: .normal)
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
                guard let sectionView = Bundle.main.loadNibNamed("iPadSectionView", owner: self, options: nil)?.first as? iPadSectionView else {
                    return UIView()
                }
                
                if self.toggleValue == true {
                    sectionView.toggleButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
                    sectionView.toggleButton.setTitle("iPad", for: .normal)
                    sectionView.toggleButton.isEnabled = false
                    
                    return sectionView
                }
            }
        }
        
        return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == AppInfoSectionType.info.rawValue {
            return 165
        }

        if indexPath.section == AppInfoSectionType.iphoneScreenshot.rawValue {
            if self.viewModel.appStoreModel.screenshotUrls.count == 0 {
                return 0
            }
            
            return 550
        }
        
        if indexPath.section == AppInfoSectionType.ipadScreenshot.rawValue {
            if self.viewModel.appStoreModel.ipadScreenshotUrls.count == 0 {
                return 0
            }
            
            if self.toggleValue == true {
                return 450
            }
            
            return 0
        }
        
        if indexPath.section == AppInfoSectionType.description.rawValue {
            return 100
        }
        

        return 100
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
            screenshotModel = ScreenshotModel(targetPaths: self.viewModel.appStoreModel.screenshotUrls, width: 250, height: 550)
            return
        }
        
        self.ipadImageCollectionViewController = destination
        screenshotModel = ScreenshotModel(targetPaths: self.viewModel.appStoreModel.ipadScreenshotUrls, width: 300, height: 450)
    }
}
