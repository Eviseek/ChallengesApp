//  
//  AppDelegate.swift
//  WorkoutTracker
//
//  Created by Eva Chlpikova on 04.03.2026.
//

import UIKit

// swiftlint:disable discouraged_optional_collection
protocol AppDelegateProtocol: AnyObject {
    func applicationDidFinishLaunching(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
}

@Observable
class AppDelegate: UIResponder, UIApplicationDelegate {
    weak var delegate: AppDelegateProtocol?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        setupNavBarAppearance()
        delegate?.applicationDidFinishLaunching(with: launchOptions)
        return true
    }

    // Applies the Archivo Black display font to navigation-bar titles only.
    // Setting the text attributes via the proxy (not a full UINavigationBarAppearance)
    // leaves the bar background alone, so the iOS 26 Liquid Glass chrome is preserved.
    private func setupNavBarAppearance() {
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont.Archivo.navInlineTitle]
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont.Archivo.navLargeTitle]
    }
}
// swiftlint:enable discouraged_optional_collection
