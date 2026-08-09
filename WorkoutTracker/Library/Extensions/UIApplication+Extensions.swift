//
//  UIApplication+Extensions.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 18.03.2026.
//

import UIKit

extension UIApplication {
    var windowScene: UIWindowScene? {
        connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
    }

    var rootViewController: UIViewController? {
        windowScene?.windows.first?.rootViewController
    }
}
