//
//  UIViewController+showAlert.swift
//  YouTubeAPI
//
//  Created by VitaliyButsan on 18.05.2022.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String = "Error!", message: String, style: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let okAction = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
}

