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

class AppInfoTableViewController: UITableViewController {
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
    // screenshotUrls
    // ipadScreenshotUrls
    // trackContentRating
    // genres
    // artworkUrl512

    var viewModel: AppInfoViewModel?
    private var disposeBag = DisposeBag()
    private var rxDataSource: RxTableViewSectionedAnimatedDataSource<BaseSectionTableViewModel>?
    private var searchEmptyView = SearchEmptyView()
    private var ignore = false
    deinit {
        self.disposeBag = DisposeBag()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindTableView()
        self.bindInputs()
        self.bindOutputs()
    }
    
    func bindTableView() {
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.rxDataSource = RxTableViewSectionedAnimatedDataSource<BaseSectionTableViewModel>(configureCell: { dataSource, tableView, indexPath, cellViewModel in
            guard let viewModel = try? (dataSource.model(at: indexPath) as? BaseCellViewModel),
                let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reuseIdentifier, for: indexPath) as? SearchHistoryCell else {
                    return UITableViewCell()
            }
            
            cell.configure(viewModel: viewModel)
            return cell
        }, titleForHeaderInSection: { (dataSource, index) in
            let viewModel = dataSource.sectionModels[index]
            return viewModel.header
        })

//        self.viewModel.output.recentSections
//            .bind(to: self.tableView.rx.items(dataSource: self.rxDataSource!))
//            .disposed(by: self.disposeBag)
    }
    
    func bindInputs() {
    }
    
    func bindOutputs() {
        
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let destination = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: String(describing: SearchHeaderSectionViewController.self))
//        return destination.view
//    }
//
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 60
//    }
}
