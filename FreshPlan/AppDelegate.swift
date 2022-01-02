//
//  AppDelegate.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-10-05.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import UIKit
import MaterialComponents
import Fabric
import Crashlytics
import OneSignal
import Reachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSPermissionObserver, OSSubscriptionObserver {

	var window: UIWindow?
  let reachability = Reachability()!

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// set up the window size
		window = UIWindow(frame: UIScreen.main.bounds)
		guard let window = self.window else { fatalError("no window") }
    prepareFabric()
    prepareOneSignal(launchOptions)
		// setup window to make sure
		// check to make sure if token exists or not
    window.makeKeyAndVisible()
    window.backgroundColor = .white
    if let _ = UserDefaults.standard.string(forKey: "token"), let jwt = Token.decodeJWT {
      if jwt.expired {
        let alertController = MDCAlertController(title: "Login Expired", message: "Your login credentials have expired. Please log back in.")
        let action = MDCAlertAction(title: "OK", handler: { _ in
          UserDefaults.standard.removeObject(forKey: "token")
        })
        alertController.addAction(action)
        window.rootViewController = LoginAssembler.make()
        window.rootViewController?.present(alertController, animated: true)
      } else {
        window.rootViewController = HomeAssembler.make()
      }
    } else {
      window.rootViewController = LoginAssembler.make()
    }
    // check connection here
    prepareReachability()
		return true
	}
  
  private func prepareOneSignal(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
    let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: true]
    
    // Replace 'YOUR_APP_ID' with your OneSignal App ID.
    OneSignal.initWithLaunchOptions(launchOptions,
                                    appId: "65c83147-8269-4f36-a255-d737806c465e",
                                    handleNotificationAction: nil,
                                    settings: onesignalInitSettings)
    
    OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
    
    // Recommend moving the below line to prompt for push after informing the user about
    //   how your app will use them.
    OneSignal.promptForPushNotifications(userResponse: { accepted in
      print("User accepted notifications: \(accepted)")
    })
    
    // add for player id searching and notification
    OneSignal.add(self as OSPermissionObserver)
    OneSignal.add(self as OSSubscriptionObserver)
  }
  
  // Add this new method
  public func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
    // Example of detecting answering the permission prompt
    if stateChanges.from.status == OSNotificationPermission.notDetermined {
      if stateChanges.to.status == OSNotificationPermission.authorized {
        print("Thanks for accepting notifications!")
      } else if stateChanges.to.status == OSNotificationPermission.denied {
        print("Notifications not accepted. You can turn them on later under your iOS settings.")
      }
    }
    // prints out all properties
    print("PermissionStateChanges: \n\(stateChanges)")
  }
  
  // Add this new method
  // sets up the notificatino for us
  public func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
    if !stateChanges.from.subscribed && stateChanges.to.subscribed {
      print("Subscribed for OneSignal push notifications!")
      // get player ID
      UserDefaults.standard.set(stateChanges.to.userId, forKey: "deviceToken")
    }
  }
  
  private func prepareFabric() {
    #if DEBUG
      print ("Skipping Crashalytics")
    #else
      print ("~~~~*** Starting Fabrics Crashalytics ***~~~~~")
      Fabric.with([Crashlytics.self])
    #endif
  }
  
  private func prepareReachability() {
    NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .reachabilityChanged, object: reachability)
    do{
      try reachability.startNotifier()
    }catch{
      print("could not start reachability notifier")
    }
  }
  
  @objc func reachabilityChanged(note: Notification) {
    let reachability = note.object as! Reachability
    
    if reachability.connection == .none {
      print("Network not reachable")
      // present the window
      let alert = UIAlertController(
        title: "No Network Connection",
        message: "Please check in your settings to make sure you're connected to the internet",
        preferredStyle: .alert
      )
      
      let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
      
      alert.addAction(action)
      
      window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
  }

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

