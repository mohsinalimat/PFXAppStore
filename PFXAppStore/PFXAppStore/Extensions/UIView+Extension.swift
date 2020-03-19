//
//  UIView+Extension.swift
//  PFXAppStore
//
//  Created by PFXStudio on 2020/03/19.
//  Copyright © 2020 PFXStudio. All rights reserved.
//

import Foundation
import RxSwift

extension UIView {
    func roundLayer(value: CGFloat) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = value
    }
    
    func roundBorder(width: CGFloat, color: CGColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color
    }
    
    func gradient(startPoint: CGPoint, endPoint: CGPoint) -> CAGradientLayer {
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = self.frame
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
        gradientLayer.locations = [0, 0.5, 1]
        self.layer.addSublayer(gradientLayer)
        return gradientLayer
    }
}

extension UIAlertController {
  struct Action<T> {
    var title: String?
    var style: UIAlertAction.Style
    var value: T

    static func action(title: String?, style: UIAlertAction.Style = .default, value: T) -> Action {
      return Action(title: title, style: style, value: value)
    }
  }

  static func present<T>(in viewController: UIViewController,
                      title: String? = nil,
                      message: String? = nil,
                      style: UIAlertController.Style,
                      actions: [Action<T>]) -> Observable<T> {
    return Observable.create { observer in
      let alertController = UIAlertController(title: title, message: message, preferredStyle: style)

      actions.enumerated().forEach { index, action in
        let action = UIAlertAction(title: action.title, style: action.style) { _ in
          observer.onNext(action.value)
          observer.onCompleted()
        }
        alertController.addAction(action)
      }

      viewController.present(alertController, animated: true, completion: nil)
      return Disposables.create { alertController.dismiss(animated: true, completion: nil) }
    }
  }
}
