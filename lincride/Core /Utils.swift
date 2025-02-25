//
//  Utils.swift
//  lincride
//
//  Created by Adeoluwa on 24/02/2025.
//
import Foundation
import UIKit


struct Utils {
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}
