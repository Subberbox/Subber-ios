//
//  AppDelegate.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 10/31/16.
//  Copyright © 2016 Instacrate. All rights reserved.
//

import UIKit
import Nuke
import NukeAlamofirePlugin
import Stripe
import Alamofire

let loader = Nuke.Loader(loader: NukeAlamofirePlugin.DataLoader(), decoder: Nuke.DataDecoder(), cache: Cache.shared)
let nuke = Nuke.Manager(loader: loader, cache: Cache.shared)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var manager: SessionManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        STPPaymentConfiguration.shared().publishableKey = "pk_test_8CLhJ9ky8vCfyVwFm2CZfXdc"
        
        window = UIWindow()
        window?.rootViewController = MainTabBarController()
        window?.makeKeyAndVisible()
        
        // Hardcode login for now
        guard let auth = Request.authorizationHeader(user: "jasper.gan@berkeley.edu", password: "jasper") else {
            return true
        }
        
        var headers = SessionManager.default.session.configuration.httpAdditionalHeaders!
        headers[auth.key] = [auth.value]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers
            
        manager = Alamofire.SessionManager(configuration: configuration)
        
        manager?.request("http://api.instacrate.me/authentication/?type=customer", method: .post, headers: [auth.key: auth.value]).nativeResponseJSON { response in
            let response = response.response
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: response?.allHeaderFields as! [String: String], for: response!.url!)
            
            print(HTTPCookieStorage.shared.cookies ?? [])

            SessionManager.default.session.configuration.httpCookieStorage?.setCookies(cookies, for: response?.url, mainDocumentURL: nil)
        }

        return true
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

