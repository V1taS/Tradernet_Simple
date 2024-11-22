//
//  AppDelegate.swift
//  Tradernet_Simple
//
//  Created by Vitalii Sosin on 22.11.2024.
//

import UIKit
import SwiftUI

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
  
  // MARK: - Internal properties
  
  var window: UIWindow?
  
  // MARK: - Private properties
  
  // MARK: - Internal func
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    setupWindowForPreiOS13()
    return true
  }
  
  // MARK: - Private Methods
  
  private func setupWindowForPreiOS13() {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = MainScreenViewController()
    window?.makeKeyAndVisible()
  }
}
