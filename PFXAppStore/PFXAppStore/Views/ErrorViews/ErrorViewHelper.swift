//
//  ErrorViewHelper.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/21.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import SwiftMessages

class ErrorViewHelper {
    class func show(error: NSError) {
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.presentationContext = .window(windowLevel: .statusBar)
        config.duration = .automatic
        config.dimMode = .gray(interactive: true)
        config.interactiveHide = false
        config.preferredStatusBarStyle = .lightContent

        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.error)
        view.configureDropShadow()
        let iconText = "😡"
        view.configureContent(title: "Error", body: PBError.messageKey(value: error.code), iconText: iconText)
        view.button?.isHidden = true
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        SwiftMessages.show(config: config, view: view)
    }
}
