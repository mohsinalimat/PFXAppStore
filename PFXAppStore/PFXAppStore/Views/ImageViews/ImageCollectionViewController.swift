//
//  ImageCollectionViewController.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/19.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxDataSources

class ImageCollectionViewController: UICollectionViewController {
    private var viewModel: ImageCollectionViewModel!
    private var disposeBag = DisposeBag()
    private var rxDataSource: RxCollectionViewSectionedAnimatedDataSource<BaseSectionCollectionViewModel>?
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    func willDisplay(screenshotModel: ScreenshotModel) {
        self.disposeBag = DisposeBag()
        self.viewModel = ImageCollectionViewModel()
        self.bindOutput()
        self.viewModel.input.screenshotUrlObserver.onNext(screenshotModel)
    }
    
    func bindOutput() {
        self.collectionView.delegate = nil
        self.collectionView.dataSource = nil
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = true
            layout.sectionFootersPinToVisibleBounds = true
        }
        self.rxDataSource = RxCollectionViewSectionedAnimatedDataSource<BaseSectionCollectionViewModel>(configureCell: { dataSource, collectionView, indexPath, cellViewModel in
            guard let viewModel = try? (dataSource.model(at: indexPath) as! BaseCellViewModel),
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.reuseIdentifier, for: indexPath) as? ImageCell else {
                    assert(true)
                    return UICollectionViewCell()
            }
            
            cell.configure(viewModel: viewModel)
            return cell
        })
        
        self.viewModel.output.sections.asDriver(onErrorJustReturn: [])
            .drive(self.collectionView.rx.items(dataSource: self.rxDataSource!))
            .disposed(by: self.disposeBag)
        
        self.collectionView.rx.willDisplayCell
            .subscribe(onNext: { cell, indexPath in
                guard let cell = cell as? ImageCell else { return }
                cell.willDisplay()
            })
            .disposed(by: self.disposeBag)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
//        guard let destination = segue.destination as? ExplorerViewController else { return }
//        guard let items = self.collectionView.indexPathsForSelectedItems else { return }
//        guard let indexPath = items.first else { return }
//        guard let viewModel = self.rxDataSource?.sectionModels.first?.items[indexPath.row] as? ExplorerCellViewModel else { return }
//        destination.viewModel = viewModel
    }
}

