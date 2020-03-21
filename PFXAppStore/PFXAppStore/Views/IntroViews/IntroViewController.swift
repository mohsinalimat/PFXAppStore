//
//  IntroViewController.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/21.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class IntroViewController: UIViewController {
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.animationView.contentMode = .scaleAspectFit
        self.animationView.loopMode = .loop
        self.animationView.play()
        
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.titleLabel.alpha = 1
        }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            guard let destination = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "SearchTabBarController") as? UITabBarController else { return }
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            appDelegate.window!.rootViewController = destination
        }
    }
}
