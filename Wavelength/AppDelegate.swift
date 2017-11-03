//
//  AppDelegate.swift
//  Wavelength
//
//  Created by Robert Canton on 2017-10-04.
//  Copyright © 2017 Robert Canton. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import CoreData
import AVFoundation

let API_ENDPOINT = "https://us-central1-wavelength-app.cloudfunctions.net"

let accentColor = UIColor(red: 0, green: 152/255, blue: 235/255, alpha: 1)
let primaryColor = UIColor(red: 99/255, green: 219/255, blue: 254/255, alpha: 1)
let secondaryColor = UIColor(red: 98/255, green: 139/255, blue: 220/255, alpha: 1)

let imageCacheManager = ImageCacheManager()
func fetchMediaImageCheckingCache(url:URL, completion:@escaping((_ imageURL:String, _ image:UIImage?)->())) {
    if let image = imageCacheManager.cachedImage(url: url) {
        return completion(url.absoluteString, image)
    } else {
        imageCacheManager.fetchImage(url: url) { image in
            return completion(url.absoluteString, image)
        }
    }
}

func getHTTPSHeaders(_ completion:@escaping (_ headers:HTTPHeaders?)->()) {
    guard let user = Auth.auth().currentUser else { return completion(nil) }
    user.getIDToken() { token, error in
        
        if token == nil || error != nil {
            return completion(nil)
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token!)", "Accept": "application/json", "Content-Type" :"application/json"]
        return completion(headers)
    }
}

var userConfig:UserConfig!
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let config:[UserConfig] = try context.fetch(UserConfig.fetchRequest())
            if config.count == 0 {
                userConfig = UserConfig(context: context)
                userConfig.currenttheme = "Default"
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            } else {
                userConfig = config[0]
            }
            
            
        } catch {
            print("Error with request")
            userConfig = UserConfig(context: context)
            userConfig.currenttheme = "Default"
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        
        ThemeManager.fetchCustomThemes()
        if let currentTheme = userConfig.currenttheme {
            for theme in ThemeManager.defaultThemes {
                if theme.name == currentTheme {
                    ThemeManager.setNewTheme(theme)
                }
            }
            
            for theme in ThemeManager.customThemes {
                if theme.name == currentTheme {
                    ThemeManager.setNewTheme(theme)
                }
            }
        }
        didThemeUpdate()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didThemeUpdate), name: ThemeManager.didThemeUpdate, object: nil)
        
        do {
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch {
            print("error")
        }
        VolumeBar.sharedInstance.animationStyle = .fade
        VolumeBar.sharedInstance.start()
        
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
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate: ThemeDelegate {
    @objc func didThemeUpdate() {
        VolumeBar.sharedInstance.backgroundColor = currentTheme.background.color
        VolumeBar.sharedInstance.tintColor = currentTheme.detailPrimary.color
        VolumeBar.sharedInstance.trackTintColor = currentTheme.detailSecondary.color
    }
}
